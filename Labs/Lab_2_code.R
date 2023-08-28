library(tidyverse)
library(readr)

setwd('~/Desktop/USC_Fall2023/PM592/Labs')


### 1

chs_individual <- read_csv('../data/chs_individual.csv')
chs_regional <- read_csv('../data/chs_regional.csv')

# a
which(!(chs_individual$townname %in% chs_regional$townname))

# b
which(!(chs_regional$townname %in% chs_individual$townname))

# c
chs_merged <- chs_individual %>%
  left_join(chs_regional, by="townname")


### 2
chs_merged <- chs_merged %>%
  mutate(hispanic.f = factor(hispanic, levels=c(0,1), labels=c("Non-Hispanic", "Hispanic"))) %>%
  mutate(educ_parent.f = factor(educ_parent,
                                levels=c(1, 2, 3, 4, 5),
                                labels=c("<12 Grade", 
                                         "Grade 12",
                                         "Some post high school",
                                         "4 years of college",
                                         "Some post-graduate")))

# a
chs_merged %>%
  count(educ_parent, educ_parent.f)

# b
chs_merged %>%
  count(hispanic, hispanic.f)


### 3

# a
chs_merged %>%
  ggplot(aes(sample=fvc)) +
  geom_qq() +
  geom_qq_line(color='red') # the edges of the qq plot look to be a bit non-normal

# b
chs_merged %>%
  ggplot(aes(x=fvc)) + geom_histogram() # looks a bit skewed

# c
shapiro.test(chs_merged$fvc) # p < 0.001 rejects null hypothesis of normality


### 4
chs_merged <- 
  chs_merged %>%
  mutate(fev_fvc_ratio = fev/fvc) %>%
  mutate(fev_fvc_ratio_cat = 
           ifelse(fev_fvc_ratio >= .7, "Normal", 
                  ifelse(fev_fvc_ratio >= .6, "Mild Deficiency",
                         ifelse(fev_fvc_ratio >= .5, "Moderate Deficiency", 
                                ifelse(!is.na(fev_fvc_ratio), "Severe Deficiency", NA)))))

chs_merged %>%
  count(fev_fvc_ratio_cat) %>%
  mutate(n_pct = n / sum(n))


### 5

# a
chs_merged %>%
  ggplot(aes(sample=fev_fvc_ratio)) +
  geom_qq() +
  geom_qq_line(color='red') # the qqplot does not look normal

# b
chs_merged %>%
  ggplot(aes(x=fev_fvc_ratio)) + 
  geom_histogram() # left skew

# c
shapiro.test(chs_merged$fev_fvc_ratio) # p << 0.001 rejects null hypothesis of normality


### 6

# d
var.test(fev_fvc_ratio ~ as.factor(male), data=chs_merged)

t.test(fev_fvc_ratio ~ as.factor(male), var.equal = T, data=chs_merged)

# e
var.test(fev_fvc_ratio ~ hispanic.f, data=chs_merged)

t.test(fev_fvc_ratio ~ hispanic.f, var.equal = T, data=chs_merged)

# f
var.test(fev_fvc_ratio ~ as.factor(asthma), data=chs_merged)

t.test(fev_fvc_ratio ~ as.factor(asthma), var.equal = F, data=chs_merged)


