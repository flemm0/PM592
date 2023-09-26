library(tidyverse)
library(car)

# Read-in CHS data and simplify the race variable
chs <-
  read_csv("chs_individual.csv") %>%
  mutate(race = case_when(
    race == "D" ~ "O",
    race == "M" ~ "O",
    TRUE ~ race
  ) %>%
    as.factor() %>%
    relevel(ref = "W")
  )

# Model 1 - BMI
fev.m1 <-
  lm(fev ~ bmi, data = chs)

anova(fev.m1)
anova.full(fev.m1)

# Model 2 - BMI + Pets
fev.m2 <-
  lm(fev ~ bmi + pets, data = chs)

# Model 3 - BMI + race
fev.m3 <-
  lm(fev ~ bmi + race, data = chs)

# Examine the effect of just race
fev_race.m <-
  lm(fev ~ race, data = chs)
anova(fev_race.m)
summary(fev_race.m)

# Boxplot for comparing FEV among race groups
chs %>%
  ggplot(aes(x = race, y = fev, fill = race)) +
  geom_boxplot(alpha = .25)

aov(fev ~ race, data = chs) %>% summary()
aov(fev ~ race, data = chs) %>% TukeyHSD()

# Model with several predictors

fev.m4 <-
  lm(fev ~ wheeze + male, data = chs)
anova(fev.m4)

fev.m5 <-
  lm(fev ~ male + wheeze, data = chs)
anova(fev.m5)


Anova(fev.m4, type = 3)





##############################
# Lab Exercises

#1
cereals <- read_csv("cereals.csv")
cereals %>%
  count(mfr.f)
cereals %>%
  ggplot(aes(x=mfr.f, y=rating)) +
  geom_boxplot()
cereals <-
  cereals %>%
  mutate(mfr.f = factor(mfr) %>%
           relevel("G"))

#2
lm(rating ~ calories, data=cereals) %>% summary()
lm(rating ~ sugars, data=cereals) %>% summary()
lm(rating ~ mfr.f, data=cereals) %>% summary()

#3
library(GGally)
cereals %>%
  select(rating, calories, sugars, mfr.f) %>%
  ggpairs()

#4
m1 <- lm(rating ~ calories + sugars, data=cereals)
m2 <- lm(rating ~ calories + sugars + mfr.f, data=cereals, na.action=na.exclude)
summary(m2)
anova(m1, m2)
anova(m2)

#5
car::vif(m2)

#7
library(ggfortify)
m2 %>%
  autoplot(which=1:6)

#8
library(olsrr)
ols_plot_cooksd_bar(m2)
ols_plot_dfbetas(m2, print_plot=F)
ols_plot_dffits(m2)
ols_plot_resid_lev(m2)


cereals <-
  cereals %>%
  mutate(
    pred_rating = predict(m2),
    rstudent = rstudent(m2)
  )

cereals[45,] %>%
  select(name, rating, pred_rating,
         sugars, calories, mfr.f)


survey::regTermTest(m2, ~mfr.f)


  
