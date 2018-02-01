#####################################
#               TFM 2016            #
#     Code: reading_data_RADAR.R    #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

##################

A <- data.frame(read.csv("02_Data/raw_data/sensordata_2015_03-2015_05.csv", sep=";", header = T, stringsAsFactors = FALSE ))
str(A)


#######################################################


A$Date <- as.Date(substr(A$timestamp, 1, 10))

D <- A[which(A$Date %in% c(as.Date("2015-03-21"), 
                           as.Date("2015-03-28"), 
                           as.Date("2015-03-19"), 
                           as.Date("2015-03-26"))),]

D$Year <- as.numeric(substr(D$timestamp, 1, 4))
D$Month <- as.numeric(substr(D$timestamp, 6, 7))
D$Day <- as.numeric(substr(D$timestamp, 9, 10))
D$Hour <- as.numeric(substr(D$timestamp, 12, 13))
D$Minute <- as.numeric(substr(D$timestamp, 15, 16))
D$Date <- as.Date(substr(D$timestamp, 1, 10))
D$timestamp <- as.POSIXct(D$timestamp)

names(D)[which(names(D) == "timestamp")] <- "DateTime"
names(D)[which(names(D) == "sensorId")] <- "id"
names(D)[which(names(D) == "totalFlow")] <- "flow"

D$type <- "R"

D <- D %>% 
  select(id, type, DateTime, Date, Hour, Minute, flow, speed)

D$speed <- 3.6*D$speed
D$id <- paste0("R/", D$id)

str(D)
D <- unique(D)

###### AGGREGATION ####

gap <- 5
u <- 0:59

int = c(0)

for(j in 1:(60/gap)) {
  v <- rep(gap*(j-1), gap)
  int <- c(int, v)
} 

int <- int[-1]


DF_aux <- data.frame(Minute = u, Int = int)

#######

D$SF <- D$speed*D$flow

D3 <- D %>%
  left_join(DF_aux, by="Minute") %>% 
  rename(index = Int) %>% 
  group_by(id, type, Date, Hour, index) %>%
  summarise(DateTime = min(DateTime),
            flow = mean(flow, na.rm = T),
            flow_sum = sum(flow, na.rm=T),
            speed = mean(SF/flow_sum, na.rm=T) ) %>%
  rename(Minute = index) 


D3$flow_sum <- NULL

D4 <- D3[which(D3$Hour %in% 6:19),]

D4 <- D4[,c(1:2, 6, 3:5, 7:8 )]


####### Fusion and writing CSV ##########

write.table(D4, "radar_data.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
save.image("02_Data/Clean_data_16112016.RData")