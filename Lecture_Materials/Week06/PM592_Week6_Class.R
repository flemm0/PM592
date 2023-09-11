library(tidyverse)
library(haven)
library(readxl)
library(interactions)

# Load the data. 
# This data set is not available to the class but the code is presented here.
places <-
  read_dta("G:/My Drive/PLACES/HP_DATA/SURVEY/ADULT/adult_wave1_practice.dta") %>%
  mutate(racecat = relevel(factor(racecat), ref = "Hispanic/Latino"))

# Compare the model with intervention as a predictor (m1) vs. the null model (m0).
m1 <- lm(enjoy_ex1 ~ intervention, data = places)
summary(m1)
m0 <- lm(enjoy_ex1 ~ 1, data = places) 
summary(m0)

anova(m1)
anova(m0)

# Add racecat as a potential confounder.
# Then illustrate the use of the Extra SS F-test
m2 <- lm(enjoy_ex1 ~ intervention + racecat, data = places)
summary(m2)

anova(m1, m2)


# Load the WCGS data set for use
wcgs <-
  read_xls("wcgs.xls") %>%
  mutate(bmi = 703*weight/height^2)

# Examine age as a confounder between personality type and SBP
m3 <- lm(sbp ~ factor(dibpat), data = wcgs)
m3a <- lm(sbp ~ factor(dibpat) + age, data = wcgs)
summary(m3)
summary(m3a)


# Load the ice cream data set for use
# Then create a high-income dummy variable
# And create a price X hiincome interaction variable
ic <- read_csv("icecream.txt") %>%
  mutate(hiincome = factor(income > median(income), 
                           labels = c("Below Median", "Above Median")),
         price_hiincome = price * (income > median(income)))

# Simple plot of consumption vs price, and fit the model
ic %>%
  ggplot(aes(x = price, y = cons)) +
  geom_point() +
  geom_smooth(method = "lm")

ic.m1 <- 
  lm(cons ~ price, data = ic)
summary(ic.m1)

# Plot of consumption vs price, by income category
# Then fit the model specifically for each income category
ic %>%
  ggplot(aes(x = price, y = cons, color = hiincome)) +
  geom_point() +
  geom_smooth(method = "lm")

ic.m2a <- 
  lm(cons ~ price, data = ic %>% filter(hiincome == "Below Median"))
summary(ic.m2a)
ic.m2b <- 
  lm(cons ~ price, data = ic %>% filter(hiincome == "Above Median"))
summary(ic.m2b)

# We can combine the information from these two stratified models
# into a single model with an interaction term
ic.m2 <-
  lm(cons ~ price + hiincome + price_hiincome, data = ic)
summary(ic.m2)

summary(lm(cons ~ price*hiincome, data = ic))


# Center the income and price variables for further use
ic <-
  ic %>%
  mutate(
    income.c = income - mean(income, na.rm=T),
    price.c  = price - mean(price, na.rm=T)
  )
  
# Plot of consumption vs price, by continuous income
ic %>%
  ggplot(aes(x = price.c, y = cons, color = income.c)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_color_gradient(low = "blue", high = "red")

# Model for continuous-by-continuous interaction
ic.m3 <-
  lm(cons ~ price.c*income.c, data = ic)
summary(ic.m3)

interact_plot(ic.m3, pred = price.c, modx = income.c)
interact_plot(ic.m3, pred = price.c, modx = income.c, plot.points = T)
interact_plot(ic.m3, pred = price.c, modx = income.c, plot.points = T, linearity.check = T)

sim_slopes(ic.m3, pred = price.c, modx = income.c, johnson_neyman = FALSE)
