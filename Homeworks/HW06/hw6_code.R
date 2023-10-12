library(readr)
library(tidyverse)
library(mfp)
library(gtools)

fw <- readr::read_csv("data/fetal_weight.csv")

head(fw)
dim(fw)


## helper functions (from https://rpubs.com/RatherBit/102428):

PRESS <- function(linear.model) {
  #' calculate the predictive residuals
  pr <- residuals(linear.model)/(1-lm.influence(linear.model)$hat)
  #' calculate the PRESS
  PRESS <- sum(pr^2)
  
  return(PRESS)
}

pred_r_squared <- function(linear.model) {
  #' Use anova() to get the sum of squares for the linear model
  lm.anova <- anova(linear.model)
  #' Calculate the total sum of squares
  tss <- sum(lm.anova$'Sum Sq')
  # Calculate the predictive R^2
  pred.r.squared <- 1-PRESS(linear.model)/(tss)
  
  return(pred.r.squared)
}

## Question 1

# 1a
ggplot(fw, aes(x=bw, y=ap.sqrt)) +
  geom_point() +
  geom_smooth(formula=y~x, method="lm") + 
  theme_minimal()

# 1b
fw <-
  fw %>%
  mutate(bw.c = bw - mean(bw))
lm(ap.sqrt ~ bw.c + I(bw.c^2) + I(bw.c^3) + I(bw.c^4), data = fw) %>% anova() # 4th order polynomial term does not improve model fit
lm(ap.sqrt ~ bw.c + I(bw.c^2) + I(bw.c^3), data = fw) %>% summary()
lm(ap.sqrt ~ bw.c + I(bw.c^2) + I(bw.c^3), data = fw) %>% pred_r_squared()

# 1c
mfp(ap.sqrt ~ fp(bw.c), data = fw)
lm(ap.sqrt ~ I(((bw.c+1738)/1000)^3) + I(((bw.c+1738)/1000)^3*log(((bw.c+1738)/1000))), data = fw) %>% summary()
lm(ap.sqrt ~ I(((bw.c+1738)/1000)^3) + I(((bw.c+1738)/1000)^3*log(((bw.c+1738)/1000))), data = fw) %>% pred_r_squared()

# 1d
fw <-
  fw %>%
  mutate(bw.quint = quantcut(bw, q = 5))
lm(ap.sqrt ~ bw.quint, data = fw) %>% summary()
lm(ap.sqrt ~ bw.quint, data = fw) %>% pred_r_squared()


## Question 2

# 2a
lm(ap.sqrt ~ year, data = fw) %>% summary()
lm(ap.sqrt ~ year + bw.c + I(bw.c^2) + I(bw.c^3), data = fw) %>% summary()
lm(ap.sqrt ~ year + I(((bw.c+1738)/1000)^3) + I(((bw.c+1738)/1000)^3*log(((bw.c+1738)/1000))), data = fw) %>% summary()
lm(ap.sqrt ~ year + bw.quint, data = fw) %>% summary()
