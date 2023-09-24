library(glue)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(tidyverse)

# Read in property_current data frame from RDS file
property_current <- readRDS(property_current_rds)

# Filter out missing values in col202
property_current %<>%
  filter(!is.na(col202))%>%
  group_by(col34, col48, col49, col161) %>%
  mutate(group_count = n()) %>%
  filter(group_count > 2)

# Compute group counts by col48, col49, col161
property_current_agg <- property_current %>%
  mutate(q75 = quantile(col202, 0.50, na.rm = TRUE), outliner = ifelse(col202 > q75*5,"1","0")) %>%
  ungroup() %>%
  group_by(col34, col48, col49, col161, outliner) %>%
  summarize(
    sum_within = sum(col202),
    counto = n()
  ) %>%
  ungroup() %>%
  pivot_wider(
    id_cols = c("col34", "col48", "col49", "col161"),
    names_from = "outliner", 
    values_from = c("sum_within","counto")) %>%
  mutate(sum_ratio = sum_within_0/sum_within_1) %>%
  filter(!is.na(sum_ratio))


# Compute various summary statistics on col202 by group
property_current %<>%
  summarize(
    group_count = n(),
    max_col202 = max(col202),
    second_max_col202 = nth(col202, 2, default = NA),
    third_max_col202 = nth(col202, 3, default = NA),
    fourth_max_col202 = nth(col202, 4, default = NA),
    fifth_max_col202 = nth(col202, 5, default = NA),
    median_col202 = median(col202),
    min_col202 = min(col202),
    ratio_max_med_col202 = max_col202 / median_col202
  ) %>%
  full_join(property_current_agg, by = c("col34", "col48", "col49", "col161")) %>%
  filter(!is.na(sum_ratio))
