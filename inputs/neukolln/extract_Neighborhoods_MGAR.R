library(tidyverse)
library(readxl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

maxcol<-37+4*4
maxcol<-217

df <-
  file.path("raw", "Neukolln population statistics (citizenship - migrant background, gender, age, religion).xlsx") %>%
  read_excel(sheet = "Data Sheet 0") %>%
  select(-"Einwohnerregisterstatistik Berlin (1)") %>%
  select( num_range("X__", 1:maxcol))


df1 <- 
  filter(df, between(row_number(), 14, 17) ) 

df0<-filter(df, row_number() %in% 8:11)
for(i in rev(2:maxcol)) {
  l<-72;r<-1
  df0[r,paste0("X__",i)] <-  df0[r,trimws(paste0("X__",floor((i-2)/l)*l+2))]
  l<-36;r<-2
  df0[r,paste0("X__",i)] <- paste0(trimws(df0[r-1,paste0("X__",i)]),"___", df0[r,trimws(paste0("X__",floor((i-2)/l)*l+2))])
  l<-4;r<-3
  df0[r,paste0("X__",i)] <- paste0(trimws(df0[r-1,paste0("X__",i)]),"___", 
                                   df0[r,trimws(paste0("X__",floor((i-2)/l)*l+2))],"___",
                                   df0[r+1,trimws(paste0("X__",i))])
}
# for(i in rev(2:maxcol)) {
#   l<-36
#   print(paste0("X__",i,"X__",floor((i-2)/l)*l+2))
# }

df0[3,1]<-"area"
names(df1)<-df0[3,]


df3 <-   df1 %>%
  gather(class, var, -area) %>%
  separate(class, into = c("a", "b", "age","religion"), sep = "___") %>%
  mutate(
    age = case_when(
      age == "unter 1 Jahr" ~ "0 bis unter 1",
      age == "80 und mehr" ~ "80 bis unter 120",
      TRUE ~ age
    )
  ) %>%
  separate(age, into = c("age_from", "age_to"), sep = " bis unter ") %>%
  write_csv(file.path("data", "neukolln-by-citizenship-migrantbackground-gender-age-religion.csv"))  
