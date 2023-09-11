library(tidyverse)

z.test.prop <- function(x, pi0=.5) {
  p = mean(x, na.rm=T)
  n = length(!is.na(x))
  se_p = sqrt(p*(1-p)/n)
  se_pi0 = sqrt(pi0*(1-pi0)/n)
  ci.l = p - 1.96*se_p
  ci.u = p + 1.96*se_p
  z = (p - pi0)/se_pi0
  pval = 2*(1-pnorm(abs(z)))
  
  tibble(
    p, n, ci.l, ci.u, pi0, z, pval
  )
}

z.test.prop(chs$asthma, .1)

# Entering in your own frequencies for chi-square
tibble(
  aspirin = c(1, 1, 0, 0),
  mi = c(1, 0, 1, 0),
  freq = c(104, 10933, 189, 10845)
) %>%
  xtabs(freq ~ aspirin + mi, data = .) %>%
  chisq.test(correct = F)

# Using existing data for frequencies
chs %>%
  with(.,
       table(asthma, male)) %>%
  chisq.test(correct = F)

# A naive model for asthma
chs %>%
  count(asthma, mother_asthma) %>%
  ggplot(aes(x = mother_asthma, y = asthma, size = n)) +
  geom_point(alpha = .5)

lm(asthma ~ mother_asthma + father_asthma, data = chs) %>%
  autoplot(which = 1:3)

# Example where outcome falls outside (0,1)
lm(asthma ~ mother_asthma + father_asthma + wheeze + hayfever + smoke + allergy, data = chs) %>%
  summary()


# Asthma and parents' asthma
chs <-
  chs %>%
  mutate(asthma_parent = as.integer(mother_asthma | father_asthma))

chs %>%
  with(., table(asthma, asthma_parent)) %>%
  chisq.test(correct = F)

glm(asthma ~ asthma_parent, data = chs, family = binomial) %>% summary()

# Asthma and BMI
# Scatter plot
chs %>%
  ggplot(aes(x = bmi, y = asthma)) +
  geom_point(alpha=.5) +
  geom_smooth()

glm(asthma ~ bmi, data = chs, family = binomial) %>% summary()

glm(asthma ~ bmi, data = chs, family = binomial) %>% anova(test = "LRT")
