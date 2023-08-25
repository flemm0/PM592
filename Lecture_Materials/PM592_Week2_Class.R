## PM592 Week 2 R Code

library(tidyverse)
library(psych)      # For descriptives

# Read in OKC data set
# Note the file must be in the same location as the working directory
#   or you will need to refer to the full path name
okc <- read_csv("okcprofiles.csv")

# Let's remove some implausible height values
okc$height %>% sort()
# 9 inches is pretty low. Let's set all values less than 12 inches to NA
okc <-
  okc %>%
  mutate(height = if_else(height < 12, NA_real_, height))

# Histogram of height
okc %>%
  ggplot(aes(x = height)) +
  stat_count() +
  stat_function(fun = function(x, mean, sd, n){
    n * dnorm(x = x, mean = mean, sd = sd)
  },
  args = with(okc, c(mean = mean(height, na.rm=T), 
                     sd = sd(height, na.rm=T), 
                     n = length(height))),
  color = "#BF5700", size = 1)

# Create height z-scores
okc <-
  okc %>%
  mutate(height_z = (height - mean(height, na.rm=T))/sd(height, na.rm=T)) 

# Alternately, use the "scale" function
okc <-
  okc %>%
  mutate(height_z = scale(height))

# Histogram of height and height z-score
okc %>%
  ggplot(aes(x = height)) +
  stat_count() +
  stat_count(aes(x = height_z), fill = "blue")


# Creating the normal curve
funcShaded <- function(x) {
  y <- dnorm(x)
  y[x < 1.70] <- NA
  return(y)
}

ggplot(tibble(x = -4:4), aes(x = x)) +
  stat_function(fun = dnorm, color = "#BF5700") +
  stat_function(fun=funcShaded, geom="area", fill="#BF5700", alpha=0.2)

# Describe age and height
okc %>%
  select(height, age) %>%
  describe()

# QQ plots for height and age
okc %>%
  ggplot(aes(sample=height)) +
  geom_qq() +
  geom_qq_line(size = 2, color = "tan")



# Sample Example
sample_example <- tibble(
  nosmoke_10 = replicate(1000, mean(sample(okc$smokes_yn, 10, replace = T), na.rm=T)),
  nosmoke_100 = replicate(1000, mean(sample(okc$smokes_yn, 100, replace = T), na.rm=T)),
  nosmoke_1000 = replicate(1000, mean(sample(okc$smokes_yn, 1000, replace = T), na.rm=T)),
  height_10 = replicate(1000, mean(sample(okc$height, 10, replace = T), na.rm=T)),
  height_100 = replicate(1000, mean(sample(okc$height, 100, replace = T), na.rm=T)),
  height_1000 = replicate(1000, mean(sample(okc$height, 1000, replace = T), na.rm=T)),
  age_10 = replicate(1000, mean(sample(okc$age, 10, replace = T), na.rm=T)),
  age_100 = replicate(1000, mean(sample(okc$age, 100, replace = T), na.rm=T)),
  age_1000 = replicate(1000, mean(sample(okc$age, 1000, replace = T), na.rm=T))
)

sample_example_long <-
  sample_example %>%
  pivot_longer(
    everything(),
    names_to = "value",
    values_to = "mean") %>%
  separate(value, 
           into = c("var", "reps"),
           sep = "_")

sample_example_long %>%
  mutate(reps = factor(reps, levels = c("10", "100", "1000"))) %>%
  ggplot(aes(x = mean)) +
  facet_grid(cols = vars(var), rows = vars(reps), scales = "free_x") +
  geom_histogram(bins=100)
