library(readr)
library(tidyverse)
library(skimr)
library(GGally)

ex_sos <- readr::read_csv("data/ex_sos.csv")

str(ex_sos)


## Question 1

# 1a
ex_sos <- ex_sos %>%
  mutate(m_help.z = scale(m_help)[,1])

# 1b
skim(ex_sos)


## Question 2

# 2a
ggpairs(ex_sos)


## Question 3

# 3a