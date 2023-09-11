library(tidyverse)
library(GGally)
library(mfp)
# Load the real estate data

re <- read_csv("real_estate.csv") %>%
  mutate(age.c = age - mean(age, na.rm=T))

# Show relationship between price and age
re %>%
  ggplot(aes(x = age, y = area)) +
  geom_point(alpha = .5)

re %>%
  ggplot(aes(x = age, y = area)) +
  geom_point(alpha = .5) +
  geom_smooth(method = "lm", color = "#F8766D")

colors <- c("Linear" = "#F8766D", "Quadratic" = "#BB9D00", "Cubic" = "#00B81F")

re %>%
  ggplot(aes(x = age, y = area)) +
  geom_point(alpha = .5) +
  geom_smooth(aes(color = "Linear"), method = "lm", formula = "y ~ x", se = F) +
  geom_smooth(aes(color = "Quadratic"), method = "lm", formula = "y ~ x + I(x^2)", se = F) +
  geom_smooth(aes(color = "Cubic"), method = "lm", formula = "y ~ x + I(x^2) + I(x^3)", se = F) +
  scale_color_manual(values = colors)

# Fit the model up to a cubic term

lm(area ~ age + I(age^2) + I(age^3), data = re) %>% anova()
lm(area ~ age + I(age^2) + I(age^3), data = re) %>% car::Anova()

# Decision: fit the quadratic polynomial model
lm(area ~ age + I(age^2), data = re) %>% summary()

# Examine correlations among polynomial terms
re %>%
  select(age) %>%
  mutate(age2 = age*age,
         age3 = age2*age) %>%
  cor()

re %>%
  select(age.c) %>%
  mutate(age2.c = age.c*age.c,
         age3.c = age2.c*age.c) %>%
  cor()

# Fractional polynomials

mfp(area ~ fp(age), data = re) 


# Health Expenditure Data
hccp <- read_csv("health_expense.csv") %>%
  pivot_longer(
    cols = -Location, 
    values_to = "hepc",
    names_to = "year",
    names_pattern = "(.*)__Health Spending per Capita") %>%
  mutate(yearnum = as.integer(year)-2000) %>%
  filter(yearnum > 0)

# Plot and examine the linear model
hccp %>%
  ggplot(aes(x = yearnum, y = hepc)) +
  geom_point() +
  geom_smooth(method = "lm")

lm(hepc ~ yearnum, data = hccp) %>% autoplot()

# Plot and examine the spline model
# Here the abline refers to if the slope for year 2000-2010 had been extended
hccp %>%
  ggplot(aes(x = yearnum, y = hepc)) +
  geom_point() +
  geom_abline(color = "red", slope = 314.89, intercept = 4242.85) +
  geom_smooth(method = "lm", formula = "y ~ x + I((x-10)*(x>10))")
  
lm(hepc ~ yearnum + I((yearnum-10)*(yearnum>10)), data = hccp) %>% summary()
lm(hepc ~ yearnum + I((yearnum-10)*(yearnum<=10)), data = hccp) %>% summary()

# How's California doing?
hccp %>%
  ggplot(aes(x = yearnum, y = hepc)) +
  geom_point(data = filter(hccp, Location != "California")) +
  geom_point(data = filter(hccp, Location == "California"), color = "red")


# Overfitting Example

set.seed(1919)
ex1 <-
  tibble(
    x = -15:15,
    y = 5 + (x) + .25*(x)^2 + rnorm(31, 0, 15)
  )

ex1 %>%
  ggplot(aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = "y ~ x + I(x^2)")

lm(y ~ x + I(x^2), data = ex1) %>% summary()

lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8), data = ex1) %>%
  summary()

ex1 %>%
  ggplot(aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm",
              formula = "y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8)")


# Overfitting with Real Estate

lm(y ~ x + I(x^2), data = ex1) %>% pred_r_squared()

lm(y ~ x + I(x^2) + I(x^3) + I(x^4) + I(x^5) + I(x^6) + I(x^7) + I(x^8), data = ex1) %>%
  pred_r_squared()
