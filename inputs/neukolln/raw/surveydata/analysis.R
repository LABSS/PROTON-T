library(foreign)
# read data from SPSS
data <- read.spss("EVS_ABM1.sav", to.data.frame=TRUE)
warnings()
write.csv2(x = data,file = "germany.csv")

