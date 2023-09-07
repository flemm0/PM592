library(tidyverse)
library(MASS)

# Load the data. The "cars" data set is built-in to R
data(cars)

# Simple plot of distance vs. speed
with(cars, plot(speed, dist))

# GGplot of distance vs. speed with linear line added
cars %>%
  ggplot(aes(x = speed, y = dist)) +
  geom_point() + 
  geom_smooth(method = "lm", se=F)

# Fit the linear regression
lm(dist ~ speed, data = cars) %>%
  summary()

# Add some additional data for higher speeds
cars2 <- tibble(
  speed = c(30,  35,  40,  45,  45,  50,  55,  55,  60,  65,  65,  70,  70,  75,
            80,  80,  85,  85,  85,  90,  90),
  dist  = c(88,  125, 149, 155, 170, 243, 225, 275, 366, 350, 420, 532, 500, 550,
            481, 570, 532, 590, 620, 584, 631, 650)
)

# Bind new data to previous data
carstot <-
  bind_rows(
    cars, cars2
  )

# Simple plot of distance vs. speed with new data
with(carstot, plot(speed, dist))

# GGplot of distance vs. speed with linear line added
carstot %>%
  ggplot(aes(x = speed, y = dist)) +
  geom_point() + 
  geom_smooth(method = "lm", se=F)

# Perform a linear regression of distance on speed, then box-cox procedure
lm(dist ~ speed, data = carstot) %>%
  boxcox()

# Box-Cox showed a square-root transformation is appropriate,
# so create a variable that is square-root of distance
carstot <-
  carstot %>%
  mutate(
    dist_sqrt = sqrt(dist)
  )

# GGplot of square-root of distance vs. speed with linear line added
carstot %>%
  ggplot(aes(x = speed, y = dist_sqrt)) +
  geom_point() + 
  geom_smooth(method = "lm", se=F)

# Regression of distance on speed, then of square-root distance on speed
lm(dist ~ speed, data = carstot) %>%
  summary()



# Real estate example
realestate <-
  read_csv("real_estate.csv") 
colnames(realestate) <-
    c("id", "dt", "age", "dist_mrt", "stores", "lat", "long", "price")

realestate %>%
  ggplot(aes(x = stores, y = price)) +
  geom_point() +
  geom_smooth(method = "lm", se = F)

model_price_stores <- lm(price ~ stores, data = realestate)
summary(model_price_stores)
anova(model_price_stores)

hist(residuals(model_price_stores))



# Sleep example
sleep <-
  read_csv("sleep.csv")

sleep %>%
  with(.,
       plot(hours, bmi)
       )

model_bmi_hours <-
  lm(bmi ~ hours, data = sleep)
summary(model_bmi_hours)
anova(model_bmi_hours)
hist(residuals(model_bmi_hours))

sleep <-
  sleep %>%
  mutate(
    hours_c = hours - mean(hours, na.rm=T)
  )
  
model_bmi_hoursc <-
  lm(bmi ~ hours_c, data = sleep)
summary(model_bmi_hoursc)
anova(model_bmi_hoursc)
hist(residuals(model_bmi_hoursc))

sleep %>%
  ggplot(aes(x = hours, y = bmi)) +
  geom_point(color = "red") +
  geom_smooth(color = "red", method = "lm") +
  geom_point(aes(x = hours_c), color = "blue") + 
  geom_smooth(aes(x = hours_c), color = "blue", method = "lm") +
  scale_y_continuous(limits = c(0, 26))


summary(model_bmi_hoursc)
confint(model_bmi_hoursc)

# The confidence interval for the mean (line)
predict(model_bmi_hoursc, sleep, interval="confidence") %>%
  head()

# The confidence interval for the prediction (points)
predict(model_bmi_hoursc, sleep, interval="prediction") %>%
  head()

sleep %>%
  ggplot(aes(x = hours, y = bmi)) +
  geom_point() +
  geom_smooth(method = "lm", level = 0.95) 

# Add prediction CI and include with plot
sleep2 <- cbind(
  sleep,
  predict(model_bmi_hoursc, sleep, interval="prediction")
)

sleep2 %>%
  ggplot(aes(x = hours, y = bmi))+
  geom_point() +
  geom_line(aes(y=lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y=upr), color = "red", linetype = "dashed")+
  geom_smooth(method=lm, se=TRUE)


# Sleep correlations
cor(sleep)
with(sleep,
     cor.test(hours, bmi)
     )

sleep %>%
  psych::describe()



# Correlation for stopping distance
with(carstot,
     cor.test(speed, dist)
     )

with(carstot,
     cor.test(speed, dist, method = "spearman")
)


# Correlation for MPG

mpg %>%
  ggplot(aes(x = displ, y = cty)) +
  geom_jitter(color ="darkgreen") +
  geom_smooth(method = "lm")

with(mpg,
     cor.test(cty, displ))

with(mpg,
     cor.test(cty, displ, method = "spearman"))
