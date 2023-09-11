library(tidyverse)


# Load the data. The "cars" data set is built-in to R
data(cars)

# Add some additional data for higher speeds
cars2 <- tibble(
  speed = c(30,  35,  40,  45,  45,  50,  55,  55,  60,  65,  65,  70,  70,  75,
            80,  80,  85,  85,  85,  90,  90,  92),
  dist  = c(88,  125, 149, 155, 170, 243, 225, 275, 366, 350, 420, 532, 500, 550,
            481, 570, 532, 590, 620, 584, 631, 650)
)

# Bind new data to previous data
carstot <-
  bind_rows(
    cars, cars2
  )

# Perform a linear regression of distance on speed, then add residual and prediction
model1 <-
  lm(dist ~ speed, data = carstot)

carstot_model1 <-
  carstot %>%
  mutate(
    pred = predict(model1),
    resid = residuals(model1)
  )

carstot_model1 %>%
  ggplot(aes(x = pred, y = resid)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_point()

# Assess Linearity
carstot_model1 %>%
  ggplot(aes(x = pred, y = resid)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_smooth() +
  geom_point() 

# Assess Normality
carstot_model1 %>%
  select(resid) %>%
  psych::describe()

carstot_model1 %>%
  ggplot(aes(x = resid)) +
  geom_histogram()

carstot_model1 %>%
  ggplot(aes(sample = resid)) +
  geom_qq() +
  geom_qq_line()

shapiro.test(carstot_model1$resid)

# Assess Homoscedasticity
carstot_model1 %>%
  ggplot(aes(x = speed, y = resid)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_smooth() +
  geom_point() 


# New model with square root distance
model2 <-
  lm(sqrt(dist) ~ speed, data = carstot)

carstot_model2 <-
  carstot %>%
  mutate(
    pred = predict(model2),
    resid = residuals(model2)
  )

plot(model2)

psych::describe(carstot_model2$resid)


# Load CHS data and perform regression

chs <-
  read_csv("chs_individual.csv")

chs %>%
  ggplot(aes(x = "Overall", y = fev)) +
  geom_beeswarm()

lm(fev ~ 1, data = chs) %>% summary()
lm(fev ~ 1, data = chs) %>% anova()

chs %>%
  ggplot(aes(x = weight, y = fev)) +
  geom_point() +
  geom_smooth(method = "lm")

lm(fev ~ weight, data = chs) %>% summary()
lm(fev ~ weight, data = chs) %>% anova()

anova.full <- function(x) {
  anova.df <-
    x %>%
    anova() %>%
    data.frame() %>%
    rownames_to_column() %>%
    tibble() 
  
  anova.df %>%
    bind_rows(
      tibble(
        rowname = "Total",
        Df = sum(anova.df$Df),
        Sum.Sq = sum(anova.df$Sum.Sq),
        Mean.Sq = Sum.Sq / Df
      )
    )
}


# Log transformation of Y

re <- read_csv("real_estate.csv") 

re %>%
  ggplot(aes(x = age,
             y = expense)) +
  geom_point() +
  geom_smooth(se = F) +
  geom_smooth(method = "lm", se = F, color = "red")

lm(expense ~ age, data = re) %>%
  plot()

re %>%
  ggplot(aes(x = expense)) +
  geom_histogram()

MASS::boxcox(expense ~ age, data = re) 

lm(log(expense) ~ age, data = re) %>% plot()

re %>%
  ggplot(aes(x = age, y = log(expense))) +
  geom_point() +
  geom_smooth(method = "lm", se = F, color = "red")

lm(log(expense) ~ age, data = re) %>% summary()
lm(log(expense) ~ age, data = re) %>% confint()


# Categorical IV Binary
t.test(fev ~ male, 
       var.equal = T,
       data = chs)

lm(fev ~ male,
   data = chs) %>%
  summary()

chs %>%
  ggplot(aes(x = male, y = fev)) +
  geom_point(alpha=.1) +
  geom_smooth(method = "lm", SE = F) +
  scale_x_continuous(breaks = c(0, 1))

lm(fev ~ male,
   data = chs) %>%
  plot()

lm(fev ~ female,
   data = chs %>% mutate(female = 1-male)) %>%
  summary()


# Categorical IV
chs <-
  chs %>% 
  mutate(race = case_when(
    race == "D" ~ "O",
    race == "M" ~ "O",
    TRUE ~ race
  ))

library(skimr)
chs %>%
  group_by(race) %>%
  skim(fev)

chs %>%
  ggplot(aes(x = race, y = fev)) +
  geom_boxplot()

chs <-
  chs %>%
  mutate(
    race_a = if_else(race=="A", 1, 0),
    race_b = if_else(race=="B", 1, 0),
    race_o = if_else(race=="O", 1, 0)
  )

lm(fev ~ race_a + race_b + race_o, data = chs) %>%
  summary()

lm(fev ~ race_a + race_b + race_o, data = chs) %>%
  plot()

lm(fev ~ relevel(factor(race), ref = "W"), data = chs) %>% summary()
