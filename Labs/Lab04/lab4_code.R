library(cowplot)
library(tidyverse)
library(ggpmisc)
library(ggfortify)

## Part 1

# 1

data("anscombe")

f1 <- ggplot(anscombe, aes(x=x1, y=y1)) +
  geom_point() +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE) +
  labs(title="f1")
f2 <- ggplot(anscombe, aes(x=x2, y=y2)) +
  geom_point() +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE) +
  labs(title="f2")
f3 <- ggplot(anscombe, aes(x=x3, y=y3)) +
  geom_point() +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE) +
  labs(title="f3")
f4 <- ggplot(anscombe, aes(x=x4, y=y4)) +
  geom_point() +
  stat_poly_eq(formula = y ~ x,
               eq.with.lhs = "italic(hat(y))~`=`~",               
               aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")), 
               parse = TRUE) +
  labs(title="f4")

plot_grid(f1, f2, f3, f4)

lm1 <- lm(y1 ~ x1, data = anscombe)
summary(lm1)

lm2 <- lm(y2 ~ x2, data = anscombe)
summary(lm2)

lm3 <- lm(y3 ~ x3, data = anscombe)
summary(lm3)

lm4 <- lm(y4 ~ x3, data = anscombe)
summary(lm4)


# 2
autoplot(lm1)

autoplot(lm2)

autoplot(lm3)

autoplot(lm4)

## Part 2

lab1q1 <- read_fwf("./Labs/Lab04/lab1q1.dat", 
                   fwf_widths(
                     c(5, 2, 1, 3, 2, 2, 2, 2),
                     c("id", "sex", "htfeet", "htinches",
                       "race", "birthm", "birthd", "labnum")),
                   na = "."
)
lab2q1 <-   read_fwf("./Labs/Lab04/lab2q1.dat", 
                     fwf_widths(
                       c(5, 2, 1, 3, 2, 2, 2, 2),
                       c("id", "sex", "htfeet", "htinches",
                         "race", "birthm", "birthd", "labnum")),
                     na = "."
)
lab1q2 <-  read_fwf("./Labs/Lab04/lab1q2.dat", 
                    fwf_widths(
                      c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
                      c("id", "transportation", "gasprice", "suv", "carmake",
                        "tankvol", "tanklast", "city", "oneway", "schtimes", "labnum")),
                    na = "."
)
lab2q2 <- read_fwf("./Labs/Lab04/lab2q2.dat", 
                   fwf_widths(
                     c(5, 2, 5, 2, 11, 3, 4, 17, 6, 2, 1),
                     c("id", "transportation", "gasprice", "suv", "carmake",
                       "tankvol", "tanklast", "city", "oneway", "schtimes", "labnum")),
                   na = "."
)

q2 <- bind_rows(lab1q2, lab2q2)
q1 <- bind_rows(lab1q1, lab2q1)

lab_data <- full_join(
  x=q1,
  y=q2,
  by="id"
)

m1 <- lm(tankvol ~ tanklast, data = lab_data)
summary(m1)
autoplot(m1)


lab_data <- lab_data %>%
  mutate(transportation.f = factor(transportation, 
                                   levels=c(1, 2, 3, 4),
                                   labels=c("Car", "Walk", "Public Transit", "Bike")))
m2 <- lm(oneway ~ transportation.f, data = lab_data)
summary(m2)

lab_data <-
  lab_data %>%
  mutate(transportation.f = relevel(transportation.f, "Walk"))
m3 <- lm(oneway ~ transportation.f, data = lab_data)
summary(m3)
