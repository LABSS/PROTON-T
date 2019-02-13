library(tidyverse)
library(readxl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

df <-
  file.path("raw", "ABMstuff.xlsx") %>%
  read_excel(sheet = "Setup-Landscape") %>%
  gather(Area, value, - Factor) %>%
  mutate(
    Area = Area %>%
    str_extract_all("\\d+")
  ) %>%
  mutate(
      Factor =
        Factor %>%
      gsub(pattern = "%", replacement = " percent", .) %>%
        gsub(pattern = "#", replacement = " num", .)  %>%
        gsub(pattern = "\\+", replacement = " on", .) 
  )  %>%
  write_csv(file.path("data", "neighborhoods.csv"))

