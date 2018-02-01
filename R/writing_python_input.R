#####################################
#               TFM 2016            #
#     Code: writing_python_input.R  #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

source("01_Codes/reading_data_RADAR.R")

##### Input for the Real Data State ####

DAY <- as.Date("2015-03-19")

## 1. flow ###

# main flow (section 22727)
loc <- read.csv("place.csv", sep=";", header=T, dec=",", stringsAsFactors = FALSE)

Aux <- D4[which(D4$id == "R/1213" & D4$Date == DAY),c("DateTime", "flow")]

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$Section <- 22727

input_flow <- select(Aux, time, Section, flow)

# 1209-1212 (section 878)

Aux_1209 <- D4[which(D4$id == "R/1209" & D4$Date == DAY),c("DateTime", "flow")]
Aux_1212 <- D4[which(D4$id == "R/1212" & D4$Date == DAY),c("DateTime", "flow")]

Aux <- left_join(Aux_1212, Aux_1209, by = "DateTime") 
Aux$flow <- round(Aux$flow.y - Aux$flow.x)
Aux$flow[which(Aux$flow < 0)] <- 0

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$Section <- 878

input_flow <- left_join(input_flow, select(Aux, time, Section, flow), by="time")


# 1200 - 1203 (section 23470)

Aux_1200 <- D4[which(D4$id == "R/1200" & D4$Date == DAY),c("DateTime", "flow")]
Aux_1203 <- D4[which(D4$id == "R/1203" & D4$Date == DAY),c("DateTime", "flow")]

Aux <- left_join(Aux_1203, Aux_1200, by = "DateTime") 
Aux$flow <- round(Aux$flow.y - Aux$flow.x)
Aux$flow[which(Aux$flow < 0)] <- 0

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$Section <- 23470

input_flow <- left_join(input_flow, select(Aux, time, Section, flow), by="time")



# 1196 - 1194 (section 66855)

Aux_1196 <- D4[which(D4$id == "R/1196" & D4$Date == DAY),c("DateTime", "flow")]
Aux_1194 <- D4[which(D4$id == "R/1194" & D4$Date == DAY),c("DateTime", "flow")]

Aux <- left_join(Aux_1194, Aux_1196, by = "DateTime") 
Aux$flow <- round(Aux$flow.y - Aux$flow.x)
Aux$flow[which(Aux$flow < 0)] <- 0

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$Section <- 66855

input_flow <- left_join(input_flow, select(Aux, time, Section, flow), by="time")


write.table(input_flow, "02_Data/traffic_state_data_flow_19_march.csv", quote=FALSE, sep=",", row.names=FALSE, col.names = FALSE)




############# Turns #################

### 1r 66982 = 66684 + 387
Aux  <- D4[which(D4$id == "R/1204" & D4$Date == DAY),c("DateTime", "flow")]
Aux2 <- D4[which(D4$id == "R/1203" & D4$Date == DAY),c("DateTime", "flow")]
Aux3 <- D4[which(D4$id == "R/1205" & D4$Date == DAY),c("DateTime", "flow")]

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$DateTime <- NULL
Aux2$time <- substr(Aux2$DateTime, 12, 20)
Aux2$DateTime <- NULL
Aux3$time <- substr(Aux3$DateTime, 12, 20)
Aux3$DateTime <- NULL

Aux <- full_join(Aux, Aux2, by="time")
Aux <- full_join(Aux, Aux3, by="time")
names(Aux)[4] <- "flow.z"

Aux$flow_sum <- Aux$flow.y + Aux$flow.z
Aux$T1 <- round((Aux$flow.y/Aux$flow_sum)*100)
Aux$T2 <- round((Aux$flow.z/Aux$flow_sum)*100)

Aux$Main <- Aux$MAIN <- 66982
Aux$Main2 <- 66684
Aux$Out <- 387

input_turns <- select(Aux, time, Main, Main2, T1, MAIN, Out, T2)


### 2n 9866	= 9483 + 2330
Aux  <- D4[which(D4$id == "R/1196" & D4$Date == DAY),c("DateTime", "flow")]
Aux2 <- D4[which(D4$id == "R/1194" & D4$Date == DAY),c("DateTime", "flow")]
Aux3 <- D4[which(D4$id == "R/1197" & D4$Date == DAY),c("DateTime", "flow")]

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$DateTime <- NULL
Aux2$time <- substr(Aux2$DateTime, 12, 20)
Aux2$DateTime <- NULL
Aux3$time <- substr(Aux3$DateTime, 12, 20)
Aux3$DateTime <- NULL

Aux <- full_join(Aux, Aux2, by="time")
Aux <- full_join(Aux, Aux3, by="time")
names(Aux)[4] <- "flow.z"

Aux$flow_sum <- Aux$flow.y + Aux$flow.z
Aux$T1 <- round((Aux$flow.y/Aux$flow_sum)*100)
Aux$T2 <- round((Aux$flow.z/Aux$flow_sum)*100)

Aux$Main <- Aux$MAIN <- 9866
Aux$Main2 <- 9483
Aux$Out <- 2330

input_turns <- left_join(input_turns, select(Aux, time, Main, Main2, T1, MAIN, Out, T2), by="time")



### 3r  66785	= 14487 + 66881
Aux  <- D4[which(D4$id == "R/1187" & D4$Date == DAY),c("DateTime", "flow")]
Aux2 <- D4[which(D4$id == "R/1178" & D4$Date == DAY),c("DateTime", "flow")]

Aux$time <- substr(Aux$DateTime, 12, 20)
Aux$DateTime <- NULL
Aux2$time <- substr(Aux2$DateTime, 12, 20)
Aux2$DateTime <- NULL


Aux <- full_join(Aux, Aux2, by="time")

Aux$flow.z <- Aux$flow.x - Aux$flow.y
Aux$flow.z[which(Aux$flow.z  < 0) ] <- 0

Aux$flow_sum <- Aux$flow.y + Aux$flow.z
Aux$T1 <- round((Aux$flow.y/Aux$flow_sum)*100)
Aux$T2 <- round((Aux$flow.z/Aux$flow_sum)*100)

Aux$Main <- Aux$MAIN <- 66785
Aux$Main2 <- 14487
Aux$Out <- 66881

input_turns <- left_join(input_turns, select(Aux, time, Main, Main2, T1, MAIN, Out, T2), by="time")


write.table(input_turns, "02_Data/traffic_state_data_turns_19_march.csv", quote=FALSE, sep=",", row.names=FALSE, col.names = FALSE)