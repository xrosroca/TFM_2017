#####################################
#               TFM 2016            #
#     Code: measuring_goodness.R    #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)


comparing_times <- read.table("V/comparing_times.csv", sep=";", dec=",", header=T)
comparing_flows <- read.table("V/comparing_flows.csv", sep=";", dec=",", header=T)


A <- matrix(ncol=6, nrow=4)
colnames(A) <- c("NRMSE", "R_squared", "U", "UM", "US", "UC")
rownames(A) <- c("Flow", "Speed", "Travel Times", "Mean")

#######

NRMSE <- function(x,y){
  n <- length(x)
  NRSME <- sqrt(sum((x-y)^2)/n)/(max(y)-min(y))
  return(NRSME)
}

U <- function(x,y) {
  n <- length(x)
  sqrt(sum((y-x)^2)/n)/(sqrt(sum(y^2)/n)+sqrt(sum(x^2)/n))
}

UM <- function(x,y) {
  n <- length(x)
  UM <- n*(mean(y)-mean(x))^2/sum((y-x)^2)
  return(UM)
}


US <- function(x,y) {
  n <- length(x)
  US <- n*(sd(y)-sd(x))^2/sum((y-x)^2)
  return(US)
}


UC <- function(x,y) {
  n <- length(x)
  rho <- cor(y,x)
  UC <- 2*(1-rho)*n*sd(y)*sd(x)/sum((y-x)^2)
  return(UC)
}



#### FLOW


Lm2 <- lm(flow_sim ~ flow_real ,comparing_flows )
SLm2 <- summary(Lm2)

A[1,1] <- NRMSE(comparing_flows$flow_sim, comparing_flows$flow_real)
A[1,2] <- SLm2$r.squared
A[1,3] <- U(comparing_flows$flow_sim, comparing_flows$flow_real)
A[1,4] <- UM(comparing_flows$flow_sim, comparing_flows$flow_real)
A[1,5] <- US(comparing_flows$flow_sim, comparing_flows$flow_real)
A[1,6] <- UC(comparing_flows$flow_sim, comparing_flows$flow_real)


#### SPEED

Lm3 <- lm(speed_sim ~ speed_real ,comparing_flows )
SLm3 <- summary(Lm3)


A[2,1] <- NRMSE(comparing_flows$speed_sim, comparing_flows$speed_real)
A[2,2] <-SLm3$r.squared
A[2,3] <- U(comparing_flows$speed_sim, comparing_flows$speed_real)
A[2,4] <- UM(comparing_flows$speed_sim, comparing_flows$speed_real)
A[2,5] <- US(comparing_flows$speed_sim, comparing_flows$speed_real)
A[2,6] <- UC(comparing_flows$speed_sim, comparing_flows$speed_real)



### TRAVEL TIME

Lm1 <- lm(Sim_ttime ~ Real_ttime ,comparing_times )
SLm1 <- summary(Lm1)

A[3,1] <- NRMSE(comparing_times$Sim_ttime, comparing_times$Real_ttime)
A[3,2] <- SLm1$r.squared
A[3,3] <- U(comparing_times$Sim_ttime, comparing_times$Real_ttime)
A[3,4] <- UM(comparing_times$Sim_ttime, comparing_times$Real_ttime)
A[3,5] <- US(comparing_times$Sim_ttime, comparing_times$Real_ttime)
A[3,6] <- UC(comparing_times$Sim_ttime, comparing_times$Real_ttime)


### mean

A[4,] <- colMeans(A[-4,])