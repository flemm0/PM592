library(readr)
library(tidyverse)
library(interactions)

data <- readr::read_csv("data/subjdata.csv")
dim(data)

data <-
  data %>%
  filter(race %in% c(3,4)) %>%
  mutate(race.f = as.factor(race)) %>%
  mutate(townname.f = as.factor(townname))

## Question 1

# 1a
ggplot(data, aes(x=race.f, y=fev)) +
  geom_boxplot() +
  theme_bw() +
  scale_x_discrete(labels=c("hispanic", "non-hispanic white"))

# 1b
ggplot(data, aes(x=townname.f, y=fev)) +
  geom_boxplot() +
  theme_bw()


## Question 2

# 2a
m2a <- lm(fev ~ race.f, data=data)
summary(m2a)

# 2b
m2b <- lm(fev ~ race.f + townname.f, data=data)
summary(m2b)

# 2e
data %>%
  group_by(townname.f, race.f) %>%
  summarise(count = n()) %>%
  group_by(townname.f) %>%
  mutate(total = sum(count)) %>%
  mutate(pct_total = count / total)


## Question 3

# 3a
m3a <- lm(fev ~ race.f + asthma, data=data)
summary(m3a)


## Question 4

# 4a
ggplot(data, aes(x=age, y=fev)) +
  geom_point() +
  theme_bw()

# 4b
ggplot(data, aes(x=age, y=fev, color=townname.f)) +
  geom_point() +
  geom_smooth(method = "lm") +
  theme_bw()

# 4c
m4c <- lm(fev ~ age + townname.f, data = data)
summary(m4c)

# 4d
m4d <- lm(fev ~ age + townname.f + age*townname.f, data=data)
summary(m4d)

# 4c
anova(m4c, m4d)

# 4f
interact_plot(m4d, pred = age, modx = townname.f)
sim_slopes(m4d, pred = age, modx = townname.f)


## Question 5

# 5a
data %>%
  group_by(townname) %>%
  summarise(no2 = mean(no2),
            ozone = mean(ozone),
            pm10 = mean(pm10)) %>%
  pivot_longer(cols = c("no2", "ozone", "pm10"),
               names_to = "pollutant",
               values_to = "level") %>%
  ggplot(aes(x = pollutant, y = level, fill = townname)) +
  geom_col(position = "dodge") 


## Question 6

# 6a
ggplot(data, aes(x=no2, y=fev)) +
  geom_point() +
  geom_smooth(method = "lm")

# 6b
summary(lm(fev ~ no2, data = data))


## Question 7

# 7a
ggplot(data, aes(x=age, y=fev, color=factor(no2))) +
  geom_point() +
  geom_smooth(formula = y~x, method="lm")

# 7b
m7b <- lm(fev ~ age + no2, data=data)
summary(m7b)

# 7c
m7c <- lm(fev ~ age*no2, data=data)
summary(m7c)

# 7e
interact_plot(m7c, pred = age, modx = no2)
sim_slopes(m7c, pred = age, modx = no2)
