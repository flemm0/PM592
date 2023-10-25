library(tidyverse)
library(haven)

intrinsic <- haven::read_dta('data/intrinsic.dta')

intrinsic <- na.omit(intrinsic)

head(intrinsic)


## Question 2

# 2a
m <- glm(enjoyex ~ ewc, data = intrinsic)
summary(m)

# 2b
intrinsic$pred_logits <- predict(m, type = "link")
ggplot(intrinsic, aes(x=ewc, y=pred_logits)) + geom_point()

# 2c
m.2 <- glm(enjoyex ~ factor(ewc), data = intrinsic)
summary(m.2)
anova(m.2, test = "LRT")

# 2f
intrinsic$pred_logits_dummy = predict(m.2, type = "link")
ggplot(intrinsic, aes(x=ewc, y=pred_logits_dummy)) + geom_point()

# 2g
anova(m, m.2, test = "LRT")


## Question 3

# 3c
q = (-2*-355.10) - (-2*-336.55)
pchisq(q=q, df=2, lower.tail = FALSE)

# 3d
q = (-2*-337.09) - (-2*-336.55)
pchisq(q=q, df=1, lower.tail = FALSE)
