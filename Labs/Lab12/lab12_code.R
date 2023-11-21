library(tidyverse)
library(haven)
library(survival)
library(survminer)
library(survMisc)
library(lubridate)
library(mfp)
library(skimr)
library(magrittr)

rm(list = ls())

hiv <- haven::read_dta("data/hmohiv.dta")

skimr::skim(hiv)
head(hiv)

hiv <-
  hiv %>%
  mutate(entdate = dmy(entdate), 
         enddate = dmy(enddate),
         age.q4 = cut(age, breaks = quantile(age, prob = 0:4/4), include.lowest = T),
         death = 1 - censor
         ) 

## Question 1

hiv %>%
  arrange(time) %>%
  ggplot(aes(x = id, y = time)) + 
  geom_bar(stat = "identity", width = 0.1) + 
  geom_point(aes(color = factor(death), shape = factor(death)), size = 1) +
  coord_flip() +
  theme_minimal() + 
  scale_color_manual(values = c("goldenrod", "firebrick")) +
  theme(legend.title = element_blank(),
        legend.position = "bottom")

# 1c
surv_object <- Surv(hiv$time, hiv$death)
km_drug.m <- survfit(surv_object ~ drug, data = hiv)
ggsurvplot(km_drug.m, data = hiv, pval = T)

# 1d
km_age.m <- survfit(surv_object ~ age.q4, data = hiv)
ggsurvplot(km_age.m, data = hiv, pval = T)


## Question 2

# 2a
mfp(Surv(time, death) ~ fp(age) + drug, family = cox, data = hiv)

# 2b
ggcoxfunctional(Surv(time, death) ~ age + log(age) + I(age^2), data = hiv, f=1)


## Question 3

# 3a
cox_unadj.m <- coxph(surv_object ~ drug, data = hiv)
summary(cox_unadj.m)

# 3b
cox_adj.m <- coxph(surv_object ~ drug + age, data = hiv)
summary(cox_adj.m)
ggadjustedcurves(cox_adj.m, data = data.frame(hiv), variable = "drug")


## Question 4

# 4a
ggcoxzph(cox.zph(cox_adj.m))

# 4b
both_models <-
  list(
    km = km_drug.m,
    cox = survfit(cox_adj.m, newdata = data.frame(drug = 0:1, age = mean(hiv$age)))
  )

ggsurvplot(
  both_models,
  combine = T,
  linetype = c(1, 1, 2, 2)
)


## Question 5

# 5a
coxph(
  Surv(hiv$death - residuals(cox_adj.m, type = "martingale"), death) ~ 1, 
  data = hiv) %>%
  basehaz() %>%
  ggplot(aes(x = time, y = hazard)) + 
  geom_point() + 
  geom_smooth() +
  geom_abline(slope = 1, intercept = 0, color = "red")

# 5b
ggcoxdiagnostics(cox_adj.m, type = "deviance", sline = F, 
                 ox.scale = "observation.id") +
  geom_hline(yintercept = 2, color = "orange") +
  geom_hline(yintercept = -2, color = "orange")

residuals(cox_adj.m, type = "deviance") %>% 
  data.frame() %>% 
  rownames_to_column() %>% 
  filter(abs(.) > 2)

hiv[c(6, 21),]

# 5c
ggcoxdiagnostics(cox_adj.m, type = "dfbeta", sline = F) +
  geom_hline(data = bind_rows(
    tibble(val = abs(coefficients(cox_adj.m)*.1),
           covariate = names(coefficients(cox_adj.m))),
    tibble(val = -abs(coefficients(cox_adj.m)*.1),
           covariate = names(coefficients(cox_adj.m)))),
    aes(yintercept = val), color = "orange") 

residuals(cox_adj.m, type = "dfbeta") %>%
  data.frame() %>%
  set_colnames(names(coefficients(cox_adj.m))) %>%
  rownames_to_column() %>%
  filter(abs(drug) > coefficients(cox_adj.m)["drug"]/10)

hiv[c(21, 27, 49, 70), ]
