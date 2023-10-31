library(tidyverse)
library(readr)
library(mfp)
library(GGally)
library(sjPlot)
library(ResourceSelection)

source("Labs/Lab09/plot_resid_lev_logistic.R")
source("Labs/Lab09/logit_plot.R")

votemh <- readr::read_csv('data/vote_mhealth.csv')

votemh %>%
  psych::describe()

votemh %>%
  skimr::skim()

## Question 1

# center age and education to make for easier interpretation
votemh <-
  votemh %>%
  mutate(age.c = age - mean(age), educ.c = educ - mean(educ))

## Question 2

# 2a
votemh <-
  votemh %>%
  mutate(mhealth.f = factor(mhealth))

votemh %>%
  group_by(mhealth.f) %>%
  summarise(vote_mean = mean(vote96, na.rm=T)) %>%
  ggplot(aes(x = mhealth.f, y = vote_mean)) +
  geom_point()

anova(
  glm(vote96 ~ mhealth, family = binomial, data = votemh),
  glm(vote96 ~ factor(mhealth), family = binomial, data = votemh),
  test = "LRT"
)

# 2b
logit_plot("mhealth", "vote96", votemh)

# 2c
mfp(vote96 ~ fp(mhealth), data = votemh, family = binomial)


## Question 3

# 3a
logit_plot("age", "vote96", votemh)
mfp(vote96 ~ fp(age), data = votemh, family = binomial)

# 3b
logit_plot("educ", "vote96", votemh)
mfp(vote96 ~ fp(educ), data = votemh, family = binomial)
glm(vote96 ~ educ + I(educ^2) + I(educ^3),
    data = votemh, family = binomial) %>%
  anova(test = "LRT")

# 3c
# gender is a binary variable in this data set
logit_plot("female", "vote96", votemh)

# 4a
votemh <- 
  votemh %>%
  mutate(age_sq = I((age/100)^2), age_cube = I((age/100)^3))
mfp(vote96 ~ fp(mhealth) + female + educ.c + educ.c^2 + age_sq + age_cube, data = votemh, family = binomial)

# 4b
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

# 4c
final_model <- glm(vote96 ~ mhealth + educ.c + I(educ.c^2) + I((age/100)^2) + I((age/100)^3), family = binomial, data = votemh)
summary(final_model)


## Question 5

# 5a
DescTools::PseudoR2(final_model)

# 5b
# there are many covariate patterns, especially because age is continuous
# based on this, I will use the Hosmer-Lemeshow test for goodness of fit
hoslem.test(final_model$y, fitted(final_model), g=20)

# 5c
LogisticDx::dx(final_model)
LogisticDx::dx(final_model, byCov = F)
plot_resid_lev_logistic(final_model)


## Question 6
tab_model(
  unadjusted.m, final_model
)
