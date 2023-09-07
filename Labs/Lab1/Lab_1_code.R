library(skimr)
library(tidyverse)
library(Hmisc)
library(readr)

setwd('./Week1')

## 3. read in profiles data
df <-  readr::read_csv('./okcprofiles_cleaned.csv')


## 4. view part of the data
head(df)

## 4a. how many observations
dim(df)[1]

## 4b. how many variables
dim(df)[2]


## 4c. what are the variable names
names(df)


## 5a. what is the output from `summary()`
summary(df)
# prints quartiles, min, max, mean, median for numerical variables
# prints number of observations and data type for string/character variables

## 5b. what is the output from `skimr::skim()`
df %>%
  skim()
# prints number of rows, columns, data types of each column
# for string/character variables, it reports number missing, number of unique variables, etc.
# for numerical variables it reports number missing, mean, quartiles, standard deviation, and a histogram

## 5c. what is the output from `Hmisc::describe()`
describe(df)
# for numerical variables, it prints summary statistics such as mean, percentiles, number missing, mean, the lowest and highest five values
# for string/character variables it print the frequency and proportion of each distinct value in that column

## 6. create new variable drink_yn
df <- df %>%
  mutate(drink_yn = ifelse(drinks == "not at all", 0, 1))

## 6a. how many people drink
sum(df$drink_yn, na.rm = TRUE) # 53,694 people drink

## 7. create new variable drugs_yn
df <- df %>%
  mutate(drugs_yn = ifelse(drugs == "never", 0, 1))

## 7a. how many people do drugs
sum(df$drugs_yn, na.rm = TRUE) # 8,142 people do drugs

## 8. use count function on drink_yn and drugs_yn
df %>%
  count(drugs_yn, drink_yn) #2,920 people do not do drugs and do not drink

## 9. create new variable called height_ft
df <- df %>%
  mutate(height_ft = height/12)

## 9a. what is the mean of height_ft
mean(df$height_ft, na.rm = TRUE) #5.69 ft is the mean

## 10. what percent of profiles are from users currently seeing someone
df %>%
  group_by(status) %>%
  summarise(n = n()) %>%
  mutate(pct = n / sum(n)) # 3.4% of people are currently "seeing someone"

## 11. use following code to get mean height of males and females
df %>%
  group_by(sex) %>%
  summarise(meanht = mean(height))
# outputs NA for each category

## 12. use following code to get mean height of males and females
df %>%
  group_by(sex) %>%
  summarise(meanht = mean(height, na.rm = TRUE))
# now it outputs the correct mean height for each category
# the code in q 11 did not work because R does not know how to take the mean of a list of values for which some values are unknown (it needs to be told to ignore NA values)

## 13. save data as RDS
write_rds(df, "profiles_new.rds")
