library(tidyverse)
library(ggfortify)

# load the data
data(mtcars)

# make "cyl" a factor variable
mtcars <-
  mtcars %>%
  rownames_to_column() %>%
  rename(carname = rowname) %>%
  mutate(
    cyl.f = factor(cyl),
    vs.f = factor(vs),
    am.f = factor(am)
  ) %>%
  as_tibble()

# Plot MPG vs drat, then model diagnostics
mtcars %>%
  ggplot(aes(x = drat, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm")

par(mfrow = c(1, 3))
lm(mpg ~ drat, data = mtcars) %>%
  plot()

# Use ggfortify

mtcars %>%
  select_if(is.numeric) %>%
  scale() %>%
  autoplot()

lm(mpg ~ drat, data = mtcars) %>%
  autoplot(which = 1:3, ncol = 3)

# MPG vs horsepower
mtcars %>%
  ggplot(aes(x = hp, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm")

lm(mpg ~ hp, data = mtcars) %>%
  autoplot(which = 1:3, ncol = 3)

lm(mpg ~ hp, data = mtcars) %>%
  autoplot(which = 1:3, 
           ncol = 3, 
           data = mtcars,
           colour = 'am.f')

# Stringr extract first word

mtcars <-
  mtcars %>%
  mutate(
    car_make = word(carname, 1),
    car_model = word(carname, 2, -1)
    )

# Factor variable

lm(mpg ~ cyl.f, data = mtcars) %>%
  summary()

mtcars <-
  mtcars %>%
  mutate(
    cyl.rf1 = factor(cyl, levels = c(8, 6, 4)),
    cyl.rf2 = relevel(cyl.f, ref = "8")
    )
  
mtcars %>%
  select(starts_with("cyl.rf")) %>%
  str()

lm(mpg ~ cyl.rf1, data = mtcars) %>%
  summary()

lm(mpg ~ cyl.rf2, data = mtcars) %>%
  summary()

# Merging/setting solution


l1q1 <-
  read_fwf("lab1q1.dat", 
           fwf_widths(
             c(5, 2, 1, 3, 2, 2, 2, 2),
             c("id", "sex", "htfeet", "htinches",
               "race", "birthm", "birthd", "labnum")),
           na = "."
  )
l2q1 <-
  read_fwf("lab2q1.dat", 
           fwf_widths(
             c(5, 2, 1, 3, 2, 2, 2, 2),
             c("id", "sex", "htfeet", "htinches",
               "race", "birthm", "birthd", "labnum")),
           na = "."
  )
l1q2 <-
  read_fwf("lab1q2.dat",
           fwf_widths(
             c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
             c("id", "trans", "gasprice", "suv",
               "carmake", "tankvol", "tanklast",
               "city", "oneway", "schtimes", "labnum")),
             na = "."
           )
l2q2 <-
  read_fwf("lab1q2.dat",
           fwf_widths(
             c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
             c("id", "trans", "gasprice", "suv",
               "carmake", "tankvol", "tanklast",
               "city", "oneway", "schtimes", "labnum")),
             na = "."
           )


lab <-
    full_join(
      bind_rows(l1q1, l2q1),
      bind_rows(l1q2, l2q2),
      by = c("id", "labnum")) %>%
  distinct() %>%
  mutate(sex.f = factor(sex, levels = c("F", "M")))


install.packages("ggfortify")

##############################
# Lab 4 Solutions

library(ggfortify)
library(cowplot)
library(ggpmisc)

data(anscombe)
f1 <- anscombe %>%
  ggplot(aes(x=x1, y=y1)) +
  geom_point() + 
  geom_smooth(method="lm") +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE)
f2 <- anscombe %>%
  ggplot(aes(x=x2, y=y2)) +
  geom_point() + 
  geom_smooth(method="lm") +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE)
f3 <- anscombe %>%
  ggplot(aes(x=x3, y=y3)) +
  geom_point() + 
  geom_smooth(method="lm") +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE)
f4 <- anscombe %>%
  ggplot(aes(x=x4, y=y4)) +
  geom_point() + 
  geom_smooth(method="lm") +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE)

plot_grid(f1, f2, f3, f4)

m1 <- lm(y1 ~ x1, data=anscombe)
m2 <- lm(y2 ~ x2, data=anscombe)
m3 <- lm(y3 ~ x3, data=anscombe)
m4 <- lm(y4 ~ x4, data=anscombe)

summary(m1)
summary(m2)
summary(m3)
summary(m4)

autoplot(m1)
autoplot(m2)
autoplot(m3)
autoplot(m4)



lab1q1 <- read_fwf("lab1q1.dat", 
                     fwf_widths(
                       c(5, 2, 1, 3, 2, 2, 2, 2),
                       c("id", "sex", "htfeet", "htinches",
                         "race", "birthm", "birthd", "labnum")),
                     na = "."
)
lab2q1 <-   read_fwf("lab2q1.dat", 
                     fwf_widths(
                       c(5, 2, 1, 3, 2, 2, 2, 2),
                       c("id", "sex", "htfeet", "htinches",
                         "race", "birthm", "birthd", "labnum")),
                     na = "."
)
lab1q2 <-  read_fwf("lab1q2.dat", 
                    fwf_widths(
                      c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
                      c("id", "transportation", "gasprice", "suv", "carmake",
                        "tankvol", "tanklast", "city", "oneway", "schtimes", "labnum")),
                    na = "."
)
lab2q2 <- read_fwf("lab2q2.dat", 
                              fwf_widths(
                                c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
                                c("id", "transportation", "gasprice", "suv", "carmake",
                                  "tankvol", "tanklast", "city", "oneway", "schtimes", "labnum")),
                              na = "."
)

q1 <- lab1q1 %>%
  bind_rows(lab2q1)
q2 <- lab1q2 %>%
  bind_rows(lab2q2)

class_data <-
  q1 %>%
  full_join(q2, by="id")

m2.1 <- lm(tankvol ~ tanklast, data=class_data)

class_data <-
  class_data %>%
  mutate(transport.f = factor(transportation,
                             labels = c("Car",
                                        "Walk",
                                        "Public",
                                        "Bike")))

m2.2 <- lm(oneway ~ transport.f, data=class_data)

class_data <-
  class_data %>%
  mutate(transport.f = relevel(transport.f, "Walk"))
