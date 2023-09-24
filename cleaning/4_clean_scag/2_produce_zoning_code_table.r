library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)

property_current <- readRDS(property_apt_rds)

property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

coordinates <- st_as_sf(property_current, coords = c("col49", "col48"), crs = 4326)
specific_point <- st_point(c(-118.24281465562832, 34.053675951292455))
specific_point <- st_sfc(specific_point, crs = 4326)
specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)
property_current$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current$distance <- as.numeric(property_current$distance)

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  mutate(adj_land = ACRES*43560) %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201)%>%
  filter(pu_size<5000, pu_size>300, HIGH!= 0)%>%
  mutate(eff_minsize = 43560/HIGH)%>%
  mutate(close = ifelse(distance<40000,1,0))%>%
  mutate(zone_id = paste0(HIGH, "_", tractID19)) %>%
  mutate(zone_ratio = perland/eff_minsize)


property_current_mod$code_group <- substr(property_current_mod$CITY_ZN_CO, 1, 1)

code_table <- property_current_mod %>%
  group_by(CITY,CITY_ZN_CO) %>%
  summarize(code_count = n())

code_table$code_group <- substr(code_table$CITY_ZN_CO, 1, 1)

city_table <- code_table %>%
  group_by(CITY) %>%
  summarize(city_count = sum(code_count))

group_table <- property_current_mod %>%
  group_by(CITY,code_group) %>%
  summarize(group_count = n())


code_table %<>% merge(city_table, by = 'CITY') %>%
  merge(group_table, by = c('CITY','code_group')) %>%
  select(city_count,group_count,code_count,CITY,CITY_ZN_CO) %>%
  arrange(desc(city_count), desc(group_count), CITY_ZN_CO)

write.csv(code_table, file = append_path(paste0(output_dir,'raw_zoning_code_table.csv')), row.names = FALSE)