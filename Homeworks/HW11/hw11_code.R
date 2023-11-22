library(haven)
library(survival)
library(survminer)
library(tidyverse)
library(mfp)
library(sjPlot)

rm(list = ls())

addicts <- haven::read_dta("data/addicts.dta")
head(addicts)

skimr::skim(addicts)


## Question 1

# 1a
# fractional polynomials
mfp(Surv(survt, status) ~ fp(dose), family = cox, data = addicts)

# Martingale residuals
ggcoxfunctional(Surv(survt, status) ~ dose + log(dose) + I(dose^2), data = addicts, f = 1)

# 1b
surv_obj <- Surv(addicts$survt, addicts$status)
km <- survfit(surv_obj ~ dose + prison, data = addicts)
summary(km)

cox_unadj_m <- coxph(surv_obj ~ dose + prison, data = addicts)
summary(cox_unadj_m)
cox_adj_m <- coxph(surv_obj ~ dose + prison + clinic, data = addicts)
summary(cox_adj_m)

tab_model(cox_unadj_m, cox_adj_m)

# 1c
cox.zph(cox_adj_m)
ggcoxzph(cox.zph(cox_adj_m))

# 1d
cox_str_adj_m <- coxph(surv_obj ~ dose + prison + strata(clinic), data = addicts)
summary(cox_str_adj_m)
