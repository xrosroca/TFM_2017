#####################################
#               TFM 2016            #
#     Code: comparing_sim_real.R    #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)
library(RSQLite)


con <- dbConnect(drv=RSQLite::SQLite(), dbname='05_Models/Calibration/Model_traffic_state_21_march_prova1.sqlite')


loc <- read.csv("place.csv", sep=";", header=T, dec=",", stringsAsFactors = FALSE)


#### trueData (speed and flow)

trueData <- read.table("05_Models/Calibration/scenarioInfo/trueData.txt", sep="\t")
names(trueData) <- c("Aim_ID", "Int", "flow", "speed")

sqlQuery <- 'SELECT oid + 0.0 as oid,  ent +0.0 as ent, flow + 0.0 as flow, speed + 0.0 as speed FROM MIDETEC WHERE did = 10 and sid = 1 and ent <> 0 order by oid, ent;';
simData <- dbGetQuery(con, sqlQuery)

simData <- simData[which(simData$oid %in% loc[which(loc$Type == "R"),]$Aim_ID),]

names(simData) <- names(trueData)

DF <- trueData %>% 
  left_join(simData, by=c("Aim_ID", "Int")) %>% 
  rename(flow_real = flow.x,
         flow_sim = flow.y,
         speed_real = speed.x,
         speed_sim = speed.y) 


######


library(dplyr)
DF <- left_join(DF, select(loc, Aim_ID, id))

DF$COR_speed <- cor(DF$speed_real, DF$speed_sim)
DF$COR_flow <- cor(DF$flow_sim, DF$flow_real)

write.table(DF,  "comparing_flows.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE )


trueTimes <- read.table("05_Models/Calibration/scenarioInfo/trueTimes.txt", sep="\t")
names(trueTimes) <- c("Start", 
                      "End", 
                      "Int", 
                      "SampleCount", 
                      "MinMeasuredTime", 
                      "MaxMeasuredTime", 
                      "AvgMeasuredTime", 
                      "MedianMeasuredTime")

BT <- read.table("05_Models/Calibration/scenarioInfo/BT.txt")

simTimes_all <- data.frame(start_point = NA, end_point = NA, idveh=NA, time_ini=NA, time_fin=NA, ttime=NA, Int=NA)
for (i in 1:nrow(BT)) {
  sqlQuery <- paste0('select A.oid + 0.0 as start_point, B.oid + 0.0 as end_point, A.idveh + 0.0 as idveh, A.timedet + 0.0 as time_ini, B.timedet + 0.0 as time_fin, B.timedet - A.timedet as ttime from (select * from DETEQUIPVEH where oid = ',
                     BT[i,1],  
                     ' and did = 10) A inner join (select * from DETEQUIPVEH where oid = ',
                     BT[i,2], 
                     ' and did = 10) B on A.idveh = b.idveh')
  simTimes <- dbGetQuery(con, sqlQuery)
  
  
  simTimes$Int <- ifelse(simTimes$time_ini < 38100, 1,
                         ifelse(simTimes$time_ini < 38400, 2,
                                ifelse(simTimes$time_ini < 38700, 3, 
                                       ifelse(simTimes$time_ini < 39000, 4,
                                              ifelse(simTimes$time_ini < 39300, 5, 
                                                     ifelse(simTimes$time_ini < 39600, 6,
                                                            ifelse(simTimes$time_ini < 39900, 7,
                                                                   ifelse(simTimes$time_ini < 40200, 8,
                                                                          ifelse(simTimes$time_ini < 40500, 9,
                                                                                 ifelse(simTimes$time_ini < 40800, 10,
                                                                                        ifelse(simTimes$time_ini < 41100, 11, 12)))))))))))
  
  simTimes_all <- rbind(simTimes_all, simTimes)
  
}

simTimes_all <- simTimes_all[-1,]

simTimes_DT <- simTimes_all %>% 
  group_by(start_point, end_point, Int) %>% 
  summarise(N = length(start_point),
            Min_ttime = min(ttime, na.rm=T),
            Max_ttime = max(ttime, na.rm=T),
            Avg_ttime = mean(ttime, na.rm=T),
            Median_ttime = median(ttime, na.rm=T)) %>% 
  data.frame()


simTimes <- simTimes_DT[order(simTimes_DT$start_point, simTimes_DT$end_point, simTimes_DT$Int),]

names(simTimes) <- names(trueTimes)

left_join(select(trueTimes, Start, End, Int, AvgMeasuredTime),
          select(simTimes, Start, End, Int, AvgMeasuredTime), 
          by = c("Start", "End", "Int"))

DF_times <- trueTimes %>% 
  select(Start, End, Int, AvgMeasuredTime) %>% 
  left_join(select(simTimes, Start, End, Int, AvgMeasuredTime), by = c("Start", "End", "Int")) %>% 
  rename(Real_ttime = AvgMeasuredTime.x, Sim_ttime = AvgMeasuredTime.y) %>% 
  data.frame()

DF_times <- DF_times %>% 
  left_join(select(loc, Aim_ID, id), by = c("Start" = "Aim_ID")) %>% 
  rename(id_start = id) %>% 
  left_join(select(loc, Aim_ID, id), by = c("End" = "Aim_ID")) %>% 
  rename(id_end = id)

DF_times$COR_time <- cor(DF_times$Real_ttime, DF_times$Sim_ttime)

write.table(DF_times, "comparing_times.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)