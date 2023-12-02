library(tidyverse)
library(haven)
library(MASS)
library(emmeans)
library(mfp)
library(AER)
library(sjPlot)

rm(list = ls())

source("Lecture_Materials/Week11/pois_gof.R")

fiji <- haven::read_dta("data/fiji.dta")

head(fiji)
str(fiji)
names(fiji)

## Question 1

# 1b
null_model <- glm(totborn ~ 1 + offset(log(n)), family = poisson, data = fiji)
summary(null_model)
exp(1.376346 - 1.96 * 0.009712)
exp(1.376346 + 1.96 * 0.009712)

pois_dev_gof(null_model)
pois_pearson_gof(null_model)

# 1c
educ_lin_model <- glm(totborn ~ educ + offset(log(n)), family = poisson, data = fiji)
educ_fact_model <- glm(totborn ~ factor(educ) + offset(log(n)), family = poisson, data = fiji)
summary(educ_lin_model)
summary(educ_fact_model)
anova(educ_lin_model, educ_fact_model, test="LRT") # it appears that encoding education as a factor variable improves model fit significantly (p<0.001)
emmeans(educ_fact_model, "educ", offset = log(1), type = "response")
pois_dev_gof(educ_fact_model)
pois_pearson_gof(educ_fact_model)

# determine functional form of dur
anova(
  glm(totborn ~ factor(educ) + factor(res) + dur + offset(log(n)), family = poisson, data = fiji),
  glm(totborn ~ factor(educ) + factor(res) + factor(dur) + offset(log(n)), family = poisson, data = fiji),
  test="LRT"
)

# 1d
educ_adj_model <- glm(totborn ~ factor(educ) + res + dur + offset(log(n)), family = poisson, data = fiji)
anova(educ_fact_model, educ_adj_model, test = "LRT")
summary(educ_adj_model)
sjPlot::tab_model(educ_fact_model, educ_adj_model)
pois_dev_gof(educ_adj_model)
pois_pearson_gof(educ_adj_model)


## Question 2

# 2a
AER::dispersiontest(educ_adj_model)
educ_nb_model <- MASS::glm.nb(totborn ~ factor(educ) + res + dur + offset(log(n)), data = fiji)
summary(educ_nb_model)
