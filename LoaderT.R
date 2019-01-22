library(ggplot2)
library(tidyverse)
theme_set(theme_bw())
library(poweRlaw)
library(magrittr)

name<-"PROTON-T testing-output-fat-table"

set_project_wd <- function(folder_nm){
  if(Sys.info()[[4]]=="mylaptopname") setwd(paste0('~/workspace/',folder_nm))
  else setwd(paste0('D:/workspace/',folder_nm))
}

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

f <- paste0( "./outputs/",name, ".csv") 

testload <-
readLines(f) %>%
gsub("\\\"\\\"\\\"", "", .) %>%
gsub("\\\"", "", .) %>%
read.csv(text=., skip=6, header=TRUE) 

dput(names(testload)) # to correct
names(testload) <-
  c("X.run.number.", "citizens.per.community", "initial.radicalized", 
"alpha", "radicalization.threshold", "num.communities", "activity.radius", 
"work.socialization.probability", "activity.value.update", "website.access.probability", 
"community.side.length", "X.step.", "weekday", "X.word..ticks.mod.24...00.", 
"count.citizens.with...recruited...", "count.citizens.with...risk...radicalization.threshold..", 
"X..age...of.citizens", "risk", "citizens.opinions", 
"citizens.occupations.hist")

risks <-
  testload %>%
mutate(
  extr_risk = risk %>%
  str_extract_all("[-+]?[0-9]*\\.?[0-9]+") %>%       
    map(as.numeric) 
  ) %>%
  unnest(extr_risk) %>%
  select(X.run.number., X.step., extr_risk)

# all the risk histograms
risks %>%
  ggplot(aes(x = extr_risk)) + geom_histogram() + coord_flip() +
  facet_grid(~ X.step. )



