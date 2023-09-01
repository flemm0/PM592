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
  labs(x="Body Mass Index", y="Systolic Blood Pressure") +
  theme_minimal()

# 2h
sum(wcgs$ncigs)

# 2i
wcgs %>%
  count(dibpat, smoke) %>%
  group_by(dibpat) %>%
  mutate(dibpat_count = sum(n)) %>%
  mutate(dibpat_smoke_pct = n / dibpat_count)


## Question 3

# 3a
# since population std deviation is not given, calculate t-statistic
q = (mean(wcgs$sbp) - 125) / (sd(wcgs$sbp) / sqrt(length(wcgs$sbp)))
2*pt(q=q, df=length(wcgs$sbp)-1, lower.tail=F)

# 3b
wcgs %>%
  ggplot(aes(x=smoke, y=sbp, fill=smoke)) + 
  geom_boxplot() +
  theme_minimal()

# 3c 
# parametric statistical test: t-test
var.test(sbp ~ as.factor(smoke), data=wcgs) # p < 0.05 reject null
t.test(sbp ~ as.factor(smoke), var.equal=F, data=wcgs)


# 3d
wilcox.test(sbp ~ as.factor(smoke), data=wcgs)


# 3e
describeBy(wcgs$sbp, group=wcgs$smoke, mat=T)

# CI of mean for t-distribution: mean +/- t * se
# t = critical t-value based on desired confidence level
# standard error: sample stdev / df

calculate_ci <- function(x, lower=TRUE) {
  t_crit = qt(1 - 0.05/2, df=length(x)-1) # use `pt()` function to get critical t-value for 95% CI
  se = sd(x) / (length(x) - 1)
  if (lower) {
    return(mean(x) - t_crit*se)
  } else {
    return(mean(x) + t_crit*se)
  }
}

bind_rows(
  wcgs %>%
    group_by(smoke) %>%
    summarise(
      Mean=mean(sbp),
      SD=sd(sbp),
      ci_lower=calculate_ci(sbp, lower=TRUE),
      ci_higher=calculate_ci(sbp, lower=FALSE)
    ) %>% 
    as.data.frame(),
  wcgs %>%
    summarise(
      smoke="combined",
      Mean=mean(sbp),
      SD=sd(sbp),
      ci_lower=calculate_ci(sbp, lower=TRUE),
      ci_higher=calculate_ci(sbp, lower=FALSE)
    )
  
)


