library(tidyverse)
library(survival)
library(survminer)
library(survMisc)

# Load the Ovarian data
data(ovarian)

ovarian <- ovarian %>%
  mutate(subject = 1:nrow(.),
         death = factor((1-fustat), labels = c("Censored", "Deceased")),
         ecog_good = 2-ecog.ps,
         r_disease = resid.ds - 1)

# plot with shapes to indicate censoring or event
ggplot(ovarian, aes(subject, futime)) + 
  geom_bar(stat = "identity", width = 0.1) + 
  geom_point(aes(color = death, shape = death), size = 6) +
  coord_flip() +
  theme_minimal() + 
  scale_color_manual(values = c("goldenrod", "firebrick")) +
  theme(legend.title = element_blank(),
        legend.position = "bottom")

# Create a survival object where time is "futime" and event is "fustat"
surv_object <- Surv(time = ovarian$futime, event = ovarian$fustat)

surv1.m <- survfit(surv_object ~ 1, data = ovarian)
summary(surv1.m)

surv2.m <- survfit(surv_object ~ rx, data = ovarian)
summary(surv2.m)

ggsurvplot(surv1.m, data = ovarian, surv.median.line = "hv")
ggsurvplot(surv2.m, data = ovarian)

# Get the Log-Rank test value for the effect of rx
survdiff(surv_object ~ rx, data = ovarian)
ggsurvplot(surv2.m, data = ovarian, pval = T)

# The Wilcoxon test value
survdiff(surv_object ~ rx, data = ovarian, rho = length(surv_object))


ovarian <-
  ovarian %>%
  mutate(age.q3 = cut(age,
                      breaks = quantile(age, probs = 0:3/3), include.lowest=T))
surv3.m <- survfit(surv_object ~ age.q3, data = ovarian)
summary(surv3.m)
ggsurvplot(surv3.m, data = ovarian, test.for.trend = T)
survdiff(surv_object ~ age.q3, data = ovarian)
pairwise_survdiff(Surv(futime, fustat) ~ age.q3, data = ovarian)

  # Cox PH Regression
cox1.m <- coxph(surv_object ~ rx, data = ovarian)
summary(cox1.m)
ggadjustedcurves(cox1.m, data = ovarian, variable = "rx")

cox2.m <- coxph(surv_object ~ rx + age, data = ovarian)
summary(cox2.m)
ggadjustedcurves(cox2.m, data = ovarian, variable = "rx")

# Schoenfeld residuals for PH assumption
cox.zph(cox1.m)
ggcoxzph(cox.zph(cox1.m))

cox.zph(cox2.m)
ggcoxzph(cox.zph(cox2.m))

# Assess linearity through MFP
mfp(Surv(futime, fustat) ~ fp(age) + rx, family = cox, data = ovarian)

# Assess linearity through Martingale residuals
residuals(cox2.m, type = "martingale") # In case we want to examine them
ggcoxfunctional(Surv(futime, fustat) ~ age + I(age^2) + log(age), data = ovarian, ylim = c(-1, 1))


# Cox-Snell Residuals
coxph(
  Surv(ovarian$fustat - residuals(cox2.m, type = "martingale"), fustat) ~ 1, 
  data = ovarian) %>%
  basehaz() %>%
  ggplot(aes(x = time, y = hazard)) + 
  geom_point() + 
  geom_smooth() +
  geom_abline(slope = 1, intercept = 0, color = "red")


ggcoxdiagnostics(cox2.m, type = "dfbeta", sline = F)
ggcoxdiagnostics(cox2.m, type = "deviance", sline = F, 
                 ox.scale = "observation.id") +
  geom_hline(yintercept = 2, color = "orange") +
  geom_hline(yintercept = -2, color = "orange")


# Stratified Cox Regression

cox3.m <- coxph(surv_object ~ rx + age + ecog_good + r_disease, data = ovarian)
summary(cox3.m)
cox.zph(cox3.m) %>% ggcoxzph()
ggadjustedcurves(cox3.m, data = ovarian, variable = "ecog_good")
basehaz(cox3.m) %>%
  mutate(inst_haz = hazard - lag(hazard, default = first(hazard))) %>%
  ggplot(aes(x = time, y = inst_haz)) +
  geom_line(color = "red") 

cox4.m <- coxph(surv_object ~ rx + age +  r_disease + strata(ecog_good), data = ovarian)
summary(cox4.m)
cox.zph(cox4.m) %>% ggcoxzph()
ggadjustedcurves(cox4.m, data = ovarian, variable = "ecog_good")
basehaz(cox4.m) %>%
  group_by(strata) %>%
  mutate(inst_haz = hazard - lag(hazard, default = first(hazard))) %>%
  ggplot(aes(x = time, y = inst_haz, color = strata)) +
  geom_line() 
