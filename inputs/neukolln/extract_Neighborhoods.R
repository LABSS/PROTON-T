library(tidyverse)
library(readxl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

df <-
  file.path("raw", "ABMstuff.xlsx") %>%
  read_excel(sheet = "Setup-Landscape") %>%
  gather(Area, value, - Factor) %>%
  mutate(
    area = Area %>%
    str_extract("\\d") %>%
      map(as.numeric) 
  ) %>%
  mutate(
      factor =
        Factor %>%
      gsub(pattern = "%", replacement = " percent", .) %>%
        gsub(pattern = "#", replacement = " num", .)  %>%
        gsub(pattern = "\\+", replacement = " on", .) %>%
        trimws()
  ) %>%
  unnest(area) %>%
  select(factor, area, value) %>%
  write_csv(file.path("data", "neighborhoods.csv"))

