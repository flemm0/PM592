library(tidyverse)
library(haven)

no2 <- read_sas("./data/no2.sas7bdat")

no2_ss <- no2 %>%
  filter(townname == "Lake Elsinore")

# 1
no2_ss %>%
  ggplot(aes(x=fwydist, y=NO2)) +
  geom_point() +
  geom_smooth(method="lm", se=T, linetype="dashed", color="red") +
  labs(title="Townname: Lake Elsinore")


# 2
mod <- lm(NO2 ~ fwydist, data = no2_ss)
summary(mod)


# 3
no2_ss <- no2_ss %>%
  mutate(fwydist_c = fwydist - mean(fwydist))

mod2 <- lm(NO2 ~ fwydist_c, data = no2_ss)
summary(mod2)


# 4
no2_ss <- no2_ss %>%
  mutate(fwydist_miles = fwydist/1.609344)

mod3 <- lm(NO2 ~ fwydist_miles, data = no2_ss)
summary(mod3)


#### extra -- Riverside

no2_ss <- no2 %>%
  filter(townname == "Riverside")

# 1
no2_ss %>%
  ggplot(aes(x=fwydist, y=NO2)) +
  geom_point() +
  geom_smooth(method="lm", se=F, linetype="dashed", color="red") +
  labs(title="Townname: Riverside")


# 2
mod <- lm(NO2 ~ fwydist, data = no2_ss)
summary(mod)


# 3
no2_ss <- no2_ss %>%
  mutate(fwydist_c = fwydist - mean(fwydist))

mod2 <- lm(NO2 ~ fwydist_c, data = no2_ss)
summary(mod2)


# 4
no2_ss <- no2_ss %>%
  mutate(fwydist_miles = fwydist/1.609344)

mod3 <- lm(NO2 ~ fwydist_miles, data = no2_ss)
summary(mod3)

#####

# 5
no2_ss <- 
  no2 %>%
  filter(townname %in% c("Anaheim", "Long Beach", "Glendora"))

mod4 <- lm(NO2 ~ fwydist, data = no2_ss)
summary(mod4)
