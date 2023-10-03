library(tidyverse)
library(haven)
library(readxl)
library(interactions)

chs <- read_csv("subjdata.csv")

chs <- 
  chs %>%
  mutate(race.f = factor(race,
                         levels=3:4,
                         labels=c("Hispanic",
                                  "Non-Hispanic White")),
         townname.f = factor(townname))

# 1a
chs %>%
  ggplot(aes(x = race.f, y = fev)) +
  geom_boxplot()

# 1b
chs %>%
  ggplot(aes(x = townname.f, y = fev)) +
  geom_boxplot()

# 2a
summary(lm(fev ~ race.f, data = chs))

# 2b
summary(lm(fev ~ race.f + townname.f, data = chs))

# 2e
chs %>%
  group_by(townname) %>%
  summarise(mean_hisp = mean(race2 == "H"))

# 3a
summary(lm(fev ~ factor(race2) + factor(townname) + asthma, data = chs))

# 4a
chs %>%
  ggplot(aes(x = age, y = fev)) +
  geom_point() +
  geom_smooth(method = "lm")

# 4b
chs %>%
  ggplot(aes(x = age, y = fev, color = townname.f)) +
  geom_point() +
  geom_smooth(method = "lm")

# 4d
m1 <- lm(fev ~ age*townname.f, data = chs)

# 4c
m0 <- lm(fev ~ age + townname.f, data = chs)

# 4e
anova(m0, m1)

# 4f
interact_plot(m1, pred = age, modx = townname.f)
sim_slopes(m1, pred = age, modx = townname.f)

# 5a
chs %>%
  group_by(townname) %>%
  summarise(no2 = mean(no2),
            ozone = mean(ozone),
            pm10 = mean(pm10)) %>%
  pivot_longer(cols = c("no2", "ozone", "pm10"),
               names_to = "pollutant",
               values_to = "level") %>%
  ggplot(aes(x = pollutant, y = level, fill = townname)) +
  geom_col(position = "dodge") 

# 6a
chs %>%
  ggplot(aes(x = pm10, y = fev)) +
  geom_point() +
  geom_smooth(method = "lm")

# 6b
summary(lm(fev ~ pm10, data = chs))

# 6c
summary(lm(fev ~ pm10 + age, data = chs))

# 7a
chs %>%
  ggplot(aes(x = age, y = fev, color = factor(pm10))) +
  geom_point() +
  geom_smooth(method = "lm") 

# 7b
m0 <- lm(fev ~ age + pm10, data = chs)
summary(m0)

# 7c
m1 <- lm(fev ~ age*pm10, data = chs)
summary(m1)

# 7e
interact_plot(m1, pred = age, modx = pm10)
sim_slopes(m1, pred = age, modx = pm10)
interact_plot(m1, pred = age, modx = pm10, linearity.check = T)
