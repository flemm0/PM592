library(tidyverse)
library(mfp)
library(ROCit)
# Download these files and put them in your working directory
source("plot_resid_lev_logistic.R")
source("logit_plot.R")
source("group_smooth.R")

sos_dat <- read_csv("sos_dat.csv")

with(sos_dat,
     gmodels::CrossTable(s_att))

# Categorical Method 1: Contingency Table
with(sos_dat,
     gmodels::CrossTable(grade, s_att, prop.chisq=F, prop.t=F, chisq=T))

# Categorical Method 2: Logistic Regression
univ_grade.m <-
  glm(s_att ~ factor(grade), family = binomial, data = sos_dat)
summary(univ_grade.m)
anova(univ_grade.m, test="LRT")

# Categorical: examine linearity for ordinal variables
group_smooth("grade", "s_att", sos_dat)

# Continuous
sos_dat %>%
  group_by(s_att) %>%
  select(s_att, odg) %>%
  skimr::skim()

univ_odg.m <-
  glm(s_att ~ odg, family = binomial, data = sos_dat)
summary(univ_odg.m)

logit_plot("odg", "s_att", sos_dat)
group_smooth("odg", "s_att", sos_dat)
mfp(s_att ~ fp(odg), family = binomial, data = sos_dat)


# Proceed with best subsets
best_subset_att <-
  glmulti::glmulti(s_att ~ odg + dens + recip + age + factor(grade) + male + bully + bullied, 
          data = sos_dat,
          level=1, family = binomial, crit="aicc", confsetsize=128)

best_subset2_att <-
  glmulti::glmulti(s_att ~ odg + dens + recip + age + factor(grade) + male + bully + bullied +
                     I(age^2) + I(odg*dens) + I(odg*recip) + I(dens*recip), 
                   data = sos_dat,
                   level=1, family = binomial, crit="aicc", confsetsize=128)

best_model <- 
  summary(best_subset2_att)$bestmodel %>% glm(., data = sos_dat, family = binomial)

ResourceSelection::hoslem.test(best_model$y, fitted(best_model), g=20)

plot_resid_lev_logistic(best_model)
LogisticDx::dx(best_model)


# Classification
DescTools::Conf(best_model, pos = 1)

best_model.p <-
  tibble(
    pred_p = best_model$fitted.values,
    y = best_model$y
  )

best_model.p %>%
  ggplot(aes(x = pred_p)) + 
  facet_wrap(~y) +
  geom_histogram() +
  geom_vline(xintercept = .5, color = "red")

# Accuracy
best_model.roc <- 
  ROCit::measureit(score = best_model$fitted.values, 
                   class = best_model$y,
                   measure = c("ACC", "SENS", "SPEC"))

tibble(
  Cutoff = best_model.roc$Cutoff,
  ACC = best_model.roc$ACC
) %>%
ggplot(aes(x = Cutoff, y = ACC)) +
  geom_point() +
  geom_line()

# ROC Curve
tibble(
  Cutoff = best_model.roc$Cutoff,
  SENS = best_model.roc$SENS,
  SPEC = best_model.roc$SPEC
) %>%
  pivot_longer(., cols = c("SENS", "SPEC"), values_to = "value", names_to = "metric") %>%
  ggplot(aes(x = Cutoff, y = value, color = metric)) +
  geom_point() + 
  geom_line()

tibble(
  Cutoff = best_model.roc$Cutoff,
  SENS = best_model.roc$SENS,
  SPEC = best_model.roc$SPEC,
  SUM = SENS + SPEC
) %>%
  arrange(-SUM, -SENS, -SPEC)
  
roc_empirical <- 
  rocit(score = best_model$fitted.values, class = best_model$y)
plot(roc_empirical, YIndex = F)
roc_empirical
summary(roc_empirical)
ciAUC(roc_empirical)

OptimalCutpoints::optimal.cutpoints(X = "pred_p", status = "y", 
                  data = data.frame(best_model.p), 
                  methods = c("Youden", "MaxSpSe", "MaxProdSpSe"), tag.healthy = 0)


library(plotROC)
best_model.p %>%
  ggplot(aes(m = pred_p, d = y)) + 
  geom_roc(n.cuts=0,labels=FALSE) + 
  style_roc(theme = theme_grey, xlab = "1 - Specificity", ylab = "Sensitivity") +
  geom_abline(slope = 1, intercept = 0)
