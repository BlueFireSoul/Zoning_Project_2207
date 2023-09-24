library(glue)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

property_current <- readRDS(property_current_rds)
property_current_dt <- as.data.table(property_current)

# Group the data by col161 and col3, calculate count1 and hcol161
property_current_dt[, `:=` (
  count1 = .N,
  hcol161 = max(col161, na.rm = TRUE)
), by = .(col161, col3)]

# Group the data by col48 and col49, calculate count2 and hhcol161
property_current_dt[, `:=` (
  count2 = .N,
  hhcol161 = max(col161, na.rm = TRUE)
), by = .(col48, col49)]

property_current_dt[, `:=` (
  eh_land := pmax(hcol161, hhcol161, na.rm = TRUE),
  el_floorspace = col202 / pmax(count1, count2, na.rm = TRUE)
)]

property_current_dt[, `:=` (
  el_f_ratio = ifelse(el_floorspace/eh_land == 0 | el_floorspace/eh_land == -Inf | el_floorspace/eh_land == Inf, NA, el_floorspace/eh_land)
)]

property_current_dt[, `:=` (
  el_f_change = el_f_ratio/f_ratio)]

# Convert data.table back to data frame
property_current <- as.data.frame(property_current_dt)
