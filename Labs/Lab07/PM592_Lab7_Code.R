library(tidyverse)
library(GGally)

sos <- read_csv("ex_sos.csv")

to.z = function(x) {
  (x - mean(x, na.rm=T))/sd(x, na.rm=T)
}
# Create standardized help
sos <-
  sos %>%
  mutate(m_help.z = to.z(m_help),
         eth.f = factor(eth, levels=c("W", "B", "O")))

# Summary stats, make sure ranges etc make sense
sos %>%
  psych::describe()

sos %>%
  Hmisc::describe()

sos %>%
  skimr::skim()

# Run ggpairs
my_fn <- function(data, mapping, method="loess", ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point() + 
    geom_smooth(method=method, ...)
  p
}

sos %>%
  ggpairs(lower = list(continuous = my_fn))

# Trusted Adults
sos %>%
  group_by(tatot) %>%
  summarise(help_mean = mean(m_help.z, na.rm=T))

sos %>% 
  ggplot(aes(x = tatot, y = m_help.z)) + 
  geom_jitter(width = .1) + 
  geom_point(data = sos %>% 
               group_by(tatot) %>% 
               summarise(m_help.z = mean(m_help.z, na.rm=T)), 
             stat = "identity", size = 5, color = "red", shape = "diamond") +
  geom_line(data = sos %>% 
              group_by(tatot) %>% 
              summarise(m_help.z = mean(m_help.z, na.rm=T)), 
            stat = "identity", color = "red", size = 1.5)

# This next section is dose-response coding
# We create a full model that contains a linear
#  relationship between tatot and m_help.z, but
#  allows more flexibility for those who named
#  no adults.
# The Extra SS test tells us that this model is better (p=.02),
#  but for simplicity we will proceed with just a linear
#  model in subsequent sections.
sos <-
  sos %>%
  mutate(noad = as.integer(tatot==0),
         tatot1 = if_else(tatot>0, (tatot-1), 0))

tatot_full.m <- lm(m_help.z ~ noad + tatot1, data = sos)
summary(tatot_full.m)
tatot_reduced.m <- lm(m_help.z ~ tatot, data = sos)
summary(tatot_reduced.m)
anova(tatot_reduced.m, tatot_full.m)

# Age
sos %>%
  group_by(age) %>%
  summarise(help_mean = mean(m_help.z, na.rm=T))

sos %>%
  ggplot(aes(x = age, y = m_help.z)) +
  geom_point() +
  geom_smooth(method = "loess") +
  geom_smooth(method = "lm", formula = "y~x", color="red", se=F) +
  geom_smooth(method = "lm", formula = "y~x+x^2", color="green", se=F)

mfp(m_help.z ~ fp(age), data = sos) #Too complicated for this research question!
sos <-
  sos %>%
  mutate(age.c = age - mean(age, na.rm=T)) #Mean-center age for polynomials
age_full.m <- lm(m_help.z ~ age.c + I(age.c^2), data = sos)
summary(age_full.m)

# Gender
sos %>%
  group_by(gender) %>%
  summarise(mean_help = mean(m_help.z, na.rm=T))

sos %>%
  ggplot(aes(group = gender, y = m_help.z)) +
  geom_boxplot()

lm(m_help.z ~ gender, data = sos) %>% summary()

# Ethnicity
sos %>%
  group_by(eth) %>%
  summarise(mean_help = mean(m_help.z, na.rm=T))

sos %>%
  ggplot(aes(group = eth, y = m_help.z)) +
  geom_boxplot()

lm(m_help.z ~ eth, data = sos) %>% summary()

# Check Confounding
lm(m_help.z ~ tatot, data = sos) %>% 
  summary()
lm(m_help.z ~ tatot + age.c + I(age.c^2), data = sos) %>% 
  summary() # Almost no change in estimates
lm(m_help.z ~ tatot + gender, data = sos) %>% 
  summary() # Almost no change in estimates
lm(m_help.z ~ tatot + eth.f, data = sos) %>% 
  summary() 
# Let's also examine all covariates together:
lm(m_help.z ~ tatot + age.c + (age.c^2) + gender + eth, data = sos) %>%
  summary() 

# We could now examine interactions
# but there is no hypothesis relating to interactions

m_help.m <-
  lm(m_help.z ~ tatot, data = sos)

ggfortify::autoplot(m_help.m, which = 1:6)

car::residualPlots(m_help.m)
car::qqPlot(m_help.m)

library(olsrr)
ols_plot_dfbetas(m_help.m)
ols_plot_dffits(m_help.m)
ols_plot_resid_qq(m_help.m)

ols_plot_resid_lev(m_help.m)

#340, 278

# Examine the outliers' records
sos %>%
  bind_cols(
    tibble(
      pred = predict(m_help.m)
    )
  ) %>%
  .[c(278, 340),]
    
# Re-fit the model with these observations excluded (sensitivity analysis)
lm(m_help.z ~ tatot1, 
   data = sos[-c(278, 340),]) %>% 
  summary()

# There's some slight change in estimates but the conclusions remain the same