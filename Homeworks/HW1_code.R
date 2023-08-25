library(tidyverse)
library(tibble)
library(readr)


setwd("\\\\wsl.localhost/Ubuntu/home/flemm0/school_stuff/USC_Fall_2023/PM592")

## Question 1

# 1a
a <- qnorm(p=0.01, mean=0, sd=1)

# 1b
b <- 2*pnorm(q=1.96, lower.tail=F)

# 1c
c <- qchisq(p=0.95, df=7)

# 1d
d <- pchisq(q=10, df=10)

# 1e
e <- qt(p=.15/2, df=16)

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
