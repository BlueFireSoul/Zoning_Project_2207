library(glue)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

property_current <- readRDS(property_current_rds)

property_current_dt <- as.data.table(property_current)

# Calculate group-level statistics using data.table syntax
property_current_dt[, `:=` (
  count1 = .N,
  hcol202 = max(col202, na.rm = TRUE)), by = .(col3, col161)]

property_current_dt[, `:=` (
  count2 = .N,
  lcol161 = min(col161, na.rm = TRUE),
  hhcol202 = max(col202, na.rm = TRUE)), by = .(col48, col49)]

property_current_dt[, `:=` (
  el_land = lcol161 / pmax(count1, count2, na.rm = TRUE),
  eh_floorspace = pmax(hcol202, hhcol202))]

property_current_dt[, `:=` (
  eh_f_ratio = ifelse(eh_floorspace/el_land == 0 | eh_floorspace/el_land == -Inf, NA, eh_floorspace/el_land)
)]

property_current_dt[, `:=` (
  eh_f_change = eh_f_ratio/f_ratio)]

# Convert data.table back to data frame
property_current <- as.data.frame(property_current_dt)
exam1 <- property_current %>%
  filter(col34 == 112, col3 == 6013)
exam2 <- property_current %>%
  filter(col34 == 112, col3 == 6075)
exam3 <- property_current %>%
  filter(col34 == 112, col3 == 6077)
exam4 <- property_current %>%
  filter(col34 == 163, col3 == 6075)
