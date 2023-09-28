library(tidyverse)
library(readr)
library(olsrr)

## Question 1

# 1d
r = .77
r_sq = r ** 2
r_sq

## Question 2

happygdp <- readr::read_csv("data/happygdp.csv")
happygdp <- happygdp[! is.na(happygdp$gdp),] # remove observations with missing data

# 2a
ggplot(data=happygdp, aes(x=gdp, y=satisfaction)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(formula = y ~ x, method="lm", se=FALSE, linetype="dashed", colour = "grey", na.rm = TRUE) +
  theme_minimal() +
  labs(y="Life satisfaction score", x="GDP per capita", title="The Relationship Between Money and Happiness") 

# 2b
m.2b <- lm(satisfaction ~ gdp, data = happygdp)
summary(m.2b)

# 2c
happygdp <-
  happygdp %>%
  bind_cols(sresid = rstandard(m.2b))
head(happygdp, 6)

# 2d
ggplot(data=happygdp, aes(x=gdp, y=satisfaction)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(formula = y ~ x, method="lm", se=FALSE, linetype="dashed", colour = "grey", na.rm = TRUE) +
  theme_minimal() +
  labs(y="Life satisfaction score", x="GDP per capita", title="The Relationship Between Money and Happiness") +
  geom_label(
    data = happygdp %>% subset(abs(sresid)>2),
    aes(label=country), nudge_x = 0.5, nudge_y = 0.5
  )

# 2e
autoplot(m.2b, 1:6)

# 2f
ols_plot_resid_lev(m.2b)
ols_plot_dfbetas(m.2b, F)
m.2f <- lm(satisfaction ~ gdp, data = happygdp[-c(4, 15, 18, 26, 34),])
summary(m.2f)


## Question 3

# 3a
m.3a1 <- lm(sqrt(gdp) ~ satisfaction, data = happygdp) # square root transformation
summary(m.3a1)

m.3a2 <- lm((gdp)^(1/10) ~ satisfaction, data = happygdp) # 10th root transformation
summary(m.3a2)

m.3a3 <- lm(log(gdp) ~ satisfaction, data = happygdp) # log transformation
summary(m.3a3)

# 3b
happygdp <-
  happygdp %>%
  bind_cols(ln_sresid = rstandard(m.3a3))
head(happygdp, 6)

# 3c
ggplot(data=happygdp, aes(x=gdp, y=satisfaction)) +
  geom_point(na.rm = TRUE) +
  geom_smooth(formula = y ~ log(x), method="lm", se=FALSE, linetype="dashed", colour = "grey", na.rm = TRUE) +
  theme_minimal() +
  labs(y="Life satisfaction score", x="GDP per capita", title="The Relationship Between Money and Happiness") +
  geom_label(
    data = happygdp %>% subset(abs(ln_sresid)>2),
    aes(label=country)
  )

# 3d
autoplot(m.3a3)
