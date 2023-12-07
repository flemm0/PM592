library(haven)
library(tidyverse)
library(skimr)
library(arrow)

# outcome variable: fasting glucose levels
# independent variables: physical activity, how healthy is diet
# confounders: age, bmi
# interaction terms: drink alcohol, gender

glu <- haven::read_xpt("Final_Project/data/P_GLU.XPT", 
                       col_select = c("SEQN", "LBXGLU")) %>% 
  data.frame() %>%
  rename("glucose" = "LBXGLU")

demographics <- haven::read_xpt("Final_Project/data/P_DEMO.XPT", 
                                col_select = c("SEQN", "RIAGENDR", "RIDAGEYR")) %>%
  data.frame() %>%
  rename("age" = "RIDAGEYR", "gender" = "RIAGENDR")

bmi <- haven::read_xpt("Final_Project/data/P_BMX.XPT", 
                       col_select = c("SEQN", "BMXBMI")) %>%
  data.frame() %>%
  rename("bmi" = "BMXBMI")

alcohol <- haven::read_xpt("Final_Project/data/P_ALQ.XPT", 
                           col_select = c("SEQN", "ALQ121")) %>%
  data.frame() %>%
  rename("alcohol_frequency" = "ALQ121")

pa <- haven::read_xpt("Final_Project/data/P_PAQ.XPT",
                      col_select = c("SEQN",
                                     "PAQ610", # days vigorous work
                                     "PAD615", # avg mins vigorous work
                                     "PAQ625", # days moderate work
                                     "PAD630", # avg mins moderate work
                                     "PAQ655", # days vigorous recr activity
                                     "PAD660", # avg mins vigorous recr activity
                                     "PAQ670", # days moderate recr activity
                                     "PAD675" # avg mins moderate recr activity
                                     )) %>%
  data.frame() %>%
  rename(
    "days_vigorous_work" = "PAQ610", 
    "avg_mins_vigorous_work" = "PAD615", 
    "days_moderate_work" = "PAQ625",
    "avg_mins_moderate_work" = "PAD630",
    "days_vigorous_recr_activity" = "PAQ655",
    "avg_mins_vigorous_recr_activity" = "PAD660",
    "days_moderate_recr_activity" = "PAQ670",
      "avg_mins_moderate_recr_activity" = "PAD675" 
    )

diet <- haven::read_xpt("Final_Project/data/P_DBQ.XPT", 
                        col_select = c("SEQN", "DBQ700")) %>%
  data.frame() %>%
  rename("diet_health" = "DBQ700")

sleep <- haven::read_xpt("Final_Project/data/P_SLQ.XPT", col_select = c("SEQN", "SLD012")) %>%
  data.frame() %>%
  rename("sleep_hrs" = "SLD012")

nhanes <- 
  glu %>%
  inner_join(demographics) %>%
  inner_join(bmi) %>%
  inner_join(alcohol) %>%
  inner_join(pa) %>%
  inner_join(diet) %>%
  inner_join(sleep) %>%
  tibble()


head(nhanes)

skimr::skim(nhanes)

# fill NA in physical activity with 0
pa_cols <- grep("^days_|^avg_mins_", names(nhanes), value = TRUE)
nhanes[pa_cols] <- lapply(nhanes[pa_cols], function(x) ifelse(is.na(x), 0, x))


# remove "missing" or "don't know" values in physical activity columns  
nhanes <- 
  nhanes %>%
  filter(across(starts_with("days_"), ~ . <= 7)) %>%
  filter(across(starts_with("avg_mins_"), ~ . <= 900))

# calculate MET activity scores for each individual
# https://www.physio-pedia.com/images/c/c7/Quidelines_for_interpreting_the_IPAQ.pdf
nhanes <-
  nhanes |>
  mutate(met = (4*avg_mins_moderate_work*days_moderate_work) + 
               (4*avg_mins_moderate_recr_activity*days_moderate_recr_activity) +
               (8*avg_mins_vigorous_work*days_vigorous_work) +
               (8*avg_mins_vigorous_recr_activity*days_vigorous_recr_activity)
           )

nhanes |>
  select(!starts_with("avg_mins")) |>
  select(!starts_with("days_")) |>
  write_parquet(sink="./Final_Project/data/nhanes.parquet")
