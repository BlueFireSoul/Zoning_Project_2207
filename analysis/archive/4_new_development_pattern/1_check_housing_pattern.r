library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(lfe)

houston_counties <- c(48015, 48039, 48071, 48157, 48167, 48201, 48291, 48339, 48473)
dallas_counties <- c(48085, 48113, 48121, 48139, 48231, 48257, 48397, 48251, 48367, 48439, 48497)
LA_counties <- c(06037)
LA_core <- c(34.329784, -118.68765, 33.568817, -117.789517)
property_current <- readRDS(property_c_fadj_rds)
if (run_code=="tx"){
  property_current %<>% filter(col3 %in% houston_counties)
}
if (run_code=="ca"){
  property_current %<>% filter(col48 >= LA_core[3]) %>%
    filter(col48 <= LA_core[1]) %>%
    filter(col49 >= LA_core[2]) %>%
    filter(col49 <= LA_core[4])
}

property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>% select('track_id', 'col48', 'col49') %>% distinct(col48, col49, .keep_all = TRUE)

if (run_code=="tx"){
  property_current_m <- inner_join(property_current, property_coord_dict, by = c("col48", "col49")) %>%
    mutate(col201 = if_else(is.na(col201) & house_type == "s", 1, col201)) 
} else {
  property_current_m <- inner_join(property_current, property_coord_dict, by = c("col48", "col49")) %>%
    mutate(col201 = if_else(is.na(col201) & house_type == "s", 1, col201)) 
}

median_adj_land_df <- property_current_m %>%
  group_by(track_id, house_type) %>%
  summarize(median_adj_land = median(adj_land)) %>%
  filter(house_type == "s") %>%
  select(!house_type)

median_adj_land_num <- quantile((property_current_m %>% filter(house_type == "s"))$adj_land, 0.5, na.rm = TRUE)

property_current_m <- merge(property_current_m, median_adj_land_df, by = "track_id", all.x = TRUE) %>%
  # mutate(median_adj_land = ifelse(is.na(median_adj_land),median_adj_land_num,median_adj_land) ) %>%
  mutate(median_adj_land = median_adj_land_num) %>%
  mutate(norm_floorspace = adj_f_ratio * median_adj_land) %>%
  mutate(d = col201/adj_land * median_adj_land) %>%
  mutate(b = col165/adj_land * median_adj_land) %>%
  mutate(lognorm_floorspace = log(norm_floorspace)) %>%
  mutate(logd = log(d)) %>%
  mutate(logb = log(b)) %>%
  mutate(pu_floorspace = norm_floorspace/d) %>%
  mutate(logpuf = log(pu_floorspace))

#### BEGIN HERE
plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 > 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 <= 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 > 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 <= 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "lm") %>% filter(col163 > 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "lm") %>% filter(col163 <= 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "s") %>% filter(col163 > 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "s") %>% filter(col163 <= 2000))$norm_floorspace, lower_perc = 5, upper_perc = 95)

plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 > 2000))$pu_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 <= 2000))$pu_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 > 2000))$pu_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 <= 2000))$pu_floorspace, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "lm") %>% filter(col163 > 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "lm") %>% filter(col163 <= 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 > 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "sm") %>% filter(col163 <= 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 > 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type != "s") %>% filter(col163 <= 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "s") %>% filter(col163 > 2000))$d, lower_perc = 5, upper_perc = 95)
plot_frequency((property_current_m %>% filter(house_type == "s") %>% filter(col163 <= 2000))$d, lower_perc = 5, upper_perc = 95)

frequency_table((property_current_m %>% filter(col163 > 2000))$house_type)
frequency_table((property_current_m %>% filter(col163 <= 2000))$house_type)
frequency_table((property_current_m)$col163)

plot_frequency((property_current_m)$col163, lower_perc = 5, upper_perc = 100)
