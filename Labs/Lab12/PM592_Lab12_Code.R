library(tidyverse)
library(survival)
library(survminer)
library(survMisc)
library(haven)
library(lubridate)
library(mfp)

# Load the data
HIV <-
  read_dta("hmohiv.dta") %>%
  mutate(entdate.d = dmy(entdate),
         enddate.d = dmy(enddate),
         age.q4 = cut(age, breaks = quantile(age, prob = 0:4/4), include.lowest = T),
         death = 1 - censor)


# plot with shapes to indicate censoring or event
HIV %>%
  arrange(time) %>%
  ggplot(aes(x = id, y = time)) + 
  geom_bar(stat = "identity", width = 0.1) + 
  geom_point(aes(color = factor(death), shape = factor(death)), size = 1) +
  coord_flip() +
  theme_minimal() + 
  scale_color_manual(values = c("goldenrod", "firebrick")) +
  theme(legend.title = element_blank(),
        legend.position = "bottom")

# Create the survival object
surv_object <- Surv(HIV$time, HIV$death)

# 1a
km_drug.m <- survfit(surv_object ~ drug, data = HIV)
ggsurvplot(km_drug.m, data = HIV, pval = T)

# 1b
km_age.m <- survfit(surv_object ~ age.q4, data = HIV)
ggsurvplot(km_age.m, data = HIV, pval = T)
pairwise_survdiff(Surv(time, death) ~ age.q4, data = HIV)

# 2a
mfp(Surv(time, death) ~ fp(age) + drug, family = cox, data = HIV)

# 2b
ggcoxfunctional(Surv(time, death) ~ age + log(age) + I(age^2), data = HIV)


# 3a
cox_unadj.m <- coxph(surv_object ~ drug, data = HIV)
summary(cox_unadj.m)

# 3b
cox_adj.m <- coxph(surv_object ~ drug + age, data = HIV)
summary(cox_adj.m)
ggadjustedcurves(cox_adj.m, data = data.frame(HIV), variable = "drug")


# 4a
ggcoxzph(cox.zph(cox_adj.m))

# 4b
both_models <-
  list(
    km = km_drug.m,
    cox = survfit(cox_adj.m, newdata = data.frame(drug = 0:1, age = mean(HIV$age)))
  )

ggsurvplot(
  both_models,
  combine = T,
  linetype = c(1, 1, 2, 2)
)

# 5a
coxph(
  Surv(HIV$death - residuals(cox_adj.m, type = "martingale"), death) ~ 1, 
  data = HIV) %>%
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

HIV[6,]

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

HIV[c(21, 27, 49, 70), ]
