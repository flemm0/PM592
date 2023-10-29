library(tidyverse)
library(mfp)
library(GGally)
library(sjPlot)
# Download these files and put them in your working directory
source("plot_resid_lev_logistic.R")
source("logit_plot.R")


votemh <- read_csv("vote_mhealth.csv")

votemh %>%
  psych::describe()

votemh %>%
  skimr::skim()

votemh %>%
  ggpairs()

# I'm going to center age and education. This may help with interpretation.
# I won't center votemh because there are only 10 response categories.
votemh <-
  votemh %>%
  mutate(
    age.c = age - mean(age, na.rm=T),
    educ.c = educ - mean(educ, na.rm=T)
  )

## 2a. Assess the linearity of mental health on voting; grouped smooth --------
# Running a linear regression of voting on mhealth, just for kicks.
glm(
  vote96 ~ mhealth,
  data = votemh,
  family = binomial
) %>%
  summary()

# You'll see there's an error if you try to create 4 quantiles
# Because the 25th percentile is the same as the minimum.
# Let's assess linearity in another way.
votemh <-
  votemh %>%
  mutate(
    mhealth.q4 = cut(mhealth,
                     breaks = quantile(mhealth, probs = 0:4/4),
                     include.lowest = T)
  )

votemh %>%
  count(mhealth)

# Instead of creating quantiles, let's just turn each mhealth value into
# its own category.
votemh <-
  votemh %>%
  mutate(
    mhealth.f = factor(mhealth)
  )

# Examine the mean of vote by mhealth *category*
votemh %>%
  group_by(mhealth.f) %>%
  summarise(vote_mean = mean(vote96, na.rm=T)) %>%
  ggplot(aes(x = mhealth.f, y = vote_mean)) +
  geom_point()

# Examine the beta regression coefficients for each mhealth category
tibble(
  # This code is a relic from when we needed to take the mean of quantiles
  # But it works in this situation as well
  meanmh = votemh %>% 
    group_by(mhealth.f) %>% 
    summarise(meanmh = mean(mhealth, na.rm=T)) %>% 
    pull(meanmh),
  beta = c(0, vote_mh_categorical.m$coefficients[2:10])) %>%
  ggplot(aes(x = meanmh, y = beta)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "glm", color = "red", se = F)

# Compare the continuous mhealth measure to the categorical measure
# If the categorical model does not improve fit, then linear is sufficient
vote_mh_linear.m <-
  glm(vote96 ~ mhealth, data = votemh, family = binomial)
vote_mh_categorical.m <-
  glm(vote96 ~ mhealth.f, data = votemh, family = binomial)

anova(vote_mh_linear.m, vote_mh_categorical.m, test = "LRT")
# The test has p=0.08.

## 2b. Assess the linearity of mental health on voting; LOESS --------

# Let's examine the logit of vote by mhealth using LOESS
logit_plot("mhealth", "vote96", votemh)
# There may be some transformation of mhealth that works best.

## 2c. Assess the linearity of mental health on voting; FP --------
mfp(vote96 ~ fp(mhealth), data = votemh, family = binomial)

## 3a. Assess the linearity of age on voting --------
logit_plot("age", "vote96", votemh)
mfp(vote96 ~ fp(age), data = votemh, family = binomial)

## 3b. Assess the linearity of education on voting --------
logit_plot("educ", "vote96", votemh)
mfp(vote96 ~ fp(educ), data = votemh, family = binomial)
# MFP isn't working well, so let's try traditional polynomials
glm(vote96 ~ educ + I(educ^2) + I(educ^3),
    data = votemh, family = binomial) %>%
  anova(test = "LRT")

## 3c. Assess the linearity of gender on voting --------
# Nothing to analyze

# 4a. Assess the linearity of mhealth with covariates in the model ------
mfp(vote96 ~ fp(mhealth) + I(educ.c) + I(educ.c^2) + I((age/100)^2) + I((age/100)^3) + female,
    data = votemh, family = binomial)

# 4b. Assess the set of covariates as a confounder ------
unadjusted.m <-
  glm(vote96 ~ mhealth,
      data = votemh, family = binomial)
adjusted_educ.m <-
  glm(vote96 ~ mhealth + educ.c + I(educ.c^2),
      data = votemh, family = binomial)
adjusted_age.m <-
  glm(vote96 ~ mhealth + I((age/100)^2) + I((age/100)^3),
      data = votemh, family = binomial)
adjusted_gender.m <-
  glm(vote96 ~ mhealth + female,
      data = votemh, family = binomial)
adjusted_all.m <-
  glm(vote96 ~ mhealth + educ.c + I(educ.c^2) + I((age/100)^2) + I((age/100)^3) + female,
      data = votemh, family = binomial)

tab_model(
  unadjusted.m,
  adjusted_educ.m,
  adjusted_age.m,
  adjusted_gender.m,
  adjusted_all.m,
  transform = NULL
)
# I don't think gender is a confounder here.
prelim_final.m <-
  glm(vote96 ~ mhealth + educ.c + I(educ.c^2) + I((age/100)^2) + I((age/100)^3),
      data = votemh, family = binomial)


# 5a. Find the pseudo R2. ------
DescTools::PseudoR2(prelim_final.m)

# 5b. Compute the # of covariate patterns and the goodness of fit -----
votemh %>%
  count(mhealth, educ, age) %>%
  nrow()

# Since we have so many covariate patterns, I'm going to increase g to 20.
ResourceSelection::hoslem.test(prelim_final.m$y, fitted(prelim_final.m), g=20)
ResourceSelection::hoslem.test(prelim_final.m$y, fitted(prelim_final.m), g=20) %>%
  {cbind(
    .$observed,
    .$expected
  )}

# 5c. Compute the # of covariate patterns and the goodness of fit -----
LogisticDx::dx(prelim_final.m)
plot_resid_lev_logistic(prelim_final.m)


