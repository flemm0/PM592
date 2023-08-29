library(tidyverse)
library(tibble)
library(readr)
library(skimr)
library(gridExtra)


setwd("\\\\wsl.localhost/Ubuntu/home/flemm0/school_stuff/USC_Fall_2023/PM592")

## Question 1

# 1a
a <- qnorm(p=0.01, mean=0, sd=1)

# 1b
b <- 2*pnorm(q=1.96, lower.tail=F)

# 1c
c <- qchisq(p=0.95, df=7)

# 1d
d <- pchisq(q=10, df=12)

# 1e
e <- abs(qt(p=.15/2, df=16))

# 1f
f <- pf(q=1.9, df1=7, df2=30)

ans <- tibble(
  "1a" = a, "1b" = b, "1c" = c, "1d" = d, "1e" = e, "1f" = f
)
ans


## Question 2

wcgs_raw <- readr::read_csv("./data/wcgs.csv")

# 2a
str(wcgs_raw)

names(wcgs_raw)

dim(wcgs_raw)


# 2b
wcgs <- wcgs_raw %>%
  mutate(weight_cat = cut(weight, breaks=c(-Inf, 140, 170, 201, Inf), labels=c("<140", "140-170", "170-200", ">200"), include.lowest=F, right=F))

wcgs %>%
  count(weight_cat) %>%
  mutate(pct = n / sum(n))
  
# 2c
wcgs <- wcgs %>%
  mutate(age_cat = cut(age, breaks=c(35, 41, 46, 51, 56, 60), labels=c("35-40", "41-45", "46-50", "51-55", "56-60"), right=F))

wcgs %>%
  count(weight_cat) %>%
  mutate(pct = n / sum(n))

# 2d
# bmi = (weight (lb) / [height (in)]^2) * 703
wcgs <- wcgs %>%
  mutate(bmi = (weight / height**2) * 703)

skim(wcgs$bmi)

# 2e
p1 <- ggplot(wcgs, aes(sbp)) + geom_histogram() + theme_minimal()
p2 <- ggplot(wcgs, aes(dbp)) + geom_histogram() + theme_minimal()
p3 <- ggplot(wcgs, aes(weight)) + geom_histogram() + theme_minimal()
p4 <- ggplot(wcgs, aes(height)) + geom_histogram() + theme_minimal()
p5 <- ggplot(wcgs, aes(chol)) + geom_histogram() + theme_minimal()
grid.arrange(p1, p2, p3, p4, p5, nrow=2)

# 2f
wcgs <- wcgs %>%
  mutate(sbp_log = log(sbp))

wcgs %>%
  select(sbp_log) %>%
  skim()

# 2g
wcgs %>%
  ggplot(aes(x=bmi, y=sbp)) +
  geom_point() +
  geom_smooth(method = "lm", alpha=.01) +
  labs(x="Body Mass Index", y="Systolic Blood Pressure") +
  theme_minimal()
