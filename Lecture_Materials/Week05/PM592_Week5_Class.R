library(tidyverse)
library(GGally)
library(car)
library(olsrr)

set.seed(19)
data5 <-
  tibble(
    male = rbinom(100, 1, .48),
    sw = rnorm(100, 50, 15) - runif(100)*4*male,
    st = rnorm(100, 20, 10) + .6*sw + 15*male,
    sa = 105 - (9*sw + st)/10 + rnorm(100, 0, 10) - runif(100)*20*male
  )

data5 %>%
  ggpairs(
    diag = list(continuous = "barDiag")
  ) 

data5 %>%
  psych::describe()

set.seed(19)
data6 <-
  tibble(
    fries = rnorm(100, 50, 15),
    chips = rnorm(100, 0, 5) + fries,
    wgain = rnorm(100, 0, 2.5) + (fries + chips)/19
  )

data6 %>%
  ggpairs(
    diag = list(continuous = "barDiag")
  )

# Regress SA on SW, ST, and Male individually
lm(sa ~ sw, data = data5) %>% summary()
lm(sa ~ st, data = data5) %>% summary()
lm(sa ~ male, data = data5) %>% summary()

# Regress SA on SW, ST, and Male together
mult_reg.m <-
  lm(sa ~ sw + st + male, data = data5)

summary(mult_reg.m)

residualPlots(mult_reg.m)

qqPlot(mult_reg.m)


# Regress weight gain on fries & chips individually
lm(wgain ~ fries, data = data6) %>% summary()
lm(wgain ~ chips, data = data6) %>% summary()
lm(wgain ~ fries + chips, data = data6) %>% summary()
lm(wgain ~ chips + fries, data = data6) %>% summary()

lm(wgain ~ fries + chips, data = data6) %>% car::Anova(type = 3)
lm(wgain ~ fries + chips, data = data6) %>% ols_vif_tol()



# Real Estate Example

re <-
  read_csv("real_estate.csv")

re %>%
  select(age, distMRT, stores, area) %>%
  ggpairs()

re.m <-
lm(area ~ age + distMRT + stores, data = re)

summary(re.m)

# Assess collinearity
ols_vif_tol(re.m)

# General regression diagnostics
autoplot(re.m, which = 1:6)

# Cook's D
ols_plot_cooksd_bar(re.m)

# DFBETAS
ols_plot_dfbetas(re.m)

# DFFITS
ols_plot_dffits(re.m)

# Jackknife Residuals
ols_plot_resid_stud(re.m)

# Studentized Residuals
ols_plot_resid_stand(re.m)

# Studentized Residuals vs. Leverage
ols_plot_resid_lev(re.m)

influence.measures(re.m)$infmat %>% as_tibble()

re %>%
  bind_cols(
    tibble(
      pred = predict(re.m)
      )
    ) %>%
  .[271,]
