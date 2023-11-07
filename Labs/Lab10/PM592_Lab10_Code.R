library(tidyverse)
library(mfp)
library(ROCit)
library(pROC)
# Download these files and put them in your working directory
source("plot_resid_lev_logistic.R")
source("logit_plot.R")
source("group_smooth.R")

sos_dat <- read_csv("sos_dat.csv")

with(sos_dat,
     gmodels::CrossTable(skip))

# Assign each observation an 80% chance of being in the training data set.
# Note this doesn't guarantee *exactly* 80% of observations in the training set,
# but since the sample is large enough it shouldn't be too big an issue.
set.seed(19)
sos_dat <-
sos_dat %>%
  mutate(training = sample(0:1, nrow(.),prob=c(.2, .8), replace=T))

sos_train <- sos_dat %>% filter(training == 1)
sos_test  <- sos_dat %>% filter(training == 0)

# Examine the functional form of continuous variables
mfp::mfp(skip ~ fp(odg), family = binomial, data = sos_train)
group_smooth("odg", "skip", sos_train)
logit_plot("odg", "skip", sos_train)

mfp::mfp(skip ~ fp(bully), family = binomial, data = sos_train)
group_smooth("bully", "skip", sos_train)
logit_plot("bully", "skip", sos_train)

mfp::mfp(skip ~ fp(bullied), family = binomial, data = sos_train)
group_smooth("bullied", "skip", sos_train, q = 10)
logit_plot("bullied", "skip", sos_train)

mfp::mfp(skip ~ fp(grade), family = binomial, data=sos_train)
group_smooth("grade", "skip", sos_train)
logit_plot("grade", "skip", sos_train)

group_smooth("age", "skip", sos_train)
logit_plot("age", "skip", sos_train)

mfp::mfp(skip ~ fp(dens), family = binomial, data = sos_train)
group_smooth("dens", "skip", sos_train)

mfp::mfp(skip ~ fp(recip), family = binomial, data = sos_train)
group_smooth("recip", "skip", sos_train, q=3)
logit_plot("recip", "skip", sos_train)
logit_plot("I(recip^2)", "skip", sos_train)

# Proceed with best subsets
# Find the best preliminary model
stepAIC(
  glm(skip ~ odg + dens + I(recip^2) + recip + age + factor(grade) + male + bully + bullied, 
      family=binomial, 
      data=sos_train %>% filter_all(~!is.na(.x))), 
      direction="both")

subset_skip_prelim <-
  glmulti::glmulti(skip ~ odg + dens + I(recip^2) + recip + age + factor(grade) + male + bully + bullied, 
          data = sos_train %>% filter_all(~!is.na(.x)),
          level=1, family = binomial, crit="aicc", confsetsize=128)


best_subset_skip_prelim <- 
  summary(subset_skip_prelim)$bestmodel %>% glm(., data = sos_train, family = binomial)

summary(best_subset_skip_prelim)

# Examine regression coefficients again for linearity, examine interactions, etc.
# There may be better models than the following one.
final_model <- 
  glm(skip ~ odg + dens +  age + male + bully + bullied + 
        odg*dens,
      family = binomial,
      data = sos_train)
summary(final_model)


ResourceSelection::hoslem.test(final_model$y, fitted(final_model), g=20)

plot_resid_lev_logistic(final_model)
LogisticDx::dx(final_model)


# Classification
DescTools::Conf(final_model, pos = 1)

final_model.p <-
  tibble(
    pred_p = final_model$fitted.values,
    y = final_model$y
  )

# Accuracy
final_model.roc <- 
  ROCit::measureit(score = final_model$fitted.values, 
                   class = final_model$y,
                   measure = c("ACC", "SENS", "SPEC"))

tibble(
  Cutoff = final_model.roc$Cutoff,
  ACC = final_model.roc$ACC
) %>%
ggplot(aes(x = Cutoff, y = ACC)) +
  geom_point() +
  geom_line()

# Cut Point
tibble(
  Cutoff = final_model.roc$Cutoff,
  SENS = final_model.roc$SENS,
  SPEC = final_model.roc$SPEC
) %>%
  pivot_longer(., cols = c("SENS", "SPEC"), values_to = "value", names_to = "metric") %>%
  ggplot(aes(x = Cutoff, y = value, color = metric)) +
  geom_point() + 
  geom_line()

tibble(
  Cutoff = final_model.roc$Cutoff,
  SENS = final_model.roc$SENS,
  SPEC = final_model.roc$SPEC,
  SUM = SENS + SPEC
) %>%
  arrange(-SUM, -SENS, -SPEC)


# ROC Curve
roc_empirical <- 
  rocit(score = final_model$fitted.values, class = final_model$y)
plot(roc_empirical, YIndex = F)
summary(roc_empirical)
ciAUC(roc_empirical)

OptimalCutpoints::optimal.cutpoints(X = "pred_p", status = "y", 
                  data = data.frame(final_model.p), 
                  methods = c("Youden", "MaxSpSe", "MaxProdSpSe"), tag.healthy = 0)


# Extend to the testing data set
test_model.p <-
  tibble(
    pred_p = predict(final_model, newdata = sos_test, type = "response"),
    y = sos_test$skip
  )

test_model.roc <- 
  ROCit::measureit(score = predict(final_model, newdata = sos_test, type = "response"), 
                   class = sos_test$skip,
                   measure = c("ACC", "SENS", "SPEC"))

# What are the SENS and SPEC in the testing data?
# We used a cutoff of 0.539 in the training data set
DescTools::Conf(x=test_model.p$pred_p, ref=test_model.p$y, pos = 1)

test_roc_empirical <-
  rocit(score = predict(final_model, newdata = sos_test, type = "response"), 
        class = sos_test$skip)
plot(test_roc_empirical, YIndex = F)
summary(test_roc_empirical)
ciAUC(test_roc_empirical)
