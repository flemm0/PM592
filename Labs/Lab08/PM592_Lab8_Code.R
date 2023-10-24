library(tidyverse)

okc <- read_csv("okcprofiles_cleaned.csv")

okc <-
  okc %>%
  mutate(coupled = as.integer(status %in% c("married", "seeing someone")),
         straight = as.integer(orientation == "straight"),
         sign1 = word(sign, 1),
         religion1 = word(religion, 1),
         smoker = as.integer(smokes != "no"),
         male = as.integer(sex=="m"),
         drink1 = as.integer(drinks != "not at all"),
         smoke1 = as.integer(smokes != "no"))


# Different ways to create a table of male vs. coupled
okc %>%
  with(., table(male, coupled))

okc %>%
  with(., table(male, coupled)) %>%
  prop.table(margin = 1)

okc %>%
  with(., xtabs( ~ male + coupled)) %>%
  prop.table(margin = 1)

okc %>%
  with(., table(male, coupled)) %>%
  gmodels::CrossTable()

okc %>%
  with(., table(male, coupled)) %>%
  chisq.test()

# Odds Ratio
get.or <- function(table) {
  or <- table[1]*table[4]/(table[2]*table[3])
  se <- sqrt(1/table[1] + 1/table[2] + 1/table[3] + 1/table[4])
  upper.95ci <- exp(log(or) + 1.96*se)
  lower.95ci <- exp(log(or) - 1.96*se)
  
  tibble(or, lower.95ci, upper.95ci)
}

okc %>%
  with(., table(male, coupled)) %>%
  get.or()

okc %>%
  with(., 
       epitools::oddsratio(male, coupled))

glm(coupled ~ male, data = okc, family = binomial) %>% summary()

glm(coupled ~ male, data = okc, family = binomial) %>% coef() %>% exp()

# Likelihood Ratio
glm(coupled ~ male, data = okc, family = binomial) %>% anova(test = "Chisq")

couple_male.m <- glm(coupled ~ male, data = okc, family = binomial)
couple_male_body.m <- glm(coupled ~ male + body_type,
                          data = okc %>% 
                            mutate(body_type = relevel(
                              factor(body_type),
                              ref = "average") %>% addNA()), 
                          family = binomial)
anova(couple_male.m, couple_male_body.m, test = "Chisq")

DescTools::PseudoR2(couple_male.m)
DescTools::PseudoR2(couple_male.m, "Nagelkerke")

# Prediction: Age
okc %>%
  filter(age < 90) %>%
  ggplot(aes(x = age, y = coupled)) +
  geom_point(alpha = .1)

coupled_age.m <- 
  glm(coupled ~ age, 
    data = okc %>% 
      filter(age < 90), 
    family = binomial)

okc %>%
  filter(age < 90) %>%
  ggplot(aes(x = age, y = coupled)) +
  geom_point(alpha = .1) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"))

predict(coupled_age.m, data.frame(age = c(20, 40, 60)))
predict(coupled_age.m, data.frame(age = c(20, 40, 60)), type = "response")




glm(smoke1 ~ male + age + straight + factor(religion1), 
    data = okc, 
    family = binomial) %>% 
  summary()





####################################
# Lab Solutions
####################################

# 1a
okc %>%
  with(., 
    gmodels::CrossTable(male, smoker,
                        chisq=F,
                        prop.t=F,
                        prop.c=F)
  )
# 1b
okc %>%
  with(.,
       epitools::oddsratio(male, smoker)
       )
# 2a
okc %>%
  with(., 
       gmodels::CrossTable(straight, smoker,
                           chisq=F,
                           prop.t=F,
                           prop.c=F)
  )
# 2b
okc %>%
  with(.,
       epitools::oddsratio(straight, smoker)
  )
# 3a
okc %>%
  ggplot(aes(x=age, y=smoker)) +
  geom_count() +
  geom_smooth()
# 3b
glm(smoker ~ age, data=okc, family="binomial") %>%
  summary()
# 4a
okc %>%
  group_by(religion1) %>%
  summarise(meansmoke = mean(smoker, na.rm=T)) %>%
  ggplot(aes(x=religion1, y=meansmoke)) +
  geom_point()
# 4b
glm(smoker ~ factor(religion1), data=okc, family="binomial") %>%
  summary()
# 4e
glm(smoker ~ factor(religion1), data=okc, family="binomial") %>%
  anova(test="LRT")
# 5a
glm(smoker ~ male + age + straight + religion1,
    data=okc,
    family="binomial") %>%
  summary()
# 5c
glm(smoker ~ male + age + straight + religion1,
    data=okc,
    family="binomial") %>%
  DescTools::PseudoR2()


noreligion.m <- glm(smoker ~ male + age + straight,
                    data=okc %>% filter(!is.na(religion)),
                    family="binomial")
religion.m <- glm(smoker ~ male + age + straight + religion1,
                  data=okc,
                  family="binomial")
anova(noreligion.m, religion.m, test="LRT")
