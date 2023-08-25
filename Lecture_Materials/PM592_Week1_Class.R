## PM592 Week 1 R Code

# Download and install R www.r-project.org
# Dowload and install R Studio www.rstudio.com
# Install packages using "install.packages("packagename")

library(tidyverse)
library(readxl)
library(skimr)

# Read in WCGS data set
# Note the file must be in the same location as the working directory
#   or you will need to refer to the full path name
wcgs <- read_xls("wcgs.xls")

# To select certain columns
wcgs %>%
  select(age, height, chol, sbp)

# To describe (skim) the data set
wcgs %>%
  select(age, height, chol, sbp) %>%
  skim()

# Describe the data set by personality type
wcgs %>%
  select(age, height, chol, sbp, dibpat) %>%
  group_by(dibpat) %>%
  skim()

# Describe the data set by using R base package instead of skimr
summary(wcgs[, c("age", "height", "chol", "sbp")])

# Boxplot
wcgs %>%
  ggplot(aes(y=sbp)) +
  geom_boxplot()

# Histogram
wcgs %>%
  ggplot(aes(x=sbp)) +
  geom_histogram() 

# Table
wcgs %>%
  count(dibpat)

with(wcgs, table(dibpat))

table(wcgs$dibpat)

# Bar Chart
wcgs %>%
  ggplot(aes(x=dibpat)) +
  geom_bar()

# Create a "factor" variable for personality type
wcgs <-
  wcgs %>%
  mutate(dibpat.f = factor(dibpat,
                            levels = c("Type A", "Type B")))

wcgs %>%
  ggplot(aes(x=dibpat.f)) +
  geom_bar()

# Proportion
wcgs %>%
  group_by(dibpat) %>%
  summarise(n = n()) %>%
  mutate(pct = n / sum(n))

# Scatterplot - age and SBP
wcgs %>%
  ggplot(aes(x = age, y = sbp)) +
  geom_point()

# Scatterplot with jitter - age and SBP
wcgs %>%
  ggplot(aes(x = age, y = sbp)) +
  geom_jitter()

# Mean sbp and age by dibpat.f category
wcgs %>% 
  group_by(dibpat.f) %>% 
  summarise(sbp=mean(sbp, na.rm=TRUE),
            age=mean(age, na.rm=TRUE)) 

# Boxplot sbp gy personality type
wcgs %>%
  ggplot(aes(x=dibpat, y=sbp)) + 
  geom_boxplot()

# Frequency table
library(gmodels)
CrossTable(wcgs$dibpat.f, wcgs$smoke, prop.t=F)
with(wcgs,
  CrossTable(dibpat.f, smoke, prop.t=F))

