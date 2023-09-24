library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)

property_current <- readRDS(property_apt_rds)
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

scag_zone <- property_coord_dict %>%
  group_by(CITY_ZN_CO,CITY) %>%
  summarize(DENSITY = median(DENSITY), LOW = median(LOW), HIGH = median(HIGH))

property_coord_dict %<>% select(col1, col48, col49, CITY_ZN_CO, tractID19, ACRES,CITY ) %>%
  merge(scag_zone, by = c('CITY_ZN_CO','CITY'))

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

percentile_plot(property_current_mod$zone_ratio,5,95)
percentile_plot(property_current_mod$eff_minsize,5,95)
nonparametric_plot(property_current_mod,'eff_minsize','zone_ratio',5,95)
nonparametric_plot(property_current_mod,'eff_minsize','perland',5,95)

tract_level <- property_current_mod %>%
  group_by(tractID19) %>%
  summarize(pu_size = mean(pu_size), perland = mean(perland), eff_minsize=mean(eff_minsize), tract_count = n(), distance = mean(distance)) %>%
  mutate(zone_hold = ifelse(perland>eff_minsize,1,0))%>%
  mutate(zone_hold2 = ifelse(perland>eff_minsize/2,1,0))
frequency_table(tract_level$zone_hold)
weighted_avg <- weighted.mean(tract_level$zone_hold, tract_level$tract_count)
nonparametric_plot(tract_level,'zone_hold','distance',5,95)
nonparametric_plot(tract_level,'zone_hold2','distance',5,95)

ggplot(tract_level, aes(x = log(eff_minsize), y = log(perland), size = tract_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Add the 45-degree line
  labs(x = "Effective Min Size", y = "Average Per Land", size = "Unit Count") +
  theme_minimal()

frequency_table(property_current_mod$LU16)
frequency_table(property_current_mod$CITY)
frequency_table(property_current_mod$CITY_ZN_CO)

frequency_table((property_current_mod %>% filter(CITY=='Riverside'))$CITY_ZN_CO)
check <- (property_current_mod %>% filter(CITY=='Riverside'))
          