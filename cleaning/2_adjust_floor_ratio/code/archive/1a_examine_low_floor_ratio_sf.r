library(glue)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

property_current <- readRDS(property_current_rds)

property_current %<>% mutate(col48f1 = round(col48, digits = 1),col49f1 = round(col49, digits = 1),col48f2 = round(col48, digits = 2),col49f2 = round(col49, digits = 2))
property_current_dt <- as.data.table(property_current)

# Calculate group-level statistics using data.table syntax
property_current_dt[, `:=` (
  count1 = .N,
  hcol202 = max(col202, na.rm = TRUE)), by = .(col3, col161)]

property_current_dt[, `:=` (
  count1a = .N), by = .(col48f2, col49f2 , col161, col34)]

property_current_dt[, `:=` (
  count2 = .N,
  lcol161 = min(col161, na.rm = TRUE),
  hhcol202 = max(col202, na.rm = TRUE)), by = .(col48, col49)]

property_current_dt[, `:=` (
  count2a = .N), by = .(col48, col49, col34)]

property_current_dt[, `:=` (
  count2b = .N), by = .(col48, col49, col161)]

property_current_dt[, `:=` (
  count2c = .N), by = .(col48f2, col49f2, col161)]

property_current_dt[, `:=` (
  el_land = lcol161 / pmax(count1, count2, na.rm = TRUE),
  eh_floorspace = pmax(hcol202, hhcol202),
  adj_land = col161 / pmax(count2b, na.rm = TRUE),
  adj_land2 = col161 / pmax(count2c, na.rm = TRUE)
  )]

property_current_dt[, `:=` (
  eh_f_ratio = ifelse(eh_floorspace/el_land == 0 | eh_floorspace/el_land == -Inf, NA, eh_floorspace/el_land),
  eh_f_ratio2 = ifelse(eh_floorspace/col161 == 0 | eh_floorspace/col161 == -Inf, NA, eh_floorspace/col161),
  eh_f_ratio3 = ifelse(col202/el_land == 0 | col202/el_land == -Inf, NA, col202/el_land),
  eh_f_ratio4 = ifelse(col202/adj_land == 0 | col202/adj_land == -Inf, NA, col202/adj_land),
  eh_f_ratio5 = ifelse(col202/adj_land2 == 0 | col202/adj_land2 == -Inf, NA, col202/adj_land2)
)]


# Convert data.table back to data frame
property_current <- as.data.frame(property_current_dt)
exam2 <- property_current %>%
  filter(col34 == 112, col3 == 6075)
