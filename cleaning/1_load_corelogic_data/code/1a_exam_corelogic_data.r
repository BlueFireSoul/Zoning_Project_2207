library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(data.table)

define_counties <- function(){
  if (run_code == "ca"){
    sf_counties <- c(06001, 06013, 06041, 06055, 06075, 06081, 06085, 06095, 06097)
    counties <- c(sf_counties)
  }
  return(counties)
}

process_procedure <- function(prop_data) {
  counties <- define_counties()

  prop_data <- prop_data %>%
    filter(col3 %in% counties)

  # Add new columns
  s <- c(163)
  sm <- c(100, 102, 148, 115, 151, 165, 132)
  lm <- c(111, 112, 117, 106, 133)
  prop_data <- prop_data %>%
    filter(col34 %in% c(s,sm,lm)) %>%
    mutate(house_type = case_when(col34 %in% s ~ "s",
                                  col34 %in% sm ~ "sm",
                                  col34 %in% lm ~ "lm",
                                  TRUE ~ NA_character_))
  return(prop_data)
}

process_current_data <- function() {
  # Load data
  prop_data <- fread(property_current, select = c(3, 19, 34, 38, 39), skip = 1, header = FALSE, sep = "|")
  names(prop_data) <- paste0("col", c(3, 19, 34, 38, 39))

  prop_data <- process_procedure(prop_data)
  # Export data
  saveRDS(prop_data, file = file.path(temp_dir,'exam_zoning_code.RDS'))
}

process_current_data()

property_current <- readRDS(file.path(temp_dir,'exam_zoning_code.RDS'))

property_current %<>% filter(col19 != "", col38 != "")

property_current_count <- property_current %>%
  group_by(col3, col19, col34, col38, col39) %>%
  summarise(count = n()) %>% filter(count>10)
library(dplyr)

unique_col39_counts <- property_current %>%
  count(col39, name = "count")

unique_col38_counts <- property_current %>%
  count(col38, name = "count") %>% filter(count>10)

unique_col19_counts <- property_current %>%
  count(col19, name = "count")

