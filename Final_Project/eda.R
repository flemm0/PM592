library(haven)
library(tidyverse)
library(skimr)

# outcome: fasting blood glucose levels
# variables of interest: meals not home prepared, household food security category, dietary sugar intake, physical activity
# confounding variables: age, race/ethnicity, bmi, education level
# interacting variables: receiving FS benefit, dietary sugar intake, physical activity


## read in data
glu <- haven::read_xpt("~/USC_Fall_2023/PM592/Final_Project/data/P_GLU.XPT", 
                       col_select = c("SEQN", 
                                      "LBXGLU" # Fasting Glucose (mg/dL)
                                      ))
demo <- haven::read_xpt("~/USC_Fall_2023/PM592/Final_Project/data/P_DEMO.XPT",
                        col_select = c("SEQN",
                                       "RIAGENDR", # gender
                                       "RIDAGEYR", # age in years
                                       "RIDRETH3", # race/ethnicity
                                       "DMDEDUC2", # education level (adults 20 +)
                                       "DMDMARTZ", # marital status
                                       "INDFMPIR" # ratio of family income to poverty (5.0 means 5.0 or above)
                                       ))
dbq <- haven::read_xpt("~/USC_Fall_2023/PM592/Final_Project/data/P_DBQ.XPT",
                       col_select = c(
                                      "SEQN",
                                      "DBD895", # meals not home prepared
                                      "DBD910" # no. of frozen meals/pizza in past 30 days
                                      )) 
fsq <- haven::read_xpt("~/USC_Fall_2023/PM592/Final_Project/data/P_FSQ.XPT",
                       col_select = c("SEQN",
                                      "FSDHH", # household food security category
                                      "FSQ165" # HH FS benefit: ever received
                                      ))

## join data sets
nhanes <- inner_join(
  x=inner_join(
    x=inner_join(
      x=glu,
      y=demo,
      by="SEQN"
    ),
    y=dbq,
    by="SEQN"
  ),
  y=fsq,
  by="SEQN"
)

## data preprocessing
names(nhanes) <- c(
  "id",
  "glucose",
  "gender",
  "age_yr",
  "ethnicity",
  "education",
  "married",
  "income_poverty_ratio",
  "meals_not_home_prepared",
  "num_frozen_meals",
  "food_security_category",
  "received_fs_benefit"
)

head(nhanes)
skim(nhanes)

nhanes <-
  nhanes %>%
  mutate(gender = factor(gender, levels=c(1,2), labels=c("male", "female")),
         ethnicity = factor(ethnicity, 
                             levels=c(1,2,3,4,6,7),
                             labels=c("mexican_american",
                                      "other_hispanic",
                                      "non_hispanic_white",
                                      "non_hispanic_black",
                                      "non_hispanic_asian",
                                      "other_incl_multiracial")),
         education = factor(education, 
                            levels=c(1,2,3,4,5,7,9),
                            labels=c("less_than_9th_grade",
                                     "9-11th_grade_no_diploma",
                                     "high_school_graduate",
                                     "some_college_or_AA",
                                     "college_graduate_or_above",
                                     "refused",
                                     "dont_know")),
         married = factor(married,
                          levels=c(1,2,3,77,99),
                          labels=c("married/living_with_partner",
                                   "widowed/divorced/separated",
                                   "never_married",
                                   "refused",
                                   "dont_know")),
         food_security_category = factor(food_security_category,
                                         levels=c(1,2,3,4),
                                         labels=c("full",
                                                  "marginal",
                                                  "low",
                                                  "very_low"),
                                         ordered=TRUE)) %>%
  filter(meals_not_home_prepared < 21) %>% # remove refused/don't know
  filter(num_frozen_meals < 21) %>% # remove refused/don't know
  filter(received_fs_benefit < 2) %>% # remove refused/don't know
  mutate(received_fs_benefit = factor(received_fs_benefit,
                                      levels=c(1,2),
                                      labels=c("yes", "no")))

head(nhanes)
skim(nhanes)

nhanes %>%
  filter(meals_not_home_prepared < 22) %>%
  ggplot(aes(x=meals_not_home_prepared, y=glucose)) +
  geom_point(na.rm = T)

nhanes %>%
  ggplot(aes(x=food_security_category, y=glucose)) +
  geom_point(na.rm = T)

lm(glucose ~ meals_not_home_prepared, data = nhanes) %>% summary()
lm(glucose ~ food_security_category, data = nhanes) %>% summary()
lm(glucose ~ meals_not_home_prepared + food_security_category, data = nhanes) %>% summary()
