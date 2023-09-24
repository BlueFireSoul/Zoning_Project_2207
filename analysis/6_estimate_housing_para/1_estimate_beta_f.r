library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)
library(ggplot2)
property_current <- readRDS(property_apt_rds)
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

coordinates <- st_as_sf(property_current, coords = c("col49", "col48"), crs = 4326)
specific_point <- st_point(c(-71.05804050694815,42.36038876047336))
specific_point <- st_sfc(specific_point, crs = 4326)
specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)
property_current$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current$distance <- as.numeric(property_current$distance)

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  #mutate(
  #  adj_land = ifelse(!is.na(lot_areaft) & lot_areaft != 0, lot_areaft, adj_land)
  #) %>%
  #mutate(col201 = pmax(col201, units_est)) %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201, property_far = col202_sum/adj_land)%>%
  filter(pu_size<5000, pu_size>500, dupac_eff!= 0, zo_usety==1)%>%
  mutate(eff_minsize = 43560/dupac_eff)%>%
  mutate(cutoff = ifelse(eff_minsize*1 > perland & eff_minsize*0.5 < perland,1,0))%>%
  mutate(close = ifelse(distance<20000,1,0))%>%
  mutate(zone_tract_id = paste0(dupac_eff, "_", tractID19)) %>%
  mutate(below_cutoff = ifelse(eff_minsize*0.5 >= perland,1,0)) %>%
  mutate(below_cutoff0 = ifelse(eff_minsize*1.1 >= perland,1,0)) %>%
  mutate(zone_ratio = perland/eff_minsize) %>%
  mutate(norm_f = property_far*1) %>%
  mutate(norm_d = 1/perland)

property_predate1 <- property_current_mod %>%
  filter(col163<=1918)

property_predate2 <- property_current_mod %>%
  filter(col163<=1960)

property_natural <- property_current_mod %>%
  filter(eff_minsize*1 < perland)

model <- felm(norm_f ~ norm_d | tractID19 , data = property_current_mod)
summary(model)
model <- felm(norm_f ~ norm_d | tractID19 , data = property_predate1)
summary(model)
model <- felm(norm_f ~ norm_d | tractID19 , data = property_predate2)
summary(model)
model <- felm(norm_f ~ norm_d | tractID19 , data = property_natural)
summary(model)

# parcel_data_check <- property_current %>%
#   merge(property_coord_dict, by = 'col1') %>%
#   mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201, property_far = col202_sum/adj_land)%>% 
#   filter(pu_size<5000, pu_size>500, dupac_eff!= 0, zo_usety==1)%>%
#   mutate(bldg_area_ratio = col202_sum/bldg_area) %>%
#   mutate(units_est_ratio = col201/units_est) %>%
#   mutate(lot_areaft_ratio = adj_land/lot_areaft) %>%
#   filter(lot_areaft!=0)%>%
#   filter(units_est!=0)%>%
#   filter(bldg_area!=0)
# 
# percentile_plot(parcel_data_check$bldg_area_ratio,1,99)
# percentile_plot(parcel_data_check$units_est_ratio,1,99)
# percentile_plot(parcel_data_check$lot_areaft_ratio,1,99)
# 
# nonparametric_plot(parcel_data_check,'bldg_area_ratio','pu_size',0,100)
# nonparametric_plot(parcel_data_check,'units_est_ratio','pu_size',0,100)
# nonparametric_plot(parcel_data_check,'lot_areaft_ratio','pu_size',0,100)
