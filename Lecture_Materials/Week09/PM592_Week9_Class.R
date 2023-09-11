library(tidyverse)
library(haven)
library(mfp)
library(ResourceSelection)
library(LogisticDx)
library(glmulti)

# Read-in Vegetarian Data
corcalc <- 
  read_dta("corcalc.dta")

# Quick summary of variables
corcalc %>%
  select(age, sbp, cor_calcium) %>%
  psych::describe()

# Logistic regression 
glm(cor_calcium ~ sbp, 
    data = corcalc,
    family = binomial) %>% 
  summary()
glm(cor_calcium ~ sbp + age, 
    data = corcalc,
    family = binomial) %>% 
  summary()

glm(cor_calcium ~ sbp + age, 
    data = corcalc,
    family = binomial) %>% 
  autoplot()

# Regression with age
age.m <-
  glm(cor_calcium ~ age, 
    data = corcalc,
    family = binomial) 
summary(age.m)

# Here are two different ways to create the quantiles.
# Quantcut is in the gtools package
# Choose the one you like best.
corcalc <-
  corcalc %>%
  mutate(age.q4 = gtools::quantcut(age, 4))

corcalc <-
  corcalc %>%
  mutate(age.q4 = 
           cut(age, 
               breaks = quantile(age, probs = 0:4/4), 
               include.lowest = T))

corcalc %>%
  group_by(age.q4) %>%
  summarise(
    mean = mean(age, na.rm=T),
    min  = min(age, na.rm=T),
    max  = max(age, na.rm=T),
    n    = n())

# Regression with age quantiles instead of age
agequant.m <-
  glm(cor_calcium ~ age.q4,
    data = corcalc,
    family = binomial) 
summary(agequant.m)
anova(agequant.m, test = "LRT")

agequantlin.m <-
  glm(cor_calcium ~ as.integer(age.q4),
      data = corcalc,
      family = binomial)
summary(agequantlin.m)
anova(agequant.m, agequantlin.m, test = "LRT")

tibble(
  meanage = corcalc %>% 
    group_by(age.q4) %>% 
    summarise(meanage = mean(age, na.rm=T)) %>% 
    pull(meanage),
  # Because the first quantile is the reference group,
  # we set the beta for the first quantile to 0
  beta = c(0, agequant.m$coefficients[2:4])) %>%
  ggplot(aes(x = meanage, y = beta)) +
  geom_point() +
  geom_line()

tibble(
  meanage = corcalc %>% 
    group_by(age.q4) %>% 
    summarise(meanage = mean(age, na.rm=T)) %>% 
    pull(meanage),
  # Because the first quantile is the reference group,
  # we set the beta for the first quantile to 0
  beta = c(0, agequant.m$coefficients[2:4])) %>%
  ggplot(aes(x = meanage, y = beta)) +
  geom_point() +
  geom_line() +
  geom_smooth(method = "glm", color = "red", se = F)

anova(agequantlin.m, agequant.m, test = "LRT")

# LOESS plot for age
corcalc %>%
  ggplot(aes(x = age, y = cor_calcium)) +
  geom_point(alpha = .1) +
  geom_smooth()

age_pred_logits <-
  loess(cor_calcium ~ age, data = corcalc, span = .8) %>% 
  predict(.) %>%
  psych::logit()

corcalc %>%
  ggplot(aes(x = age, y = age_pred_logits)) +
  geom_count(alpha = 0.5) +
  stat_smooth(geom='line', color = "blue", method = "glm", se=FALSE)

# Fractional Polynomials
mfp(cor_calcium ~ fp(age), data = corcalc, family = binomial, verbose = T)

# Assess goodness of fit
corcalc <-
  corcalc %>%
  mutate(gender.f = factor(gender,
                           levels = 0:1,
                           labels = c("Female", "Male")),
         bl_hisp.f = factor(as.integer(race %in% 2:3),
                            levels = 0:1,
                            labels = c("Not Black/Hispanic", "Black/Hispanic"))
  )

# Examine the covariate patterns
corcalc %>%
  count(gender.f, bl_hisp.f)

# Regress cor_calcium on gender and race/ethnicity
gender_race.m <-
glm(cor_calcium ~ gender.f + bl_hisp.f, data = corcalc, family = binomial)

summary(gender_race.m)
DescTools::PseudoR2(gender_race.m)

# Get diagnostics using LogisticDx package
dx(gender_race.m)
# Something else cool that you can do
OR(gender_race.m)

# Goodness of fit: Pearsons
gof(gender_race.m, g=9, plotROC = F) %>% unclass()

# Regress cor_calcium on gender, race/ethnicity, and age
corcalc %>%
  count(gender.f, bl_hisp.f, age)

gender_race_age.m <-
  glm(cor_calcium ~ gender.f + bl_hisp.f + age, data = corcalc, family = binomial)

hoslem.test(gender_race_age.m$y, fitted(gender_race_age.m), g=10)
hoslem.test(gender_race_age.m$y, fitted(gender_race_age.m), g=10) %>%
  {cbind(
    .$observed,
    .$expected
  )}

# Diagnostics - Collinearity
DescTools::VIF(gender_race_age.m)
plot(gender_race.m)

# Diagnostics - Influence
dx(gender_race_age.m) 
dx(gender_race_age.m, bycov = F) 

plot(gender_race_age.m)
plot(gender_race_age.m, identify = T)

plot_resid_lev_logistic(gender_race_age.m)


# Low birthweight data
data(lbw) 
lbw <-
  lbw %>% as_tibble()

lbw %>%
  select(LOW, AGE, LWT, RACE, SMOKE, PTL, HT, UI, FTV) %>%
  GGally::ggpairs()

best_subset_low <-
glmulti(LOW ~ AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, data=lbw,
        level=1, family = binomial, crit="aicc", confsetsize=128)

print(best_subset_low)
plot(best_subset_low)
head(weightable(best_subset_low))

plot(best_subset_low, type = "s")
importance(best_subset_low)

best_subset_low@objects[[1]] %>% summary()

forward_low <-
  MASS::stepAIC(
    glm(LOW ~ 1, 
        data=lbw, family = binomial),
    scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV,
                 lower = ~1),
    direction = "forward"
  )

backward_low <-
  MASS::stepAIC(
    glm(LOW ~ AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, 
        data=lbw, family = binomial),
    scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV,
                 lower = ~1),
    direction = "backward"
  )

stepwise_low <-
  MASS::stepAIC(
    glm(LOW ~ 1, 
        data=lbw, family = binomial),
    scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV,
                 lower = ~1),
    direction = "both"
  )

tab_model(
  forward_low,
  backward_low,
  stepwise_low
)
