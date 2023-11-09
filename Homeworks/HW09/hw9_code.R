library(tidyverse)
library(haven)
library(skimr)
library(ResourceSelection)
library(DescTools)
library(ROCit)
library(pROC)

source("Labs/Lab09/plot_resid_lev_logistic.R")


rm(list = ls())

fg <- read_dta('data/focusgroup.dta')

## Question 1

# 1a

fg$income.q <- cut(fg$income, quantile(fg$income), include.lowest = T)
fg$profession.f <- factor(fg$profession, levels=c(1, 0, 2, 3))

#skimr::skim(fg)

set.seed(11)
fg$train <- sample(c(F,T), nrow(fg), prob = c(.2, .8), replace = T)

fg_train <- fg[fg$train, ]
fg_test <- fg[!fg$train, ]

m <- glm(participated ~ income.q + profession.f + isfemale + white, family = binomial, data = fg_train)
summary(m)


# 1b

hoslem.test(m$y, fitted(m))
unclass(gof(m, plotROC=F))$chiSq[3, ]
DescTools::PseudoR2(m)
plot_resid_lev_logistic(m)


# 1c

m.p <-
  tibble(
    pred_p = m$fitted.values,
    y = m$y
  )

roc <- ROCit::measureit(score = m$fitted.values, 
                        class = m$y,
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

DescTools::Conf(m, cutoff = 0.38, pos=1)

roc_empirical <- rocit(score = m$fitted.values, class = m$y)
plot(roc_empirical, YIndex = F)
summary(roc_empirical)
ciAUC(roc_empirical)


# 1d

m.test.p <-
  tibble(
    pred_p = predict(m, newdata = fg_test, type = "response"),
    y = fg_test$participated
  )

test.roc <- 
  ROCit::measureit(score = predict(m, newdata = fg_test, type = "response"), 
                   class = fg_test$participated,
                   measure = c("ACC", "SENS", "SPEC"))
test_roc_empirical <-
  rocit(score = predict(m, newdata = fg_test, type = "response"), 
        class = fg_test$participated)
plot(test_roc_empirical, YIndex = F)
summary(test_roc_empirical)
ciAUC(test_roc_empirical)
