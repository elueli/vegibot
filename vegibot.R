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

#get today's menu
menu.today <- menu %>%
  html_nodes(paste0("[data-date='", Sys.Date(), "']"))

#check if menu is vegan
if (str_detect(as.character(html_children(menu.today[2])[1]), "vegan") == TRUE) {
  vegan <- 1
} else {
  vegan <- 0
}

#select the vegi menu
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
log.df <- data.frame(date = Sys.Date(), vegan = vegan, pacman = NA, menu = menu.vegi, tweet = text)

write.table(log.df, file = "menu_log.csv", row.names = FALSE, col.names = FALSE, append = TRUE, sep = ";")
