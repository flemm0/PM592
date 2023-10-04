library(readr)
library(tidyverse)

fw <- readr::read_csv("data/fetal_weight.csv")

head(fw)
dim(fw)


## Question 1

# 1a
ggplot(fw, aes(x=bw, y=ap.sqrt)) +
  geom_point() +
  geom_smooth(formula=y~x, method="lm") + 
  theme_minimal()
