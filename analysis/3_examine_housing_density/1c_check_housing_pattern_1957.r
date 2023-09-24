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
  mutate(zone_ratio = perland/eff_minsize)


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



property_modern <- property_current_mod %>%
  filter(col163>=1960, col163<1970)

property_old <- property_current_mod %>%
  filter(col163<1955, col163>1945)

nonparametric_plot(property_current_mod,'perland','pu_size',0,100)
nonparametric_plot(property_modern,'perland','pu_size',0,100)
nonparametric_plot(property_old,'perland','pu_size',0,100)

nonparametric_plot(property_current_mod,'property_far','pu_size',0,100)
nonparametric_plot(property_modern,'property_far','pu_size',0,100)
nonparametric_plot(property_old,'property_far','pu_size',0,100)

percentile_plot(property_current_mod$col163,5,95)
percentile_plot(property_modern$zone_ratio,0,95)

nonparametric_plot(property_modern,'zone_ratio','distance',5,95)
nonparametric_plot(property_modern,'zone_ratio','col201',5,95)
nonparametric_plot(property_modern,'below_cutoff0','distance',5,95)
nonparametric_plot(property_modern,'below_cutoff0','pu_size',5,95)
nonparametric_plot(property_modern,'zone_ratio','pu_size',5,95)


zone_tract_check <- property_modern %>%
  group_by(zone_tract_id) %>%
  summarize(below_cutoff_r = mean(below_cutoff), zone_count = n(), ave_perland = mean(perland),
            ave_dist = mean(distance), dupac_eff = first(dupac_eff), eff_minsize= first(eff_minsize), ave_col201 = mean(col201)) %>%
  mutate(dupac_hold = ifelse(eff_minsize<ave_perland,1,0)) %>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))

tract_check <- property_modern %>%
  group_by(tractID19) %>%
  summarize(below_cutoff_r = mean(below_cutoff), zone_count = n(), ave_perland = mean(perland),
            ave_dist = mean(distance), dupac_eff = first(dupac_eff), eff_minsize= first(eff_minsize), ave_col201 = mean(col201)) %>%
  mutate(dupac_hold = ifelse(eff_minsize<ave_perland,1,0)) %>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))

zone_check <- property_modern %>%
  group_by(zoning_shp_id, mxdu_eff, mnls_eff) %>%
  summarize(below_cutoff_r = mean(below_cutoff), zone_count = n(), ave_perland = mean(perland),
            ave_dist = mean(distance), dupac_eff = first(dupac_eff), eff_minsize= first(eff_minsize), 
            ave_col201 = mean(col201), ave_adj_land = mean(adj_land)) %>%
  ungroup() %>%
  mutate(dupac_hold = ifelse(eff_minsize<ave_perland,1,0))%>%
  mutate(mnls_hold = ifelse(mnls_eff<ave_adj_land,1,0))%>%
  mutate(mnls_hold2 = ifelse(mnls_eff/mxdu_eff<ave_adj_land,1,0))%>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))


frequency_table(zone_tract_check$dupac_hold)
frequency_table(zone_check$dupac_hold)
frequency_table(tract_check$dupac_hold)

ggplot(zone_check, aes(x = log(eff_minsize), y = log(ave_perland), size = zone_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Add the 45-degree line
  labs(x = "Effective Min Size", y = "Average Per Land", size = "Unit Count") +
  theme_minimal()

ggplot(tract_check, aes(x = log(eff_minsize), y = log(ave_perland), size = zone_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Add the 45-degree line
  labs(x = "Effective Min Size", y = "Average Per Land", size = "Unit Count") +
  theme_minimal()


