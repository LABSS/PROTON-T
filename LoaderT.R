library(ggplot2)
library(tidyverse)
theme_set(theme_bw())
library(poweRlaw)
library(magrittr)

name<-"PROTON-T testing-output-fat-table"

# set_project_wd <- function(folder_nm){
#   if(Sys.info()[[4]]=="mylaptopname") setwd(paste0('~/workspace/',folder_nm))
#   else setwd(paste0('D:/workspace/',folder_nm))
# }

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

f <- paste0( "./outputs/",name, ".csv") 
f <- "/Users/paolucci/Downloads/table-output-dens.csv"


testload <-
readLines(f) %>%
gsub("\\\"\\\"\\\"", "", .) %>%
gsub("\\\"", "", .) %>%
read.csv(text=., skip=6, header=TRUE) 

dput(names(testload)) # to correct
names(testload) <-
  c("run_number", "total.citizens", "police.density", "alpha", 
    "activity_radius", "community.side.length", "recruit.hours.threshold", 
    "activity.debug.", "work.socialization.probability", "police.interaction", 
    "test.location.type", "cpo.numerousness", "radicalization.threshold", 
    "activity.value.update", "police.distrust.effect", "scenario", 
    "website.access.probability", "step", "count.citizens.with.....shape...of.locations.here.....mosque....", 
    "count.citizens.with.....shape...of.locations.here.....public.space....", 
    "count.citizens.with.....shape...of.locations.here.....coffee.......count.locations.with...shape...coffee..", 
    "recruited", "at_risk", 
    "max..hours.with.recruiter..of.citizens", 
    "mean_distrust", 
    "mean_nonintegration", 
    "mean_crd", 
    "std_distrust", 
    "std_nonintegration", 
    "std_crd", 
    "mean...propensity...of.citizens", "mean...risk...of.citizens", 
    "standard.deviation...propensity...of.citizens", "standard.deviation...risk...of.citizens", 
    "count_links")

opinions <- testload %>%
  gather("type","opinion", c(    "mean_distrust", 
    "mean_nonintegration", 
    "mean_crd")) 

unique(testload$run_number)
hist(testload$step)

# recruits
ggp<-ggplot(data=
              testload,
            aes(x=step,y=recruited, group= run_number , color=run_number) 
)  +  geom_line()
ggp

# links
ggp<-ggplot(data=
              testload,
            aes(x=step,y=count_links, group= run_number , color=run_number) 
)  +  geom_line()
ggp

# opinions
ggp<-ggplot(data=
  opinions,
  aes(x=step,y=opinion, group=type, color=type ) ) + 
  geom_line() + 
  facet_wrap( ~ run_number)  
ggp


ggp<-ggplot(data=
              testload,
            aes(x=step,y=count_links, group= run_number , color=run_number) 
)  +  geom_line() +
facet_wrap(  ~ activity_radius )  



#scale_color_distiller(palette = "Greens") + 
#facet_wrap(  ~  age.weight   , scales = "free")  + 
#scale_y_log10() +
#theme(legend.position="none") +
#ylab("Difference in quality (PR - REP)") + 
#scale_y_continuous(labels = scientific)
# ggtitle("Difference between peer review and reputation.")






