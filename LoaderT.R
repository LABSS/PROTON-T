library(ggplot2)
library(tidyverse)
theme_set(theme_bw())
library(poweRlaw)
library(magrittr)


name<-"test.labss-simul.100"

#setwd("/Users/paolucci/Dropbox/MarioJordiFran/Experiments-Jordi")
#setwd("/Users/mariopaolucci/Dropbox/MarioJordiFran/")
# find . -maxdepth 1 -type f  \( -name "*.csv" -a ! -name  "*100Steps*" \)  -exec ls {} \;

# this removes all the headers. But I need them and I'm too lazy to re-write them.
# tail -n +8 {} >> collate \;
# so let's clean the joint file
# rm collate
# then add all the files except one. In this case I leave out the 100 steps because it has a easily recognizable name
# find . -maxdepth 1 -type f  \( -name "*.csv" -a ! -name  "*100Steps*" -a ! -name  "*collate*" \)  -exec tail -q -n +8 {} >> collate \;
# then I add the last one changing the name of the accumulator
# cat *100S* collate > collate.csv

f <- paste0( "./outputs/",name, ".csv") 

f <- paste0( "/Users/paolucci/" , name, ".csv") 

testload <-
readLines(f) %>%
gsub("\\\"\\\"\\\"", "", .) %>%
gsub("\\\"", "", .) %>%
read.csv(text=., skip=6, header=TRUE) 

names(testload) <-
  c("X.run.number.", "citizens.per.community", "initial.radicalized", 
"alpha", "radicalization.threshold", "num.communities", "activity.radius", 
"work.socialization.probability", "activity.value.update", "website.access.probability", 
"community.side.length", "X.step.", "weekday", "X.word..ticks.mod.24...00.", 
"count.citizens.with...recruited...", "count.citizens.with...risk...radicalization.threshold..", 
"X..age...of.citizens", "risk", "citizens.opinions", 
"citizens.occupations.hist")

transmute(testload, extr = as.numeric(
  str_extract_all(risk, "\\d+"))) 

summary(as.vector(
  map(
    str_extract_all(testload$risk[93], " [-+]?[0-9]*\\.?[0-9]+"),
    as.numeric)[[1]]
))


dput(names(testload)) # to correct

# setnames(testload,
#          c("X.run.number.",  "sawoff.zipf.", "read.cap.", "age.weight.", "random.seed.", "X.step.", "sum..quality...count.my.in.read.prs..of.papers", "sum..quality...count.my.in.read.reps..of.papers", "sum..quality...2...count.my.in.read.prs..of.papers", "sum..quality...2...count.my.in.read.reps..of.papers",  "count.papers.with..mistaken.."),
#          c("run.number",      "sawoff.zipf", "read.cap",  "age.weight",  "random.seed",  "step",  "massqPR",                                         "massqREP",                                         "massqPR2",                                           "massqREP2",                                            "mistakes")
# )

table(testload[,.(max(X.step.)),X.run.number.])

#
countsim<-testload[step>0, 
                   .("PRminusREP"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP > 0, 1,  -1)),
                     "PRprevailing"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP > 0, 1,  0)),
                     "REPprevailing"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP < 0, 1,  0))   ),
                     by=.(step,age.weight)]

#testload[step>0,massqPR - massqREP]



#--------

#stopifnot(FALSE)

# countsim<-testload[step>0,
#                    .("PRminusREP"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP > 0, 1,  -1)),
#                      "PRprevailing"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP > 0, 1,  0)),
#                      "REPprevailing"=sum(ifelse(massqPR+massqObsPR - massqREP-massqObsREP < 0, 1,  0))   ),
#                      by=.(step,age.weight)]
# 
# ggp<-ggplot(data=
#               countsim,
#             aes(x = step,y = REPprevailing
# #                 , group=run.number )
# ))  +
#   geom_line() +
# #  geom_line(aes(x = step,y = REPprevailing, color ="red")) +
#  # scale_color_distiller(palette = "Greens") +
#   facet_wrap(  ~  age.weight   )  + ylim(0, countsim[,.N] / 2) +
#   #theme(legend.position="none") + ylab("Difference in quality (PR - REP)") +
#   ggtitle("Number of experiments favoring reputation") +
#   ylab ("Experiments")
# ggp
# 
# #ggsave(paste(name,"_diff_sim.png", sep=""), units="cm", width = 10, height = 5, scale = 2.5)
# 
# stop
# 
# ggp<-ggplot(data=
#               testload[step<=60 ],
#             aes(x=step,y=(massqPR+massqObsPR - massqREP-massqObsREP), group=run.number )
# )  +
#   geom_line() +
#   facet_wrap(  ~ excellence.criterion  , scales = "free")  +
#   scale_color_distiller(palette = "Greens") +
#   facet_wrap(  ~  age.weight   , scales = "free")  +
#   	#scale_y_log10() +
#   #theme(legend.position="none") + ylab("Difference in quality (PR - REP)") +
#   ggtitle("Difference between peer review and reputation.")
# ggp
# #ggsave(paste(name,"_sim.png", sep=""), units="cm", width = 10, height = 5, scale = 2.5)
# 
# 
# 
# 
# 
# #_------- a better calculation for the acceptance rate:
# # testload[step==21, .(mean(count.papers.with..published..)/21),by=excellence.criterion]
# # excellence.criterion        V1
# # 1:    exponentialrandom  71.66667
# # 2:                 zipf 125.40476
# # 
# # 
# # #369 per 0.073 per PR:
# # mean(
# # testload[step==44, .(mean(count.papers.with..published..), unreadPR, unreadREP),by=.(excellence.criterion, age.weight, run.number)][,V1]
# # )
# # 
# # I interpolate between 
# 
