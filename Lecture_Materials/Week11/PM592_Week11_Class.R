library(tidyverse)
library(haven)

rbcunits <- read_dta("rbcunits.dta")

rbcunits %>%
  select(units) %>%
  skimr::skim()

rbcunits %>%
  count(units)

rbcunits %>%
  group_by(miavr) %>%
  summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
  group_by(male) %>%
  summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
  group_by(white) %>%
  summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
  group_by(bmicat) %>%
  summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
  group_by(hx_db) %>%
  summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
  ggplot(aes(x = agecent, y = units)) +
  geom_count(alpha = 0.5) + 
  geom_smooth()

rbcunits %>%
  ggplot(aes(x = agecent, y = units)) +
  geom_count(alpha = 0.5) + 
  geom_smooth(method = 'glm', method.args = list(family = 'poisson'))

# Poisson models, gradually building covariates
rbc0.m <- glm(units ~ 1, family="poisson", data=rbcunits)
summary(rbc0.m)
exp(rbc0.m$coefficients)

rbc1.m <- glm(units ~ miavr, family="poisson", data=rbcunits)
summary(rbc1.m)
exp(rbc1.m$coefficients)

rbc2.m <- glm(units ~ miavr + agecent + white + male + hx_db + factor(bmicat), 
              family="poisson", data=rbcunits)
summary(rbc2.m)
exp(rbc2.m$coefficients)

rbc3.m <- glm(units ~ miavr + agecent + male + hx_db + factor(bmicat), 
              family="poisson", data=rbcunits)
summary(rbc3.m)
tibble(
  parameter = names(rbc3.m$coefficients),
  rr = exp(rbc3.m$coefficients),
  as.data.frame.matrix(exp(confint.default(rbc3.m)))
) 


# Goodness of Fit
pois_pearson_gof(rbc3.m)
pois_dev_gof(rbc3.m)

pois_pearson_gof <-
  function(model) {
    return(
      list(
        pval = tibble(
          pred = predict(model, type = "response"),
          y = model$y
        ) %>%
          {sum((.$y - .$pred)^2/.$pred)} %>%
          pchisq(., model$df.residual, lower.tail = F),
        df = model$df.residual
      )
    )
  }

pois_dev_gof <-
  function(model) {
    return(
      list(
        pval = pchisq(model$deviance, model$df.residual, lower.tail=F),
        df = model$df.residual
      )
    )
  }

# Checking for Overdispersion
rbcunits %>%
  ggplot(aes(x = units)) +
  geom_histogram(bins = 11) +
  geom_point(aes(y=length(units)*dpois(units, mean(units))), size = 3, colour="red")

tibble(
  pred = predict(rbc3.m),
  resid = residuals.glm(rbc3.m)
) %>%
  ggplot(aes(x = pred, y = resid)) +
  geom_point() +
  geom_smooth(span = 1) +
  geom_hline(yintercept = 0, color = "red")

dispersiontest(rbc3.m)


dpois.od<-function (n, lambda,d=1) {
  if (d==1)
    dpois(n, lambda)
  else
    dnbinom(n, size=(lambda/(d-1)), mu=lambda)
}

rbcunits %>%
  ggplot(aes(x = units)) +
  geom_histogram(bins = 11) +
  geom_point(aes(y=length(units)*dpois.od(units, mean(units), d=2.3)), size = 3, colour="red")


rbc4.m <- MASS::glm.nb(units ~ miavr + agecent + male + hx_db + factor(bmicat), 
              link = log, data=rbcunits)

pois_pearson_gof(rbc4.m)
pois_dev_gof(rbc4.m)



# Rate Example: railroad
railroad <-
  read_dta("railroad.dta") %>%
  mutate(time.1975 = time-1975)

railroad %>%
  ggplot(aes(x = collisions)) +
  geom_histogram(bins = (1 + max(railroad$collisions) - min(railroad$collisions)), color = "black", fill = "gray70") +
  geom_point(aes(y=length(collisions)*dpois(collisions, mean(collisions))), size = 3, colour="red")

rr0.m <-
  glm(collisions ~ 1, family = poisson, data = railroad)

AER::dispersiontest(rr0.m)

# These two methods are equivalent
rr1.m <-
  glm(collisions ~ time.1975, offset = log(km), family = poisson, data = railroad)
rr1.m <-
  glm(collisions ~ time.1975 + offset(log(km)), family = poisson, data = railroad)

glm.RR <- function(GLM.RESULT, digits = 2) {
  
  if (GLM.RESULT$family$family == "binomial") {
    LABEL <- "OR"
  } else if (GLM.RESULT$family$family == "poisson") {
    LABEL <- "RR"
  } else {
    stop("Not logistic or Poisson model")
  }
  
  COEF      <- stats::coef(GLM.RESULT)
  CONFINT   <- stats::confint(GLM.RESULT)
  TABLE     <- cbind(coef=COEF, CONFINT)
  TABLE.EXP <- round(exp(TABLE), digits)
  
  colnames(TABLE.EXP)[1] <- LABEL
  
  TABLE.EXP
}

summary(rr1.m)
glm.RR(rr1.m, digits=4)

railroad <- 
railroad %>%
  mutate(pred_rate = predict(rr1.m, 
                             tibble(
                               time.1975 = railroad$time.1975, 
                               km = 1), 
                             type = "response"),
         pred_count = predict(rr1.m, ., type = "response")
  )

coeff <- 450
rateColor <- "goldenrod"
countColor <- "firebrick"
ggplot(railroad, aes(x=time.1975)) +
  geom_line( aes(y=pred_rate), size=2, color=rateColor) + 
  geom_line( aes(y=pred_count / coeff), size=2, color=countColor) +
  scale_y_continuous(
    name = "Collisions per million km",
    sec.axis = sec_axis(~.*coeff, name="Total collisions")
  ) + 
  theme_bw() +
  theme(
    axis.title.y = element_text(color = rateColor, size=13),
    axis.title.y.right = element_text(color = countColor, size=13)
  )

pois_pearson_gof(rr1.m)
pois_dev_gof(rr1.m)


railroad %>%
  pivot_longer(cols = c("pred_count", "collisions"),
               names_to = "type",
               values_to = "value") %>%
  ggplot(aes(x = time.1975, y = value, color = type)) +
    geom_point() +
    geom_line() 
