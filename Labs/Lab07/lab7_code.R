library(readr)
library(tidyverse)
library(skimr)
library(GGally)
library(mfp)
library(olsrr)

sos <- readr::read_csv("data/ex_sos.csv")

str(sos)


## Question 1

# 1a
sos <- sos %>%
  mutate(m_help.z = scale(m_help)[,1])

# 1b
skim(sos)


## Question 2

# 2a
ggpairs(sos)


## Question 3

# 3a
sos %>%
  group_by(tatot) %>%
  summarize(mean(m_help.z))

# 3b
sos %>%
  ggplot(aes(x = age, y = m_help.z)) +
  geom_point() +
  geom_smooth(method = "loess") +
  geom_smooth(method = "lm", formula = "y~x", color="red", se=F) +
  geom_smooth(method = "lm", formula = "y~x+x^2", color="green", se=F)

mfp(m_help.z ~ fp(age.c), data = sos) # linear
lm(m_help.z ~ age.c + I(age.c^2), data = sos) %>% summary() # quadratic

lm(m_help.z ~ age.c, data = sos) %>% summary()

## Question 4

# 4a
sos %>%
  group_by(age) %>%
  summarise(mean(m_help.z))

# 4b
sos %>%
  ggplot(aes(x = age, y = m_help.z)) +
  geom_point() +
  geom_smooth(method = "loess") +
  geom_smooth(method = "lm", formula = "y~x", color="red", se=F)

# 4c
sos <- sos %>%
  mutate(age.c = age - mean(age))
lm(m_help.z ~ age.c + I(age.c^2), data = sos) %>%
  summary()


## Question 5

# 5a
sos %>%
  group_by(gender) %>%
  summarise(mean(m_help.z))

# 5b
sos %>%
  ggplot(aes(x=factor(gender), y=m_help.z)) +
  geom_boxplot()

# 5c
lm(m_help.z ~ gender, data = sos) %>% summary()


## Question 6

# 6a
sos %>%
  group_by(eth) %>%
  summarise(mean(m_help.z))

# 6b
sos %>%
  ggplot(aes(x=factor(eth), y=m_help.z)) +
  geom_boxplot()

# 6c
lm(m_help.z ~ as.factor(eth), data = sos) %>% summary()


## Question 7

# 7a
lm(m_help.z ~ tatot + age + gender + eth, data = sos) %>% summary()

# 7b
m <- lm(m_help.z ~ tatot, data = sos)
summary(m)


## Question 8

# 8a
autoplot(m)

# 8b
ols_plot_resid_stud(m)
#ols_plot_dffits(m, print_plot = FALSE)
#ols_plot_dfbetas(m, print_plot = FALSE)
ols_plot_resid_lev(m)

lm(m_help.z ~ tatot, data = sos[-c(252, 340),]) %>% summary()


## Question 9
adj_m <- lm(m_help.z ~ tatot + age + gender + eth, data = sos)
data.frame(
  unadjusted = c(m$coefficients, NA, NA, NA, NA),
  adjusted = adj_m$coefficients,
  row.names = names(adj_m$coefficients)
)

