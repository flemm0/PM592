library(tidyverse)
library(haven)
library(mfp)
library(emmeans)
library(skimr)
source("pois_gof.R")

hospitaler <- read_dta("hospitaler.dta")

hospitaler %>%
  skimr::skim()

# Find the mean and variance of the three variables
# Method 1 - Use "summarise"
hospitaler %>%
  group_by(mo4) %>%
  summarise(
    mean_er = mean(er_visit, na.rm=T),
    var_er = sd(er_visit, na.rm=T)^2,
    mean_ad = mean(admit, na.rm=T),
    var_ad = sd(admit, na.rm=T)^2,
    mean_read = mean(readmit, na.rm=T),
    var_read = sd(readmit, na.rm=T)^2
  )

# Method 2 - use "skim"
skim_meanvar <- skim_with(numeric=sfl(mean, var), 
                          base=NULL, append=F)
hospitaler %>%
  group_by(mo4) %>%
  select(er_visit, admit, readmit) %>%
  skim_meanvar() %>%
  print(n=Inf)

hospitaler <-
  hospitaler %>%
  mutate(rate_admit = admit / er_visit)

# The relationship between month and log rate of admission is not linear
hospitaler %>%
  ggplot(aes(x = month, y = log(rate_admit))) +
  geom_point() +
  geom_smooth() + 
  geom_smooth(method="lm", formula="y~I(x^3) + I(x^3*log(x))", color="red")

# In fact the FP procedure recommends a complicated pair of polynomials
# MFP requires offset to be in the formula
mfp::mfp(admit ~ fp(month) + offset(log(er_visit)), 
         family = poisson,
         data = hospitaler)

# Build the poisson model
er1.m <-
  glm(admit ~ factor(mo4) + offset(log(er_visit)),
      family = poisson, 
      data = hospitaler)
summary(er1.m)
exp(coefficients(er1.m))

# Predicted admissions by time period
# NOTE THE "RATE" LABEL IS DECEIVING. CHANGING THE Y LABEL.
emmeans(er1.m, "mo4", type = "response") 
emmip(er1.m, ~ mo4, type = "response", CIs = TRUE) +
  labs(y = "Predicted Admissions")

# Predicted admission rate (per 100) by time period
emmeans(er1.m, "mo4", type = "response", offset = log(100)) 
emmip(er1.m, ~ mo4, type = "response", offset = log(100), CIs = TRUE) +
  labs(y = "Predicted Rate of Admission (per 100 ER Visits)")

# Goodness of Fit
# THESE FUNCTIONS AVAILABLE IN WEEK11_CLASS R FILE
pois_pearson_gof(er1.m)
pois_dev_gof(er1.m)

# Predicted vs. Actual Counts
tibble(
  obs = er1.m$y,
  pred = predict(er1.m, type = "response")
) %>%
  ggplot(aes(x = obs, y = pred)) +
  geom_point() + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  geom_smooth(method = "glm", se = F)

# Predicted vs. Actual Rates
tibble(
  hospitaler,
  pred = predict(er1.m, 
                 hospitaler %>% mutate(er_visit=1), 
                 type = "response")
) %>%
  ggplot(aes(x = rate_admit, y = pred)) +
  geom_point() + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  geom_smooth(method = "glm", se = F)

# Predicted & Actual Counts by month
tibble(
  hospitaler,
  pred = predict(er1.m, type = "response")
) %>%
  ggplot(aes(x = month, y = admit)) +
  geom_point(color="blue") +
  geom_point(aes(y=pred), color="red") + 
  geom_line(aes(y=pred), color="red")

# Predicted & Actual Rate by month
tibble(
  hospitaler,
  pred = predict(er1.m, 
                 hospitaler %>% mutate(er_visit=1), 
                 type = "response")
) %>%
  ggplot(aes(x = month, y = rate_admit)) +
  geom_point(color="blue") +
  geom_point(aes(y=pred), color="red") + 
  geom_line(aes(y=pred), color="red")

# Checking for Overdispersion
AER::dispersiontest(er1.m)



# Fit a NB model, compare to Poisson
library(MASS)
library(sjPlot)
er2.m <- glm.nb(admit ~ factor(mo4) + offset(log(er_visit)),
             data = hospitaler)
summary(er2.m)
tab_model(er1.m, er2.m, show.aic=T)
pois_pearson_gof(er2.m)
pois_dev_gof(er2.m)
