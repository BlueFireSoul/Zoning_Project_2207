library(glue)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))


# Read in property_current data frame from RDS file
property_current <- readRDS(property_current_rds)

# Convert to data.table object
property_current_dt <- as.data.table(property_current)

# Keep observations where col202 is not missing
property_current_dt <- property_current_dt[!is.na(col202)]

# Compute group counts by col48, col49, col161
property_current_dt[, group_count := .N, by = .(col48, col49, col161)]

# Keep observations with group count > 5
property_current_dt <- property_current_dt[group_count > 5]

# Compute various summary statistics on col202 by group
property_current_dt_summary <- property_current_dt[, .(
  group_count = .N,
  max_col202 = max(col202),
  second_max_col202 = sort(col202, decreasing = TRUE)[2],
  third_max_col202 = sort(col202, decreasing = TRUE)[3],
  fourth_max_col202 = sort(col202, decreasing = TRUE)[4],
  fifth_max_col202 = sort(col202, decreasing = TRUE)[5],
  median_col202 = median(col202),
  min_col202 = min(col202)
), by = .(col48, col49, col161)]

# Compute the ratio of max col202 to min col202
property_current_dt_summary[, ratio_max_min_col202 := max_col202 / min_col202]





