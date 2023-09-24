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
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201)%>%
  filter(pu_size<5000, pu_size>500, dupac_eff!= 0, mnls_eff != 0, zo_usety==1, mxdu_eff != 0)%>%
  mutate(eff_minsize = 43560/dupac_eff)%>%
  mutate(cutoff = ifelse(eff_minsize*1 > perland & eff_minsize*0.5 < perland,1,0))%>%
  mutate(close = ifelse(distance<20000,1,0))%>%
  mutate(zone_tract_id = paste0(dupac_eff, "_", tractID19)) %>%
  mutate(below_cutoff = ifelse(eff_minsize*0.5 >= perland,1,0)) %>%
  mutate(below_cutoff2 = ifelse(eff_minsize >= perland,1,0)) %>%
  mutate(zone_ratio = perland/eff_minsize)%>%
  mutate(mnlot_hold = ifelse(mnls_eff<adj_land,1,0))%>%
  mutate(mnlot_hold2 = ifelse(mnls_eff/mxdu_eff<adj_land,1,0))%>%
  mutate(mnlot_hold3 = ifelse(mnls_eff/mxdu_eff/2<adj_land,1,0))

frequency_table(property_current_mod$mnlot_hold)
frequency_table(property_current_mod$mnlot_hold2)
frequency_table(property_current_mod$mnlot_hold3)

nonparametric_plot(property_current_mod,'mnls_eff','mxdu_eff',0,99)
nonparametric_plot(property_current_mod,'adj_land','col201',0,99)
nonparametric_plot(property_current_mod,'mnlot_hold','distance',5,95)
nonparametric_plot(property_current_mod,'mnlot_hold2','distance',5,95)
nonparametric_plot(property_current_mod,'mnlot_hold3','distance',5,95)

zone_tract_check <- property_current_mod %>%
  group_by(zone_tract_id) %>%
  summarize(below_cutoff_r = mean(below_cutoff), zone_count = n(), ave_perland = mean(perland),
            ave_dist = mean(distance), dupac_eff = first(dupac_eff), eff_minsize= first(eff_minsize), ave_col201 = mean(col201)) %>%
  mutate(dupac_hold = ifelse(eff_minsize<ave_perland,1,0)) %>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))

zone_check <- property_current_mod %>%
  group_by(zoning_shp_id, mxdu_eff, mnls_eff) %>%
  summarize(below_cutoff_r = mean(below_cutoff), zone_count = n(), ave_perland = mean(perland),
            ave_dist = mean(distance), dupac_eff = first(dupac_eff), eff_minsize= first(eff_minsize), 
            ave_col201 = mean(col201), ave_adj_land = mean(adj_land)) %>%
  ungroup() %>%
  mutate(dupac_hold = ifelse(eff_minsize<ave_perland,1,0))%>%
  mutate(mnls_hold = ifelse(mnls_eff<ave_adj_land,1,0))%>%
  mutate(mnls_hold2 = ifelse(mnls_eff/mxdu_eff<ave_adj_land,1,0))%>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))

property_current_mod2 <- property_current_mod %>%
  merge(zone_tract_check, by = 'zone_tract_id')

property_sale <- property_current_mod2 %>%
  mutate(sale_year = floor(col149/1e4)) %>%
  mutate(sale_year_st = as.character(sale_year)) %>%
  mutate(per_sale_price = col151/col201) %>%
  filter(sale_year >2010 )

percentile_plot(property_current_mod$zone_ratio,0,95)
nonparametric_plot(property_current_mod,'perland','eff_minsize',0,95)
nonparametric_plot(zone_tract_check,'ave_perland','eff_minsize',0,95)

frequency_table(zone_tract_check$dupac_hold)
ggplot(zone_tract_check, aes(x = log(eff_minsize), y = log(ave_perland), size = zone_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  # Add the 45-degree line
  labs(x = "Effective Min Size", y = "Average Per Land", size = "Unit Count") +
  theme_minimal()

ggplot(zone_check, aes(x = log(mnls_eff), y = log(ave_adj_land), size = zone_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  
  theme_minimal()
frequency_table(zone_check$mnls_hold)

ggplot(zone_check, aes(x = log(mnls_eff/mxdu_eff), y = log(ave_adj_land), size = zone_count)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +  
  theme_minimal()
frequency_table(zone_check$mnls_hold2)
nonparametric_plot(zone_check,'mnls_hold2','ave_dist',0,95)

nonparametric_plot(zone_check,'mnls_eff','ave_dist',0,95)
ggplot(zone_check, aes(y = mnls_eff,x = ave_dist, size = zone_count)) +
  geom_point() +
  theme_minimal()

percentile_plot(zone_check$mnls_eff,5,95)
percentile_plot(zone_check$zone_count,0,100)
nonparametric_plot(zone_check,'zone_count','ave_dist',0,95)

frequency_table(property_current_mod$mnlot_hold)
weighted_avg <- weighted.mean(zone_check$mnls_hold, zone_check$zone_count)
