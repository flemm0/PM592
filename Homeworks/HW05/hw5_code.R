library(readr)
library(tidyverse)
library(interactions)
library(ggfortify)
library(olsrr)

gx <- readr::read_csv("data/gx.csv")

head(gx)
dim(gx)
str(gx)

gx$classtype.f <- factor(gx$classtype, levels=c(1, 2, 3), labels=c("cardio", "strength", "flexibility"))

## Question 1

# 1a
lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp, data=gx) %>% summary()

lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp + age, data=gx) %>% summary()

lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp + bmi, data=gx) %>% summary()

lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp + bmi + age, data=gx) %>% summary()

# 1b
beta_pct_change <- function(adj, unadj) {
  return((abs((unadj - adj)/unadj))*100)
}
beta_pct_change(4.1245, 4.17838) # strength
beta_pct_change(.9213, 1.03237) # flexibility
beta_pct_change(.2610, .27563) # perceived exertion
beta_pct_change(.5246, .46771) # encouragement
beta_pct_change(.3947, .38527) # control
beta_pct_change(.4158, .42932) # competence


## Question 2

# 2a
lm(satisfac ~ (rpe + encourage + control + perc_comp)*classtype.f + age + bmi, data=gx) %>% summary()

# 2b
m <- lm(satisfac ~ age + bmi + rpe*classtype.f + encourage + control + perc_comp, data=gx) 
summary(m)

# 2c
interact_plot(m, pred = rpe, modx = classtype.f)
sim_slopes(m, pred = rpe, modx = classtype.f)

# 2d
autoplot(m)

ols_plot_resid_lev(m)
