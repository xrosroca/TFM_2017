#####################################
#               TFM 2016            #
#     Code: reading_data_BT.R       #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

LF <- list.files(path="02_Data/raw_data/blip/")

LF

BT_df <- data.frame(Timestamp = NA ,        
                    StartPoint = NA,
                    StartPointName = NA,
                    EndPoint = NA,
                    EndPointName = NA,
                    MinMeasuredTime = NA,
                    MaxMeasuredTime = NA,
                    AvgMeasuredTime = NA,
                    MedianMeasuredTime = NA,
                    SampleCount = NA,
                    AccuracyLevel = NA,
                    ConfidenceLevel = NA)

# i = 1
for(i in 1:length(LF)) {
  file <- paste0("02_Data/raw_data/blip/", LF[i])
  a <- data.frame(read.csv(file, header = T, sep=",", stringsAsFactors = FALSE))

  BT_df <- rbind(BT_df, a)

}

BT_df <- unique(BT_df)

BT_df <- BT_df[-1,]
names(BT_df)[1] <- "DateTime"
BT_df$StartPoint <- BT_df$EndPoint <- NULL
names(BT_df)[2] <- "StartPoint"
names(BT_df)[3] <- "EndPoint"


head(BT_df)
BT_df$DateTime <- str_replace_all(BT_df$DateTime, "mar", "03")
BT_df$DateTime <- str_replace_all(BT_df$DateTime, "apr", "04")
BT_df$DateTime <- str_replace_all(BT_df$DateTime, "maj", "05")


BT_df$Date <- as.Date(substr(BT_df$DateTime, 1, 10))

BT_df <- BT_df[which(BT_df$Date %in% c(as.Date("2015-03-21"), as.Date("2015-03-28"), as.Date("2015-03-19"), as.Date("2015-03-26"))),]

BT_df$StartPoint <- as.character(BT_df$StartPoint) 
BT_df$EndPoint <- as.character(BT_df$EndPoint) 

BT_df$Year <- as.numeric(substr(BT_df$DateTime, 1, 4))
BT_df$Month <- as.numeric(substr(BT_df$DateTime, 6, 7))
BT_df$Day <- as.numeric(substr(BT_df$DateTime, 9, 10))
BT_df$Hour <- as.numeric(substr(BT_df$DateTime, 12, 13))
BT_df$Minute <- as.numeric(substr(BT_df$DateTime, 15, 16))


BT_df$DateTime <- as.POSIXct(BT_df$DateTime, format= "%Y-%m-%d %H:%M:%S") 
BT_df$Start_ID <- paste0("BT/", BT_df$StartPoint)
BT_df$End_ID <- paste0("BT/", BT_df$EndPoint)
summary(BT_df)

table(BT_df$StartPoint, BT_df$EndPoint)

loc <- read.csv("place.csv", sep=";", header=T, dec=",", stringsAsFactors = FALSE)


#### aggregation #####

gap <- 5
u <- 0:59

int = c(0)

for(j in 1:(60/gap)) {
  v <- rep(gap*(j-1), gap)
  int <- c(int, v)
} 

int <- int[-1]

DF_aux <- data.frame(Minute = u, Int = int)

###############

BT_df_agg <- BT_df %>% 
  left_join(DF_aux, by="Minute") %>% 
  rename(index = Int) %>% 
  group_by(Start_ID, End_ID, Date, Hour, index) %>%
  summarise(DateTime = min(DateTime, na.rm=T),
            MinMeasuredTime = min(MinMeasuredTime, na.rm = T),
            MaxMeasuredTime = max(MaxMeasuredTime, na.rm = T),
            AvgMeasuredTime = sum(AvgMeasuredTime*SampleCount, na.rm=T)/sum(SampleCount, na.rm=T), 
            MedianMeasuredTime = median(MedianMeasuredTime),
            SampleCount = sum(SampleCount) ) %>%
  rename(Minute = index) %>% 
  data.frame()

BT_df_agg[which(is.na(BT_df_agg$AvgMeasuredTime)),]$AvgMeasuredTime <- 0

BT_df2 <- BT_df_agg

####### Fusion and writing CSV ##########

write.table(BT_df2, "BT_data.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
save.image("02_Data/Clean_data_BT_16112016.RData")