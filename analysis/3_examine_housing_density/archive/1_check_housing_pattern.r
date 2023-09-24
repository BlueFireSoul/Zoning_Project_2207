library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(lfe)

houston_counties <- c(48015, 48039, 48071, 48157, 48167, 48201, 48291, 48339, 48473)
dallas_counties <- c(48085, 48113, 48121, 48139, 48231, 48257, 48397, 48251, 48367, 48439, 48497)
property_current <- readRDS(property_c_fadj_rds)
if (run_code=="tx"){
    property_current %<>% filter(col3 %in% houston_counties)
}
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>% select('track_id', 'col48', 'col49') %>% distinct(col48, col49, .keep_all = TRUE)

if (run_code=="tx"){
  property_current_m <- inner_join(property_current, property_coord_dict, by = c("col48", "col49")) %>%
    mutate(col201 = if_else(is.na(col201) & house_type == "s", 1, col201)) %>%
    mutate(gamma = col124/(col124+col125))
  
  median_land_price <- quantile((property_current_m %>% filter(house_type == "s"))$col124, 0.5, na.rm = TRUE)
} else {
  property_current_m <- inner_join(property_current, property_coord_dict, by = c("col48", "col49")) %>%
    mutate(col201 = if_else(is.na(col201) & house_type == "s", 1, col201)) %>%
    mutate(gamma = col118/(col118+col119))
  
  median_land_price <- quantile((property_current_m %>% filter(house_type == "s"))$col118, 0.5, na.rm = TRUE)
  
}

median_adj_land_df <- property_current_m %>%
  group_by(track_id, house_type) %>%
  summarize(median_adj_land = median(adj_land)) %>%
  filter(house_type == "s") %>%
  select(!house_type)

median_adj_land_num <- quantile((property_current_m %>% filter(house_type == "s"))$adj_land, 0.5, na.rm = TRUE)

median_sfh_floor <- quantile((property_current_m %>% filter(house_type == "s"))$col202, 0.5, na.rm = TRUE)

median_gamma <- quantile(property_current_m$gamma, 0.5, na.rm = TRUE)
plot_frequency(property_current_m$gamma, lower_perc = 0, upper_perc = 100)
plot_frequency((property_current_m %>% filter(house_type != "s"))$gamma, lower_perc = 0, upper_perc = 100)

property_current_m <- merge(property_current_m, median_adj_land_df, by = "track_id", all.x = TRUE) %>%
  mutate(median_adj_land = ifelse(is.na(median_adj_land),median_adj_land_num,median_adj_land) ) %>%
  mutate(norm_floorspace = adj_f_ratio * median_adj_land) %>%
  mutate(d = col201/adj_land * median_adj_land) %>%
  mutate(b = col165/adj_land * median_adj_land) %>%
  mutate(lognorm_floorspace = log(norm_floorspace)) %>%
  mutate(logd = log(d)) %>%
  mutate(logb = log(b)) %>%
  mutate(pu_floorspace = norm_floorspace/d) %>%
  mutate(logpuf = log(pu_floorspace))

median_pu_floorspace <- quantile((property_current_m %>% filter(house_type != "s"))$pu_floorspace, 0.5, na.rm = TRUE)
p_pu_floorspace <- quantile((property_current_m)$pu_floorspace, 0.5, na.rm = TRUE)

plot_frequency((property_current_m %>% filter(house_type != "s"))$pu_floorspace, lower_perc = 0, upper_perc = 95)

plot_frequency((property_current_m %>% filter(house_type == "s"))$pu_floorspace, lower_perc = 0, upper_perc = 95)

# Calculate the 10th and 90th percentiles of y
lower_bound <- quantile(property_current_m$norm_floorspace, 0.05, na.rm = TRUE)
upper_bound <- quantile(property_current_m$norm_floorspace, 0.95, na.rm = TRUE)
lower_bound2 <- quantile(property_current_m$d, 0.01, na.rm = TRUE)
upper_bound2 <- quantile(property_current_m$d, 0.99, na.rm = TRUE)

# Subset your data to only include rows where y is between the 10th and 90th percentiles
property_current_m_subset <- property_current_m[property_current_m$norm_floorspace > lower_bound & property_current_m$norm_floorspace < upper_bound, ]

property_current_m_subset <- property_current_m_subset[property_current_m_subset$d > lower_bound2 & property_current_m_subset$d < upper_bound2, ]

plot_frequency(property_current_m_subset$norm_floorspace, lower_perc = 0, upper_perc = 100)
plot_frequency(property_current_m_subset$d, lower_perc = 1, upper_perc = 99)
plot_frequency(property_current_m_subset$col201, lower_perc = 10, upper_perc = 99)
frequency_table(property_current_m_subset$col201)
frequency_table(property_current_m_subset$col165)

model <- lm(lognorm_floorspace ~ logd, data = property_current_m_subset)
summary(model)

result <- felm(lognorm_floorspace ~ logd | track_id, data = property_current_m_subset)
summary(result)

model <- lm(norm_floorspace ~ d, data = property_current_m_subset)
summary(model)

result <- felm(norm_floorspace ~ d | track_id, data = property_current_m_subset)
summary(result)

model <- lm(pu_floorspace ~ d, data = property_current_m_subset)
summary(model)

result <- felm(pu_floorspace ~ d | track_id, data = property_current_m_subset)
summary(result)

model <- lm(logpuf ~ logd, data = property_current_m_subset)
summary(model)

result <- felm(logpuf ~ logd | track_id, data = property_current_m_subset)
summary(result)

