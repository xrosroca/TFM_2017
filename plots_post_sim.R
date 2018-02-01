#####################################
#               TFM 2016            #
#     Code: plots_post_sim.R        #
#     Author: Xavier Ros Roca       #
#####################################


library(dplyr)
library(stringr)

loc_path <- "05_Models/Calibration/"

 
A <- (read.table(paste0(loc_path, "ofval.txt"), header=F))
colnames(A) <- "ofval"
A$N <- 1:nrow(A)
 
 
B <- read.table(paste0(loc_path, "R.txt"), header=F)
colnames(B) <- paste0("corr_", c("flow", "speed", "time"))
B$N <- 1:nrow(B)

TRmin = c(85, 2, 0.7, 0.2, 0.6, 0.3, 0.5, 0.7, 2, 1, 0.2, 0.2)
TRmax = c(120, 10, 1.4, 1.0, 2.0, 1.0, 1.8, 2.2, 10, 4, 1.5, 0.8)

TR <- data.frame(cbind(TRmin, TRmax))
EXP <- expand.grid(N = 1:nrow(A), NT =1:nrow(TR))

TR <- TR %>% mutate(NT = 1:nrow(TR)) %>% 
  right_join(EXP, by="NT")

C <- read.table(paste0(loc_path, "P.txt"), header=F)
params <- c("speed M",
            "speed Std",
            "Acceptance M", 
            "Acceptance Std",
            "clearance M",
            "clearance Std",
            "ReactionTime",
            "ReactionTimeStop",
            "Margin for Overt. M", 
            "Margin for Overt. Std",
            "Gap M", 
            "Gap Std")

colnames(C) <- params
C$N <- 1:(nrow(C))


D <- C

for(i in 1:12) {
  for(j in 1:nrow(D)) {
    D[j,i] <- 10*(D[j,i]-TRmin[i])/(TRmax[i]-TRmin[i])
  }
  
}
names(D) <- paste0("D_", names(C))
Past <- c(102.173295,	
				8.540214,	
				0.688124,	
				0.329139,	
				1.368162,	
				0.473820,	
				1.077367,	
				1.132899,	
				5.529925,	
				3.490986,	
				0.583857,	
				0.246785)	
            
PastN <- Past
for(i in 1:12) {
    PastN[i] <- 10*(Past[i]-TRmin[i])/(TRmax[i]-TRmin[i])
}


E <- D[,1:12]

for(j in 1:nrow(D)) {
  
  for(i in 1:12) {
    
    E[j,i] <- D[j,i]-PastN[i]
  }
  
}
names(E) <- paste0("E_", names(C))

E$norm <- apply(E, 1, function(x) {norm(x, type="2")})

E <- cbind(E$norm, N = 1:nrow(E))




#### 
write.table(A, "A.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(B, "B.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(C, "C.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(D, "D.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(D, "D.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(E, "E.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)
write.table(TR, "TR.csv", row.names = FALSE, sep=";", dec=",", quote=FALSE)