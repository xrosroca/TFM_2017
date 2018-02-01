#####################################
#               TFM 2016            #
#     Code: writing_trueTimes.R     #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

source("01_Codes/reading_data_BT.R")

##### Input for the Real Data State ####

DAY <- as.Date("2015-03-19")
Hmin <- "10:30:00"
Hmax <- "11:30:00"


## flow ###

min_H <- as.POSIXct(paste0(DAY, " ", Hmin))
max_H <- as.POSIXct(paste0(DAY, " ", Hmax))

D5 <- BT_df2 %>% 
  filter(DateTime >= min_H & DateTime < max_H) %>% 
  left_join(select(loc, id, Aim_ID), by = c("Start_ID" = "id")) %>% 
  rename(Start = Aim_ID) %>% 
  left_join(select(loc, id, Aim_ID), by = c("End_ID" = "id")) %>% 
  rename(End = Aim_ID) %>% 
  data.frame()

Aux_int <- unique(D5[,c("Hour", "Minute")])
Aux_int <- Aux_int[order(Aux_int$Hour, Aux_int$Minute),]
Aux_int$Int <- 1:nrow(Aux_int)

D5 <- D5 %>% left_join(Aux_int, by = c("Hour", "Minute"))


D6 <- select(D5, Start, End, Int, SampleCount, MinMeasuredTime, MaxMeasuredTime, AvgMeasuredTime, MedianMeasuredTime)
D6 <- D6[-which(D6$Start == 68129 & D6$End == 68130),]
D6 <- D6[-which(D6$Start == 68130 & D6$End == 68131),]

D6 <- D6[order(D6$Start, D6$End, D6$Int),]


write.table(D6, "05_Models/Calibration/scenarioInfo/trueTimes.txt", sep="\t", quote = FALSE, row.names = FALSE, col.names = FALSE)