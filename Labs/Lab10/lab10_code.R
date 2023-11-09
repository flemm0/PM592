library(tidyverse)
library(mfp)
library(ROCit)
library(pROC)
library(readr)
library(gmodels)
library(MASS)
library(glmulti)

rm(list = ls())

source("Labs/Lab09/plot_resid_lev_logistic.R")
source("Labs/Lab09/logit_plot.R")
source("Labs/Lab09/group_smooth.R")

sos_dat <- readr::read_csv("data/sos_dat.csv")
sos_dat <- na.omit(sos_dat)

head(sos_dat)

skimr::skim(sos_dat)

with(sos_dat, gmodels::CrossTable(skip))

set.seed(19)

## Question 1

sos_dat$train <- sample(c(FALSE, TRUE), nrow(sos_dat), replace=TRUE, prob=c(0.2,0.8))

sos_train <- sos_dat[sos_dat$train,]
sos_test <- sos_dat[!sos_dat$train,]

## Question 2

## assessing functional form for each of the continuous variables

logit_plot("odg", "skip", sos_train)
group_smooth("odg", "skip", sos_train)
mfp::mfp(skip ~ fp(odg), data = sos_train, family = binomial)
# out degree appears to be linear
glm(skip ~ odg, family = binomial, data = sos_train) %>% summary() # out degree is significant

logit_plot("bully", "skip", sos_train)
group_smooth("bully", "skip", sos_train)
mfp::mfp(skip ~ fp(bully), data = sos_train, family = binomial)
# bully appears to be linear
glm(skip ~ bully, family = binomial, data = sos_train) %>% summary() # bully is significant

logit_plot("bullied", "skip", sos_train)
group_smooth("bullied", "skip", sos_train)
mfp::mfp(skip ~ fp(bullied), data = sos_train, family = binomial)
# mfp says a log transformation for 'bullied', but from the group smooth it looks like that a linear approximation would be sufficient
glm(skip ~ bullied, family = binomial, data = sos_train) %>% summary()
glm(skip ~ I(log(((bullied+2.9)/10))), family = binomial, data = sos_train) %>% summary() # bullied is significant
# transforming the bullied variables to log values offers a 11 decrease in AIC - will use log transformed variable

logit_plot("age", "skip", sos_train)
group_smooth("age", "skip", sos_train)
mfp::mfp(skip ~ fp(age), data = sos_train, family = binomial)
# age appears to be linear
glm(skip ~ age, family = binomial, data = sos_train) %>% summary() # age is significant

logit_plot("dens", "skip", sos_train)
group_smooth("dens", "skip", sos_train)
mfp::mfp(skip ~ fp(dens), data = sos_train, family = binomial)
# density appears to be linear
glm(skip ~ dens, family = binomial, data = sos_train) %>% summary() # density is significant

logit_plot("recip", "skip", sos_train)
#group_smooth("recip", "skip", sos_train)
mfp::mfp(skip ~ fp(recip), data = sos_train, family = binomial)
logit_plot("I(recip^2)", "skip", sos_train)
# reciprocity appears to be quadratic
glm(skip ~ I(recip^2), family = binomial, data = sos_train) %>% summary() # reciprocity is significant

## assessing significance of grade and gender
logit_plot("grade", "skip", sos_train)
group_smooth("grade", "skip", sos_train)
mfp::mfp(skip ~ fp(grade), family = binomial, data = sos_train)
glm(skip ~ grade, family = binomial, data = sos_train) %>% summary() # grade is significant
# grade appears to be linear


logit_plot("tatot", "skip", sos_train)
group_smooth("tatot", "skip", sos_train)
mfp::mfp(skip ~ fp(tatot), family = binomial, data = sos_train)
glm(skip ~ log(((tatot+1)/10)) + I(((tatot+1)/10)^0.5), family = binomial, data = sos_train) %>% summary() #
# use x + ln(x) transformation for total adults

glm(skip ~ male, family = binomial, data = sos_train) %>% summary() # gender is significant


# preliminary model

m1 <- glm(skip ~ bully + I(log(((bullied+2.9)/10))) + odg + age + 
            dens + I(recip^2) + grade + male + log(((tatot+1)/10)) + I(((tatot+1)/10)^0.5),
    family = binomial,
    data = sos_train) 
summary(m1)

# remove grade, correlated with age
m2 <- glm(skip ~ bully + I(log(((bullied+2.9)/10))) + odg + age + 
            dens + I(recip^2) + male + log(((tatot+1)/10)) + I(((tatot+1)/10)^0.5),
          family = binomial,
          data = sos_train)
summary(m2)

stepAIC(m2, family = binomial, direction = "both")

subset_skip_prelim <- 
  glmulti::glmulti(skip ~ bully + I(log(((bullied+2.9)/10))) + odg + age + 
                     dens + I(recip^2) + grade + male + log(((tatot+1)/10)) + I(((tatot+1)/10)^0.5), 
                 data = sos_train %>% filter_all(~!is.na(.x)),
                 level=1, family = binomial, crit="aicc", confsetsize=128)
best_subset_skip_prelim <- 
  summary(subset_skip_prelim)$bestmodel %>% glm(., data = sos_train, family = binomial)
summary(best_subset_skip_prelim)


ResourceSelection::hoslem.test(m2$y, fitted(m2), g=20) 
plot_resid_lev_logistic(m2) # 6 influential points, but not strong outliers
LogisticDx::dx(m2)
DescTools::Conf(m2, pos = 1)
# accuracy = 0.63 (0.62, 0.64)

# get predicted probabilities
m2.p <-
  tibble(
    pred_p = m2$fitted.values,
    y = m2$y
  )

# get ROC measurements
roc <- ROCit::measureit(score = m2$fitted.values, 
                   class = m2$y,
                   measure = c("ACC", "SENS", "SPEC"))

# plot accuracy at different cutoff values
tibble(
  Cutoff = roc$Cutoff,
  ACC = roc$ACC
) %>%
  ggplot(aes(x = Cutoff, y = ACC)) +
  geom_point() +
  geom_line() # optimal cutoff seems to be about .5

# plot sensitvity and specificity tradeoff
tibble(
  Cutoff = roc$Cutoff,
  SENS = roc$SENS,
  SPEC = roc$SPEC
) %>%
  pivot_longer(., cols = c("SENS", "SPEC"), values_to = "value", names_to = "metric") %>%
  ggplot(aes(x = Cutoff, y = value, color = metric)) +
  geom_point() + 
  geom_line()
# again, optimal cutoff is about .5

tibble(
  Cutoff = roc$Cutoff,
  SENS = roc$SENS,
  SPEC = roc$SPEC,
  SUM = SENS + SPEC
) %>%
  arrange(-SUM, -SENS, -SPEC) # 0.511 cutoff is the highest

# ROC
roc_empirical <- 
  rocit(score = m2$fitted.values, class = m2$y)
plot(roc_empirical, YIndex = F)
summary(roc_empirical)
ciAUC(roc_empirical)

OptimalCutpoints::optimal.cutpoints(X = "pred_p", status = "y", 
                                    data = data.frame(m2.p), 
                                    methods = c("Youden", "MaxSpSe", "MaxProdSpSe"), tag.healthy = 0)


## Question 3
m2_test.p <-
  tibble(
    pred_p = predict(m2, newdata = sos_test, type = "response"),
    y = sos_test$skip
  )

test.roc <- 
  ROCit::measureit(score = predict(m2, newdata = sos_test, type = "response"), 
                   class = sos_test$skip,
                   measure = c("ACC", "SENS", "SPEC"))

# DescTools::Conf(m2_test.p$pred_p, ref=m2_test.p$y, pos = 1) # seems to take forever to run, using `caret` instead
library(caret)
binary_outcome <- ifelse(m2_test.p$pred_p > 0.511, 1, 0)
confusionMatrix(as.factor(binary_outcome), as.factor(m2_test.p$y))

test_roc_empirical <-
  rocit(score = predict(m2, newdata = sos_test, type = "response"), 
        class = sos_test$skip)
plot(test_roc_empirical, YIndex = F)
summary(test_roc_empirical)
ciAUC(test_roc_empirical)
