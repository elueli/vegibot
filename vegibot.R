##########################
# Twitterbot @VegivonRou #
##########################

library(rvest)
library(stringr)
library(twitteR)

#harvest today's menu from the mensa's website
menu <- read_html(paste0("http://zfv.ch/de/microsites/mensa-und-cafeteria-vonroll/menuplan#", Sys.Date()))

#get today's menu
menu.today <- menu %>%
  html_nodes(paste0("[data-date='", Sys.Date(), "']"))

#select the vegi menu
menu.vegi <- html_text(menu.today[2])

#extract the pacman
pacman.str <- as.character(html_children(menu.today[2])[1])

if (str_detect(pacman.str, "green") == TRUE) {
  pacman <- 1
  } else {
    if (str_detect(pacman.str, "yellow") == TRUE) {
      pacman <- 2
      } else {
        pacman <- 3
      }
    }

#check if menu is vegan
if (str_detect(tolower(menu.vegi), "vegan") == TRUE) {
  vegan <- 1
} else {
  vegan <- 0
}

#trim menu
menu.vegi <- str_replace_all(menu.vegi, "\n", " ")
menu.vegi <- str_replace_all(menu.vegi, "«natürlich vegi»", " ")
menu.vegi <- str_replace_all(menu.vegi, "CHF 6.60 / 12.60 | CHF 6.60 / CHF 12.60", " ")
menu.vegi <- str_replace(menu.vegi, "[^\\s]*(VEGAN)[^\\s]*", "") 
menu.vegi <- str_trim(menu.vegi, "both")

#assemble the tweet
if (str_detect(tolower(menu.vegi), "geschlossen") == TRUE) {
  text <- "Hüt gits ke Vegimenü. Muesch äuä säuber choche. 🍳"
  } else {
    if (nchar(menu.vegi) < 20){
      text <- "Hüt gits ke Vegimenü. Muesch äuä säuber choche. 🍳"
      } else {
        if (vegan == 1){
          if (pacman == 1){
            text <- paste0("Hüt gits öppis fürd Gsündi: ", menu.vegi, ". Vou vegan! E Guete! 💚")
          } else {
            if (pacman == 2){
              text <- paste0("Hüt gits öppis füre Geist: ", menu.vegi, ". Vou vegan! E Guete! 💚")
            } else {
              text <- paste0("Hüt gits öppis fürd Lust: ", menu.vegi, ". Vou vegan! E Guete! 💚")
            }
          }
        } else {
          if (pacman == 1){
            text <- paste0("Hüt gits öppis fürd Gsündi: ", menu.vegi, ". E Guete!")
          } else {
            if (pacman == 2){
              text <- paste0("Hüt gits öppis füre Geist: ", menu.vegi, ". E Guete!")
            } else {
              text <- paste0("Hüt gits öppis fürd Lust: ", menu.vegi, ". E Guete!")
            }
          }
        }
      }
  }

#set up Twitter access for user @VegivonRou
#the actual credentials have been removed to make sure that only the real Vegibot tweets
consumer_key <- 
consumer_secret <- 
access_token <- 
access_secret <- 

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#send Tweet
tweet(text)

#save today's menu to the log file
log.df <- data.frame(date = Sys.Date(), vegan = vegan, pacman = pacman, menu = menu.vegi, tweet = text)

write.table(log.df, file = "menu_log.csv", row.names = FALSE, col.names = FALSE,
            append = TRUE, sep = ";")
