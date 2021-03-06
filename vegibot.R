####################
# Vegibot @ vonRou #
####################

#a piece of code by Ueli Reber (@el_ueli)
#inspired by this great tutorial: http://www.r-datacollection.com/blog/Programming-a-Twitter-bot/

library(rvest)
library(stringr)
library(twitteR)

#harvest today's menu from the mensa's website
menu <- read_html(paste0("http://zfv.ch/de/microsites/mensa-und-cafeteria-vonroll/menuplan#", Sys.Date()))

#extract today's menu
menu.today <- menu %>%
  html_nodes(paste0("[data-date='", Sys.Date(), "']"))

#extract nutritional information
menu.facts <- menu.today[[2]] %>% html_nodes(".info-list") %>% xml_nodes("span") %>% xml_text()
menu.facts.meat <- menu.today[[3]] %>% html_nodes(".info-list") %>% xml_nodes("span") %>% xml_text()

#check if menu is vegan
if (str_detect(as.character(html_children(menu.today[2])[1]), "vegan") == TRUE) {
  vegan <- 1
} else {
  vegan <- 0
}

#extract the vegi menu
menu.vegi <- html_text(menu.today[2])

#trim menu
menu.vegi <- str_replace(menu.vegi, "\nmit", " mit")
menu.vegi <- str_replace(menu.vegi, "\n&", " &")
menu.vegi <- str_replace_all(menu.vegi, "(?<=[:alpha:])\\n(?=[:alpha:])", ", ")
menu.vegi <- str_replace_all(menu.vegi, "\n", "")
menu.vegi <- str_replace_all(menu.vegi, "natürlich vegi", "")
menu.vegi <- str_replace_all(menu.vegi, "[^\\s]*(VEGAN)[^\\s]*", "")
menu.vegi <- str_replace_all(menu.vegi, "\\CHF(.*)", "")
menu.vegi <- str_trim(menu.vegi, "both")
menu.vegi <- str_replace_all(menu.vegi, "  ", " ")

#assemble the tweet
if (str_detect(tolower(menu.vegi), "geschlossen") == TRUE) {
  text <- "Hüt gits ke Vegimenü. Muesch äuä säuber choche. 🍳"
  } else {
    if (nchar(menu.vegi) < 20){
      text <- "Hüt gits ke Vegimenü. Muesch äuä säuber choche. 🍳"
      } else {
        if (vegan == 1){
            text <- paste0("Hüt gits: ", menu.vegi, ". Vou vegan! E Guete! 💚")
        } else {
          text <- paste0("Hüt gits: ", menu.vegi, ". E Guete!")
        }
      }
    }

#set up Twitter access for user VegivonRou
source("credentials.R", encoding = "UTF-8")
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#send Tweet
tweet(text)

#save today's menu to the log file
log.df <- data.frame(date = Sys.Date(),
                     day = format(Sys.Date(), "%A"),
                     vegan = vegan,
                     calories = menu.facts[2],
                     fat = menu.facts[3],
                     carbs = menu.facts[4],
                     proteins = menu.facts[5],
                     menu = menu.vegi,
                     tweet = text,
                     meat_calories = menu.facts.meat[2],
                     meat_fat = menu.facts.meat[3],
                     meat_carbs = menu.facts.meat[4],
                     menu_proteins = menu.facts.meat[5])

write.table(log.df, file = "menu_log.csv", row.names = FALSE, col.names = FALSE, append = TRUE, sep = ";")