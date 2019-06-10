library(tidyverse)
library(readxl)


gender_mod <- 1.0     # multiplier - 2 means twice the women
migrant_mod <- 1.0 # 2 means twice the immigrants

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

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
  separate(class, into = c("migrant?", "male?", "age","muslim?"), sep = "___") %>%
  separate(area, into = c("area_code", "area_name"), sep = 5) %>%
  mutate(
    area_code = as.numeric(area_code %>% map(
      function(x){substr(x,4,4)}
      # ~ substr(.,4,4)
    )),
    value = as.numeric(
      case_when(
      var == "-" ~ "0",
      TRUE ~ var)
    ),
    age2 = case_when(
      age == "unter 1 Jahr" ~ "0 bis unter 1",
      age == "80 und mehr" ~ "80 bis unter 120",
      TRUE ~ age
    ),
    "migrant?" = recode( `migrant?` ,
        "Ausländer" = "true", 
        "Deutsche mit Migrationshintergrund" = "true",
        "Deutsche ohne Migrationshintergrund" = "false" 
      ),
    "male?" = recode( `male?` ,
        "männlich" = "true", 
        "weiblich" = "false" 
      ), 
    "muslim?" = recode( `muslim?` ,
        "Evangelische Kirchen"       = "false",
        "Römisch-katholische Kirche" = "false",
        "ohne Angabe"                = "true", 
        "sonstige/ohne Angabe"       = "true"
      )     
  ) %>%
  select(-age,-var) %>%
  group_by(area_code, area_name, `migrant?`, `male?`, `muslim?`, age2) %>% 
  summarise_all(funs(sum)) %>%
  separate(age2, into = c("age_from", "age_to"), sep = " bis unter ") %>%
  mutate(
    duration = as.numeric(age_to) - as.numeric(age_from),
    age_to = as.numeric(age_to) - 1
  ) %>%
  unite(age,  c("age_from", "age_to")) %>%
  mutate(
    age = age %>%
      str_extract_all("\\d+") %>%
      map(as.numeric) %>%
      map((lift(seq))
  )
  ) %>%
  mutate (      
    value = as.numeric(
      case_when(
        `male?` == "false" ~ gender_mod * value,
        TRUE  ~  value
      ))
  ) %>%
  mutate (      
    value = as.numeric(
      case_when(
        `migrant?` == "true" ~ migrant_mod * value,
        TRUE  ~  value
      ))
  )   


df4 <- df3 %>%
  ungroup() %>%
  mutate(value = as.numeric(value) / duration) %>%
  unnest(age) %>%
  filter(age>15)

df4 %>%
  select(area_code, "migrant?","male?","muslim?", age,value) %>%
  write_csv(file.path("data", "neukolln-by-citizenship-migrantbackground-gender-religion-age.csv"))  

df4 %>%
  select(area_code, area_name, value) %>%
  group_by(area_code, area_name)      %>%
  summarize(sum(value))               %>%
  write_csv(file.path("data", "neukolln-totals.csv"))  
