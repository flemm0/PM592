library(tidyverse)
library(rvest)
library(gridExtra)
library(MASS)


setwd("\\\\wsl.localhost/Ubuntu/home/flemm0/school_stuff/USC_Fall_2023/PM592/Homeworks/HW02")

wcgs <- readRDS("../HW01/wcgs.rds")

## Question 1

# 1a
ggplot(data=wcgs, aes(x=bmi, y=sbp)) +
  geom_point(size=1) +
  theme_bw()

# 1c
wcgs <-
  wcgs %>%
  mutate(bmi_c = bmi - mean(bmi))

model1c <- lm(sbp ~ bmi_c, data=wcgs)
summary(model1c)

# 1f
cbind(wcgs, predict(model1c, wcgs, interval="prediction")) %>%
  ggplot(aes(x=bmi, y=sbp)) +
  geom_point(size=1) +
  theme_bw() +
  geom_smooth(formula= y ~ x, method="lm", linetype="dashed") +
  geom_line(aes(y=lwr), color="red", linetype="dashed") +
  geom_line(aes(y=upr), color="red", linetype="dashed")


## Question 2

# 2a
wcgs <-  
  wcgs %>%
  mutate(ncigs_minus_10 = ncigs - 10, ncigs_cent = ncigs - mean(ncigs))

model2a.1 <- lm(sbp ~ ncigs, data=wcgs)
summary(model2a.1)
confint(model2a.1)

model2a.2 <- lm(sbp ~ ncigs_minus_10, data=wcgs)
summary(model2a.2)
confint(model2a.2)

model2a.3 <- lm(sbp ~ ncigs_cent, data=wcgs)
summary(model2a.3)
confint(model2a.3)

# 2e
predict(model2a.1, newdata=data.frame(ncigs=19))


## Question 3

# 3a
url <- 'https://www.visualcapitalist.com/chart-money-can-buy-happiness-after-all/'

table_nodes <- 
  read_html(url) %>%
  html_elements("body") %>%
  html_nodes("table")

table <-
  table_nodes[1] %>% 
  html_table() %>%
  as.data.frame()

names(table) <- c("annual_income", "well_being_experienced", "well_being_evaluative")

table <- 
  table %>%
  mutate(annual_income_numeric = as.numeric(gsub("[\\$,]", "", annual_income)))

p1 <- ggplot(table, aes(x=annual_income_numeric, y=well_being_experienced)) +
  geom_point() +
  theme_bw() +
  labs(x="Annual Income", y="Well-Being Experienced") +
  scale_x_continuous(labels = scales::number_format(scale = 1, accuracy = 1))
p2 <- ggplot(table, aes(x=annual_income_numeric, y=well_being_evaluative)) +
  geom_point() +
  theme_bw() +
  labs(x="Annual Income", y="Well-Being Evaluated") +
  scale_x_continuous(labels = scales::number_format(scale = 1, accuracy = 1))
grid.arrange(p1, p2)

# 3b
table <- 
  table %>%
  mutate(annual_income_log = log(annual_income_numeric))

p1 <- ggplot(table, aes(x=annual_income_log, y=well_being_experienced)) +
  geom_point() +
  theme_bw() +
  labs(x="ln(Annual Income)", y="Well-Being Experienced") +
  scale_x_continuous(labels = scales::number_format(scale = 1, accuracy = 1))
p2 <- ggplot(table, aes(x=annual_income_log, y=well_being_evaluative)) +
  geom_point() +
  theme_bw() +
  labs(x="ln(Annual Income)", y="Well-Being Evaluated") +
  scale_x_continuous(labels = scales::number_format(scale = 1, accuracy = 1))
grid.arrange(p1, p2)

# 3c
x <- table$annual_income_numeric
boxcox(lm(x ~ 1))


## Question 4

# 4c
my.t.test <- function(mean1, mean2, sd1, sd2, n1, n2) {
  t <- (mean1 - mean2) / (sqrt((((sd1)**2)/n1) + ((sd2)**2)/n2))
  return(2*pt(abs(t), df=n1+n2-2, lower.tail = F))
}

my.t.test(909, 959, 217, 182, 12, 12)
my.t.test(27, 27.1, 1.8, 1.5, 12, 12)
my.t.test(4.8, 5.1, 1.4, 1.8, 12, 12)
my.t.test(7.3, 7.3, 1.2, 1, 12, 12)
