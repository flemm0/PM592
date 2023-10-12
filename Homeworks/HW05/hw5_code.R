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
beta_pct_change(4.1245, 4.17708) # strength
beta_pct_change(.9213, 1.03705) # flexibility
beta_pct_change(.2610, .27592) # perceived exertion
beta_pct_change(.5246, .47857) # encouragement
beta_pct_change(.3947, .43744) # control
beta_pct_change(.4158, .42932) # competence


## Question 2

# 2a
anova(
  lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp, data=gx),
  lm(satisfac ~ rpe*classtype.f + encourage + control + perc_comp, data=gx)
)
anova(
  lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp, data=gx),
  lm(satisfac ~ rpe + encourage*classtype.f + control + perc_comp, data=gx)
)
anova(
  lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp, data=gx),
  lm(satisfac ~ rpe + encourage + control*classtype.f + perc_comp, data=gx)
)
anova(
  lm(satisfac ~ classtype.f + rpe + encourage + control + perc_comp, data=gx),
  lm(satisfac ~ rpe + encourage + control + perc_comp*classtype.f, data=gx)
)


# 2b
m <- lm(satisfac ~ classtype.f*rpe + encourage + control + perc_comp, data=gx) 
summary(m)

# 2c
interact_plot(m, pred = rpe, modx = classtype.f)
sim_slopes(m, pred = rpe, modx = classtype.f)

interact_plot(m, pred = encourage, modx = classtype.f)
sim_slopes(m, pred = encourage, modx = classtype.f)


# 2d
autoplot(m)

ols_plot_resid_lev(m)
