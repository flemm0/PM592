library(haven)
library(survival)
library(survminer)
library(tidyverse)
library(mfp)
library(sjPlot)
library(magrittr)

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

# Cox-Snell residuals
coxph(
  Surv(addicts$status - residuals(cox_str_adj_m, type = "martingale"), status) ~ 1, 
  data = addicts) %>%
  basehaz() %>%
  ggplot(aes(x = time, y = hazard)) + 
  geom_point() + 
  geom_smooth() +
  geom_abline(slope = 1, intercept = 0, color = "red")

# deviance residuals
ggcoxdiagnostics(cox_str_adj_m, type = "deviance", sline = F, 
                 ox.scale = "observation.id") +
  geom_hline(yintercept = 2, color = "orange") +
  geom_hline(yintercept = -2, color = "orange")

influential_pts <- residuals(cox_str_adj_m, type = "deviance") %>% 
  data.frame() %>% 
  rownames_to_column() %>% 
  filter(abs(.) > 2)
influential_pts

addicts[pull(influential_pts, rowname), ]

# dfbeta
ggcoxdiagnostics(cox_str_adj_m, type = "dfbeta", sline = F) +
  geom_hline(data = bind_rows(
    tibble(val = abs(coefficients(cox_str_adj_m)*.1),
           covariate = names(coefficients(cox_str_adj_m))),
    tibble(val = -abs(coefficients(cox_str_adj_m)*.1),
           covariate = names(coefficients(cox_str_adj_m)))),
    aes(yintercept = val), color = "orange") 

high_dfbetas <- residuals(cox_str_adj_m, type = "dfbeta") %>%
  data.frame() %>%
  set_colnames(names(coefficients(cox_str_adj_m))) %>%
  rownames_to_column() %>%
  filter(abs(prison) > coefficients(cox_str_adj_m)["prison"]/10)

addicts[pull(high_dfbetas, rowname), ]
