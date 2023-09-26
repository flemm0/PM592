library(olsrr)
library(GGally)
library(tidyverse)
library(readr)
library(car)

cereals <- readr::read_csv("data/cereals.csv")

## Question 1

# 1a
cereals <-
  cereals %>%
  mutate(mfr.f = factor(mfr))

cereals$mfr.f # "A" is the reference category (alphabetical)

# 1b
cereals %>%
  count(mfr.f)
cereals$mfr.f <- relevel(cereals$mfr.f, ref = "K")
# now "K" is the reference category, since it has the most number of cereals

# 1c
ggplot(cereals, aes(x=mfr.f, y=rating)) + 
  geom_boxplot() +
  theme_minimal()
# based on the boxplot, I believe that an ANOVA would be significant, as the ratings differ a lot based on manufacturer


## Question 2

# 2a
m.2a <- lm(rating ~ calories, data = cereals)
summary(m.2a)

# 2b
m.2b <- lm(rating ~ sugars, data = cereals)
summary(m.2b)

# 2c
m.2c <- lm(rating ~ mfr.f, data = cereals)
summary(m.2c)


## Question 3

cereals$mfr.f

## Question 4

ggpairs(data = cereals, columns = c("rating", "calories", "sugars", "mfr.f"))

## Question 5

# 5a
m.5a <- lm(rating ~ sugars + calories + mfr.f, data = cereals)
summary(m.5a)

# 5c
m.5c <- lm(rating ~ sugars + calories, data = cereals)
anova(m.5a)
anova(m.5c)

anova(m.5c, m.5a)
# f = ((4834.5 - 2876.5) / (74 - 68)) / (2876.5 / 68)
# 1-pf(f, 6, 68)

## Question 6

car::vif(m.5a)

## Question 7

autoplot(m.5a)

## Question 8

# 8a
ols_plot_cooksd_bar(m.5a)

# 8b
ols_plot_dfbetas(m.5a, print_plot = FALSE)

# 8c
ols_plot_dffits(m.5a)

# 8d
ols_plot_resid_lev(m.5a)


## Question 9
cereals[4,] %>%
  select(rating, )
