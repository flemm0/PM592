library(tidyverse)
library(readr)

source("Labs/Lab09/plot_resid_lev_logistic.R")
source("Labs/Lab09/logit_plot.R")

green <- readr::read_csv('data/green.csv')

head(green)
str(green)


## Question 1

# 1a
green$dur.f <- factor(green$dur)

depres.m <- glm(depres ~ dur.f, family = binomial, data = green)

tibble(
    duration = as.numeric(levels(green$dur.f)), 
    coef = c(0, depres.m$coefficients[2:length(depres.m$coefficients)]) # the pred logit should start at 0 for the reference group
) %>%
  ggplot(aes(x=duration, y=coef)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "glm", se = F, formula = "y ~ x", color="red") +
  ggtitle("Depression Grouped Smooth")

hibp.m <- glm(hibp ~ dur.f, family = binomial, data = green)

tibble(
  duration = as.numeric(levels(green$dur.f)),
  coef = c(0, hibp.m$coefficients[2:length(hibp.m$coefficients)])
) %>%
  ggplot(aes(x=duration, y=coef)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "glm", se = F, formula = "y ~ x", color = "red") +
  ggtitle("High Blood Pressure Grouped Smooth")

# 1b
logit_plot("dur", "depres", green)
logit_plot("dur", "hibp", green)

# 1c
mfp(depres ~ fp(dur), data = green, family = binomial)
mfp(hibp ~ fp(dur), data = green, family = binomial)

# 1e
glm(depres ~ dur, data = green, family = binomial) %>% summary()
green$dur_log <- log(((green$dur+7.5)/100)) # transformation suggested by `mfp`
glm(hibp ~ dur_log, data = green, family = binomial) %>% summary()

# logistic regression with duration category on high bp
glm(hibp ~ factor(dur), data = green, family = binomial) |> summary()
