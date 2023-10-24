library(tidyverse)
library(readr)
library(skimr)
library(gmodels)
library(epitools)

okc <- readr::read_csv('data/okcprofiles_cleaned.csv')

okc <-
  okc %>%
  mutate(coupled = as.integer(status %in% c("married", "seeing someone")),
         straight = as.integer(orientation == "straight"),
         sign1 = word(sign, 1),
         religion1 = word(religion, 1),
         smoker = as.integer(smokes != "no"),
         male = as.integer(sex=="m"),
         drink1 = as.integer(drinks != "not at all"),
         smoke1 = as.integer(smokes != "no"))

skim(okc)

## Question 1

# 1a
okc %>%
  with(., CrossTable(x=male, y=smoker))

# 1b
okc %>%
  with(., epitools::oddsratio(male, smoker))

# 1c
glm(smoker ~ male, data = okc, family = binomial) %>% summary()

## Question 2

# 2a
okc %>%
  with(., CrossTable(x=male, y=straight, chisq=F, prop.t=F, prop.c=F))

# 2b
okc %>%
  with(., epitools::oddsratio(straight, smoker))

# 2c
glm(smoker ~ straight, data = okc, family = binomial) %>% summary()


## Question 3

# 3a
okc %>%
  ggplot(aes(x=age, y=smoker)) +
  geom_count() +
  geom_smooth()

okc %>%
  filter(!is.na(smoker)) %>%
  ggplot(aes(x=age, y=smoker, group=smoker)) +
  geom_boxplot()

# 3b
glm(smoker ~ age, data = okc, family = binomial) %>% summary()


## Question 4

# 4a
okc %>%
  group_by(religion1) %>%
  summarise(meansmoke = mean(smoker, na.rm=T)) %>%
  ggplot(aes(x=religion1, y=meansmoke)) +
  geom_point()

# 4b
glm(smoker ~ factor(religion1), data = okc, family = binomial) %>% summary()

# 4c
glm(smoker ~ factor(religion1), data = okc, family = binomial) %>% anova(test = "LRT")


## Question 5

# 5a
glm(smoker ~ factor(religion1) + age + straight + male, data = okc, family = binomial) %>%
  summary()

anova(
  glm(smoker ~ age + straight + male, data = okc %>% filter(!is.na(religion)), family = binomial),
  glm(smoker ~ factor(religion1) + age + straight + male, data = okc, family = binomial),
  test = "LRT"
)

# 5c
glm(smoker ~ factor(religion1) + age + straight + male, data = okc, family = binomial) %>%
  DescTools::PseudoR2()
