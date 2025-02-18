library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

query2 <- '
SELECT * FROM "public"."BLU"
'

data <- dbGetQuery(con, query2)

library(ggplot2)
library(dplyr)

dataPlot <- data %>% group_by(Karakter) %>%
  summarize (Angka = sum(Angka), .groups='drop')


p <- ggplot(dataPlot, aes(x = Angka,
           y = Karakter))+
  geom_point() +
  xlab("Jumlah") +
  ylab("")+
  scale_x_continuous(labels = function(x) formatC(x,
                                                  format = "f",
                                                  big.mark = ".",
                                                  decimal.mark = ",",
                                                  digits = 0))+
  theme_bw()

# Download the image to a temporary location
# save to a temp file
file <- tempfile( fileext = ".png")
ggsave(file, plot = p, device = "png", dpi = 144, width = 8, height = 8, units = "in" )

## 1st Hashtag
hashtag <- c("ManajemenData","ManajemenDataStatistika", "github","rvest","rtweet", "ElephantSQL", "SQL", "bot", "opensource", "ggplot2","PostgreSQL","RPostgreSQL")

samp_word <- sample(hashtag, 1)

## Status Message

status_details <- paste0(
  Sys.Date(),": Data dalam database adalah ", nrow(data),
  " baris, dengan nilai total :", "\n","\n",
  "⚽ ",dataPlot$Karakter[1], " : ", dataPlot$Angka[1], "\n",
  "🏀 ",dataPlot$Karakter[2], " : ", dataPlot$Angka[2], "\n",
  "🏐 ",dataPlot$Karakter[3], " : ", dataPlot$Angka[3], "\n",
  "🥎 ",dataPlot$Karakter[4], " : ", dataPlot$Angka[4], "\n",
  "\n",
  "\n",
  "#",samp_word)



# Publish to Twitter
library(rtweet)

## Create Twitter token
pangan_token <- rtweet::create_token(
  app = "PanganBOT",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

## Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  media = file,
  token = pangan_token
)

on.exit(dbDisconnect(con))
