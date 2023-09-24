library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)
library(ggplot2)
property_current <- readRDS(property_apt_rds)

property_coord_dict <- read.csv(paste0(output_dir,'property_coord_dict_zone_adj')) %>%
  mutate(col1 = as.character((col1)))

mortgage_data <- readRDS(mortgage_merge3_rds) %>%
  group_by(col1) %>%
  summarize(m_amount = mean(m_amount), hm_income = mean(hm_income))

coordinates <- st_as_sf(property_current, coords = c("col49", "col48"), crs = 4326)
specific_point <- st_point(c(-71.05804050694815,42.36038876047336))
specific_point <- st_sfc(specific_point, crs = 4326)
specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)
property_current$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current$distance <- as.numeric(property_current$distance)

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  left_join(mortgage_data, by = 'col1') %>%
  mutate(property_dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201, property_far = col202_sum/adj_land)%>%
  filter(pu_size<5000, pu_size>500, zo_usety==1)%>%
  mutate(close = ifelse(distance<20000,1,0))%>%
  mutate(dupac_ratio = property_dupac/dupac_adj) %>%
  mutate(far_ratio = property_far/far_adj)%>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj*0.9,1,0),
         dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj*0.9,1,0),
         dupac_ov = ifelse(property_dupac>dupac_adj*1.1,1,0),
         far_v = ifelse(property_far>far_adj*0.9,1,0),
         far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj*0.9,1,0),
         far_ov = ifelse(property_far>far_adj*1.1,1,0))

property_old <- property_current_mod %>%
  filter(col163<=1940)%>%
  select(-col1)
property_check <- property_current_mod %>%
  filter(col163>=1960, dupac_v == 1)%>%
  select(-col1)
property_checke <- property_current_mod %>%
  filter(col163>=1960, dupac_e == 1)%>%
  select(-col1)
property_checko <- property_current_mod %>%
  filter(col163>=1960, dupac_ov == 1)%>%
  select(-col1)
property_checkr <- property_current_mod %>%
  filter(col163>=1960, dupac_v != 1)%>%
  select(-col1)

write.csv(property_old, file = paste0(output_dir,'property_old.csv'), row.names = FALSE)
write.csv(property_checke, file = paste0(output_dir,'property_e.csv'), row.names = FALSE)
write.csv(property_checko, file = paste0(output_dir,'property_ov.csv'), row.names = FALSE)
write.csv(property_checkr, file = paste0(output_dir,'property_r.csv'), row.names = FALSE)

model <- lm(col201 ~ dupac_ov, data = property_check)
summary(model)


model <- felm(col201 ~ dupac_ov  | tractID19, data = property_check)
summary(model)

frequency_table(property_checke$col201)
frequency_table(property_checko$col201)
percentile_plot(property_checke$col163,1,99)
percentile_plot(property_checko$col163,1,99)
percentile_plot(property_checke$hm_income,1,99)
percentile_plot(property_checko$hm_income,1,99)
percentile_plot(property_checke$pu_size,1,99)
percentile_plot(property_checko$pu_size,1,99)

