library(tidyverse)
# library(readr)
# library(readxl)
# library(lubridate)
# library(psych)

# Read in data sets.
chs_individual <- read_csv("chs_individual.csv")
chs_regional   <- read_csv("chs_regional.csv")

# Create a new data set that is chs_individual merged with chs_dates.
chs_merged <-
  chs_individual %>%
  left_join(chs_regional, by="townname")

# Create BMI cutpoints with "cut".
chs_merged <-
  chs_merged %>%
  mutate(
    bmicat1 = cut(
      bmi,
      breaks = c(0, 18.5, 25, 30, 100)
    ),
    bmicat2 = cut(
      bmi,
      breaks = c(0, 18.5, 25, 30, 100),
      right = F
    ),
    bmicat3 = cut(
      bmi,
      breaks = c(0, 18.5, 25, 30, 100),
      right = F,
      labels = c("Underweight", "Healthy Weight", "Overweight", "Obese")
    ),
    bmicat4 = cut(
      bmi,
      breaks = c(0, 18.5, 25, 30, 100),
      right = F,
      labels = c("Underweight", "Healthy Weight", "Overweight", "Obese"),
      ordered_result = T
    )
  )

chs_merged %>%
  select(starts_with("bmicat"))

# Create FEV categories with "ntile"
chs_merged <-
  chs_merged %>%
  mutate(
    fev4c = ntile(fev, 4),
    fev5c = ntile(fev, 5)
  )

chs_merged %>%
  group_by(fev4c) %>%
  summarise(
    min = min(fev),
    max = max(fev),
    mean = mean(fev),
    n = n()
  )

chs_merged %>%
  group_by(fev5c) %>%
  summarise(
    min = min(fev),
    max = max(fev),
    mean = mean(fev),
    n = n()
  )

# First function: hello
hello.world <- function() {
  print("Hello world!")
}

hello.world()

# Second function: F to C
f.to.c <- function(temp_F) {
  temp_C <- (temp_F - 32) * 5 / 9
  return(temp_C)
}

f.to.c(32)
f.to.c(100)

# Third function: mean0
mean0 <- function(x) {
  mean(x,  na.rm=T)
}

mean(chs_merged$fev)
mean0(chs_merged$fev)

# Fourth function: bmi
calc.bmi <- function(ht_inches, wt_pounds) {
  bmi <- 703*wt_pounds/ht_inches^2
  return(bmi)
}

# ggplot 1
chs_merged %>%
  ggplot(aes(x = agepft, y = fev))

chs_merged %>%
  ggplot(aes(x = agepft, y = fev)) +
  geom_point() +
  geom_smooth(se = F, method = "lm")

chs_merged %>%
  ggplot(aes(x = agepft, y = fev)) +
  geom_point(size = 2, color = "darkgreen") +
  geom_smooth(se = F, method = "lm", linetype = "dashed")

chs_merged %>%
  ggplot(aes(x = agepft, y = fev, color = bmicat4)) +
  geom_point() +
  geom_smooth(se = F, method = "lm")

chs_merged %>%
  ggplot(aes(x = agepft, y = fev, color = bmi)) +
  geom_point() +
  geom_smooth(se = F, method = "lm")

# Correlation
chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  cor()

chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  cor(use = "pairwise.complete.obs")

chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  cor(use = "complete.obs")

cor.test(chs_merged$fev, chs_merged$fvc)

library(Hmisc)
chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  as.matrix() %>%
  rcorr(type = "pearson")

library(ggcorrplot)
chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  cor(use = "pairwise.complete.obs") %>%
  ggcorrplot()

chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  cor(use = "pairwise.complete.obs") %>%
  ggcorrplot(method = "circle")

library(PerformanceAnalytics)
chs_merged %>%
  select(agepft, fev, fvc, mmef) %>%
  chart.Correlation(histogram=TRUE, pch=19)

# Linear Regression
model1 <-
  lm(fev ~ agepft, data = chs_merged)

model1 %>%
  summary()

model1_std <-
  lm(scale(fev) ~ scale(agepft), data = chs_merged)

model1_std %>%
  summary()

chs_merged2 <- cbind(
  chs_merged,
  predict(model1, chs_merged, interval="prediction")
)

chs_merged2 %>%
  ggplot(aes(x = agepft, y = fev))+
  geom_point() +
  geom_line(aes(y=lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y=upr), color = "red", linetype = "dashed")+
  geom_smooth(method=lm, se=TRUE)




##################
# Lab 3 Exercises
##################

#1

library(haven)

no2.d <- read_sas("no2.sas7bdat")

no2.glendora <-
  no2.d %>%
  filter(townname == "Glendora")

no2.glendora %>%
  skimr::skim(NO2)

no2.glendora %>%
  ggplot(aes(x=fwydist, y=NO2)) +
  geom_point() +
  geom_smooth(method="lm")

#2
model1 <- lm(NO2 ~ fwydist, data=no2.glendora)
summary(model1)

no2.glendora <-
  no2.glendora %>%
  mutate(fwydist.c = fwydist - mean(fwydist))

#3

model2 <- lm(NO2 ~ fwydist.c, data=no2.glendora)
summary(model2)

#4
no2.glendora <-
  no2.glendora %>%
  mutate(fwydist.miles = fwydist*0.621371)

model3 <- lm(NO2 ~ fwydist.miles, data=no2.glendora)
summary(model3)
