#####################################
#               TFM 2016            #
#     Code: writing_trueData.R      #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

source("01_Codes/reading_data_RADAR.R")

##### Input for the Real Data State ####

DAY <- as.Date("2015-03-19")
Hmin <- "10:30:00"
Hmax <- "11:30:00"

## flow ###

min_H <- as.POSIXct(paste0(DAY, " ", Hmin))
max_H <- as.POSIXct(paste0(DAY, " ", Hmax))

D5 <- D4 %>% 
  filter(DateTime >= min_H & DateTime < max_H) %>% 
  left_join(select(loc, id, Aim_ID), by = "id") %>% 
  data.frame()

Aux_int <- unique(D5[,c("Hour", "Minute")])
Aux_int <- Aux_int[order(Aux_int$Hour, Aux_int$Minute),]
Aux_int$Int <- 1:nrow(Aux_int)

D5 <- D5 %>% left_join(Aux_int, by = c("Hour", "Minute"))

D5 <- D5[order(D5$Aim_ID, D5$Int),]

D5$flow <- round(D5$flow)
D5$speed <- round(D5$speed, 4)

D6 <- select(D5, Aim_ID, Int, flow, speed)

write.table(D6, "05_Models/Calibration/scenarioInfo/trueData.txt", sep="\t", quote = FALSE, row.names = FALSE, col.names = FALSE)