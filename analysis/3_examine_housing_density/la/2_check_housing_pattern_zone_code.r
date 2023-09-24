library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)
library(readxl)

zoning_code <- read_excel(append_ori_path(paste0(output2_dir,'process_zoning_code_table.xlsx'))) %>%
  mutate(lot_area_per_du = ifelse(is.na(lot_area_per_du),min_lot/min_lot_max_density,lot_area_per_du))%>%
  mutate(lot_area_per_du = ifelse(is.na(lot_area_per_du),43560/dupac_limit,lot_area_per_du))

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
  merge(zoning_code, by = c('CITY','CITY_ZN_CO')) %>%
  mutate(adj_land = ACRES*43560) %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201)%>%
  filter(pu_size<5000, pu_size>300, lot_area_per_du!= 0)%>%
  mutate(eff_minsize = lot_area_per_du)%>%
  mutate(close = ifelse(distance<40000,1,0))%>%
  mutate(zone_ratio = perland/eff_minsize)

tract_level <- property_current_mod %>%
  group_by(tractID19) %>%
  summarize(pu_size = mean(pu_size), perland = mean(perland), eff_minsize=mean(eff_minsize), tract_count = n(), distance = mean(distance)) %>%
  mutate(zone_hold = ifelse(perland>eff_minsize,1,0))%>%
  mutate(zone_hold2 = ifelse(perland>eff_minsize/2,1,0))
frequency_table(tract_level$zone_hold)

fuzzy_threshold <- 0.2

property_check <- property_current_mod %>%
  mutate(cutoff = ifelse(eff_minsize *(1+fuzzy_threshold)> perland 
                         & eff_minsize*(1-fuzzy_threshold)<perland,1,0))%>%
  mutate(sale_year = floor(col149/1e4)) %>%
  mutate(sale_year_st = as.character(sale_year)) %>%
  mutate(per_sale_price = col151/col201)%>%
  mutate(density_bind = ifelse(eff_minsize *1.1 >perland,1,0))

nonparametric_plot(property_check,'density_bind','pu_size',5,99)

height_check <- property_current %>%
  mutate(pu_size = col202_sum/col201, perland = adj_land/col201)%>%
  filter(pu_size > 500, pu_size<5000)%>%
  mutate(height_bind2 = ifelse(col199>= 2, 1,0))%>%
  mutate(height_bind3 = ifelse(col199>= 3, 1,0))%>%
  mutate(far = col202_sum/adj_land)%>%
  mutate(far_bind1 = ifelse(far>= 1, 1,0))%>%
  mutate(far_bind07 = ifelse(far>= 0.7, 1,0))

nonparametric_plot(height_check,'height_bind2','pu_size',5,95)
nonparametric_plot(height_check,'height_bind3','pu_size',5,95)
nonparametric_plot(height_check,'far_bind1','pu_size',5,95)
nonparametric_plot(height_check,'far_bind07','pu_size',5,95)

nonparametric_plot(height_check,'col199','far',5,99)
nonparametric_plot(height_check,'far','col201',5,95)
nonparametric_plot(height_check,'adj_land','pu_size',5,95)
nonparametric_plot(height_check,'col202_sum','pu_size',5,90)
nonparametric_plot(height_check,'col199','pu_size',5,90)
nonparametric_plot(height_check,'perland','pu_size',5,90)
nonparametric_plot(height_check,'far','pu_size',5,90)

frequency_table(property_check$cutoff)
percentile_plot(property_check$distance,1,99)

model <- lm(log(pu_size)~ log(perland) + cutoff + col201 + I(col201^2), data = property_check)
summary(model)
model <- felm(log(pu_size)~ log(perland) + cutoff + col201 + I(col201^2)  | tractID19, data = property_check)
summary(model)
