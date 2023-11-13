library(haven)
library(tidyverse)
library(emmeans)
library(haven)

rm(list = ls())
source('Lecture_Materials/Week11/pois_gof.R')

er <- haven::read_dta("data/hospitaler.dta")
head(er)
str(er)


## Question 1

# 1a
er %>%
  group_by(mo4) %>%
  summarise(
    mean_er = mean(er_visit, na.rm=T),
    var_er = var(er_visit, na.rm=T),
    mean_ad = mean(admit, na.rm=T),
    var_ad = var(admit, na.rm=T),
    mean_read = mean(readmit, na.rm=T),
    var_read = var(readmit, na.rm=T)
  )

# 1b
er <- er %>%
  mutate(rate_admit = admit / er_visit)

# 1c
ggplot(data = er, aes(x=month, y=log(rate_admit))) +
  geom_point() +
  geom_smooth() + 
  geom_smooth(method="lm", formula="y~I(x^3) + I(x^3*log(x))", color="red")


## Question 2

# 2a
er_count.m <- glm(admit ~ factor(mo4), family = poisson, data = er)
summary(er_count.m)

# 2b
er.m <- glm(admit ~ factor(mo4) + offset(log(er_visit)), family = poisson, data = er)
summary(er.m)

# 2c
tibble(parameter = names(er.m$coefficients), 
       rr = exp(er.m$coefficients), 
       as.data.frame.matrix(exp(confint.default(er.m)))
       )


## Question 3

# 3a
emmeans(er.m, "mo4", type = "response") 
emmip(er.m, ~ mo4, type = "response", CIs = TRUE) +
  labs(y = "Predicted Admissions")

# 3b
emmeans(er.m, "mo4", type = "response", offset = (log(100)))
emmip(er.m, ~ mo4, type = "response", CIs = TRUE, offset = log(100)) +
  labs(y = "Predicted Admissions (per 100 Individuals in ER)")

# 3c
# Predicted vs. Actual Counts
tibble(
  obs = er.m$y,
  pred = predict(er.m, type = "response")
) %>%
  ggplot(aes(x = obs, y = pred)) +
  geom_point() + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  geom_smooth(method = "glm", se = F)

# Predicted vs. Actual Rates
tibble(
  er,
  pred = predict(er.m, 
                 er %>% mutate(er_visit=1), 
                 type = "response")
) %>%
  ggplot(aes(x = rate_admit, y = pred)) +
  geom_point() + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  geom_smooth(method = "glm", se = F)


## Question 4

# 4a
pois_pearson_gof(er.m)

# 4b
pois_dev_gof(er.m)

# 4d
AER::dispersiontest(er.m)

# 5
library(MASS)
MASS::glm.nb(admit ~ factor(mo4) + offset(log(er_visit)), data = er)

# 6
glm(readmit ~ factor(mo4) + offset(log(admit)), family = poisson, data = er) %>%
  summary()
