## Lab 1 Solutions
library(tidyverse)
library(readr)

#3 Read-in the data using read_csv
okcprofiles <-
  read_csv("okcprofiles_cleaned.csv")

#4 How many observations?
dim(okcprofiles)[1]
#4 How many variables?
dim(okcprofiles)[2]
#4 What are the variable names?
names(okcprofiles)

#5 R's base summary
summary(okcprofiles)
skimr::skim(okcprofiles)
Hmisc::describe(okcprofiles)

#6 Drinks any amount variable
okcprofiles <-
  okcprofiles %>%
  mutate(drink_yn = if_else(drinks=="not at all", 0, 1))

#7 Drugs in any amount variable
okcprofiles <-
  okcprofiles %>%
  mutate(drugs_yn = if_else(drugs=="never", 0, 1))

#8 Count "drugs_yn" and "drink_yn"
okcprofiles %>%
  count(drugs_yn, drink_yn)

#9 Height (feet)
okcprofiles <-
  okcprofiles %>%
  mutate(height_ft = height/12)

okcprofiles %>%
  skimr::skim(height_ft)

#10 Currently seeing someone
okcprofiles %>%
  count(status) %>%
  mutate(prop = n/sum(n))

gmodels::CrossTable(okcprofiles$status)

#11 
okcprofiles %>%
  group_by(sex) %>%
  skimr::skim(height)

okcprofiles %>% 
  group_by(sex) %>% 
  summarise(meanht = mean(height))

#12
okcprofiles %>% 
  group_by(sex) %>% 
  summarise(meanht = mean(height, na.rm=T))

#13
write_rds(okcprofiles, "okcprofiles_new.rds")
