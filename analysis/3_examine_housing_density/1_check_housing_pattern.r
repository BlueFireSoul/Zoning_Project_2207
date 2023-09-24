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
specific_point <- st_point(c(-71.05804050694815,42.36038876047336))
specific_point <- st_sfc(specific_point, crs = 4326)
specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)
property_current$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current$distance <- as.numeric(property_current$distance)

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201)%>%
  filter(pu_size<5000, pu_size>500, dupac_eff!= 0)%>%
  mutate(eff_minsize = 43560/dupac_eff)%>%
  mutate(cutoff = ifelse(eff_minsize*1 > perland & eff_minsize*0.5 < perland,1,0))%>%
  mutate(close = ifelse(distance<20000,1,0))%>%
  mutate(zone_id = paste0(dupac_eff, "_", tractID19)) %>%
  mutate(below_cutoff = ifelse(eff_minsize*0.5 >= perland,1,0)) %>%
  mutate(zone_ratio = perland/eff_minsize)

check <- property_current_mod %>%
  group_by(zone_id) %>%
  summarize(below_cutoff_r = mean(below_cutoff), below_cutoff_count = n()) %>%
  mutate(cutoff_switch = ifelse(below_cutoff_r<0.1,1,0))
property_current_mod2 <- property_current_mod %>%
  merge(check, by = 'zone_id')

percentile_plot(check$below_cutoff,0,95)
nonparametric_plot(check,'count','below_cutoff',0,95)

nonparametric_plot(property_current_mod,'perland','eff_minsize',0,95)

frequency_table(property_current_mod$cutoff)
frequency_table(property_current_mod$below_cutoff)

percentile_plot(property_current_mod$zone_ratio,0,95)

model <- lm(log(perland) ~ log(pu_size) + cutoff , data = property_current_mod)
summary(model)

model <- lm(log(perland) ~ log(pu_size) + cutoff + distance + I(distance^2) + cutoff*close, data = property_current_mod)
summary(model)

model <- lm(log(perland) ~ log(pu_size) + cutoff + distance + I(distance^2) + cutoff*close + cutoff*cutoff_switch + log(landv_ac), data = property_current_mod2)
summary(model)

model <- lm(log(perland) ~ log(pu_size) + cutoff + distance + I(distance^2) + cutoff*close, data = property_current_mod)
summary(model)

model <- lm(log(perland) ~ log(pu_size) + cutoff + distance + I(distance^2) + cutoff*close + log(landv_ac), data = property_current_mod)
summary(model)


model <- felm(log(perland) ~ log(pu_size) + cutoff + cutoff*close + distance + I(distance^2)  | zone_id, data = property_current_mod)
summary(model)

property_sale <- property_current_mod2 %>%
  mutate(sale_year = floor(col149/1e4)) %>%
  mutate(sale_year_st = as.character(sale_year)) %>%
  mutate(per_sale_price = col151/col201) %>%
  filter(sale_year >2010 )

model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + cutoff + distance + I(distance^2) + cutoff*close + log(landv_ac) | sale_year_st , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + cutoff + distance + I(distance^2) + cutoff*close + log(landv_ac) | sale_year_st , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + cutoff + distance + I(distance^2) + log(landv_ac) | sale_year_st , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + cutoff + distance + I(distance^2) + log(landv_ac) | sale_year_st + tractID19 , data = property_sale)
summary(model)
model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland)  + distance + I(distance^2) + log(landv_ac)+ cutoff*close | sale_year_st + tractID19 , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size)  + distance + I(distance^2) + log(landv_ac)+ cutoff | sale_year_st + tractID19 , data = property_sale)
summary(model)
model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + distance + I(distance^2) + log(landv_ac)+ cutoff | sale_year_st + tractID19 , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size)  + distance + I(distance^2) + log(landv_ac)+ cutoff | sale_year_st + zone_id , data = property_sale)
summary(model)
model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + distance + I(distance^2) + log(landv_ac)+ cutoff | sale_year_st + zone_id , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + distance + I(distance^2) + log(landv_ac)+ cutoff*close | sale_year_st + zone_id , data = property_sale)
summary(model)
model <- felm(log(per_sale_price) ~ log(pu_size)  + distance + I(distance^2) + log(landv_ac)+ cutoff*close | sale_year_st + zone_id , data = property_sale)
summary(model)

model <- felm(log(per_sale_price) ~ log(pu_size)  + distance + I(distance^2) + log(landv_ac)+ cutoff*close + cutoff_switch | sale_year_st  , data = property_sale)
summary(model)
model <- felm(log(per_sale_price) ~ log(pu_size) + log(perland) + distance + I(distance^2) + log(landv_ac)+ cutoff*close + cutoff*cutoff_switch| sale_year_st , data = property_sale)
summary(model)

