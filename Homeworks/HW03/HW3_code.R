library(tidyverse)
library(ggfortify)
library(psych)


setwd("\\\\wsl.localhost/Ubuntu/home/flemm0/school_stuff/USC_Fall_2023/PM592/Homeworks/HW03")

## Question 1

wcgs <- readRDS("../HW01/wcgs.rds")

# 1a
mod1a <- lm(sbp ~ bmi, data = wcgs)
summary(mod1a)
plot(mod1a)
#autoplot(mod1a)

# 1b
ggplot(wcgs, aes(y=sbp_log, x=bmi)) +
  geom_point()

# 1d
wcgs <-
  wcgs %>%
  mutate(bmi_c = bmi - mean(bmi))
mod1d <- lm(sbp_log ~ bmi_c, data = wcgs)
summary(mod1d)
plot(mod1d)


## Question 2

# 2a
ggplot(wcgs, aes(x=dibpat, y=sbp)) +
  geom_boxplot() +
  theme_bw()

# 2b
ggplot(wcgs, aes(x=dibpat, y=sbp)) +
  geom_point() +
  stat_summary(geom = "line", fun = mean, group = 1) +
  theme_bw()

# 2c
wcgs$dibpat.f <- as.factor(wcgs$dibpat)
mod2c <- lm(sbp ~ dibpat.f, data = wcgs)
summary(mod2c)
plot(mod2c)

t.test(sbp ~ dibpat.f, data = wcgs)


## Question 3

# 3a
wcgs <- 
  wcgs %>%
  mutate(bmi_cat = cut(bmi, 
                       breaks = c(-Inf, 18.5, 25, 30, Inf),
                       labels = c("Underweight", "Healthy weight", "Overweight", "Obsese"),
                       right = F, include.lowest = F))
table(wcgs$bmi_cat)

# 3b
wcgs$bmi_cat <- relevel(wcgs$bmi_cat, ref = "Healthy weight")

# 3d
mod3d <- lm(sbp ~ bmi_cat, data = wcgs)
summary(mod3d)
