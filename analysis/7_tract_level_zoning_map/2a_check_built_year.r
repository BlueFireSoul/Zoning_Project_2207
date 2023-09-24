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

coordinates <- st_as_sf(property_current, coords = c("col49", "col48"), crs = 4326)
specific_point <- st_point(c(-71.05804050694815,42.36038876047336))
specific_point <- st_sfc(specific_point, crs = 4326)
specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)
property_current$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current$distance <- as.numeric(property_current$distance)

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  mutate(property_dupac = col201/adj_land*43560, pu_size = col202_sum/col201, perland = adj_land/col201, property_far = col202_sum/adj_land)%>%
  filter(pu_size<5000, pu_size>500, zo_usety==1)%>%
  mutate(close = ifelse(distance<20000,1,0))%>%
  mutate(dupac_ratio = property_dupac/dupac_adj) %>%
  mutate(far_ratio = property_far/far_adj) %>%
  mutate(dupac_ratio18 = ifelse(col163< 1918, dupac_ratio, NA))%>%
  mutate(dupac_ratio60 = ifelse(col163>= 1960, dupac_ratio, NA))%>%
  mutate(far_ratio18 = ifelse(col163< 1918, far_ratio, NA))%>%
  mutate(far_ratio60 = ifelse(col163>= 1960, far_ratio, NA))

percentile_plot(property_current_mod$dupac_ratio,1,80)
percentile_plot(property_current_mod$far_ratio,1,99)

property_modern <- property_current_mod %>%
  filter(col163>=1960)%>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj*0.9,1,0),
       dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj*0.9,1,0),
       dupac_ov = ifelse(property_dupac>dupac_adj*1.1,1,0),
       far_v = ifelse(property_far>far_adj*0.9,1,0),
       far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj*0.9,1,0),
       far_ov = ifelse(property_far>far_adj*1.1,1,0))%>%
  mutate(year_ov = ifelse(dupac_ov==1,col163,NA),
         year_er = ifelse(dupac_ov==0,col163,NA))

percentile_plot(property_modern$dupac_ratio,1,95)


percentile_plot(property_modern$dupac_ratio,1,80)
percentile_plot(property_modern$far_ratio,1,98)


gam_model <- gam(year_ov ~ s(distance), data = property_modern)
property_modern$year_ovp <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(year_er ~ s(distance), data = property_modern)
property_modern$year_erp <- predict(gam_model, newdata = property_modern, type = "response")


p3 <- ggplot(property_modern) +
  geom_smooth(aes(x = distance, y = year_ov, color = "Exceed DUPAC"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  geom_smooth(aes(x = distance, y = year_er, color = "Comply to DUPAC"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  labs(title = "",
       x = "distance (m)",
       y = "built year",
       color = "") +
  scale_color_manual(values = c("Exceed DUPAC" = "red", "Comply to DUPAC" = "blue")) +
  coord_cartesian(xlim = c(0, 40000))  +
  theme(legend.position = "bottom")
print(p3)
ggsave(paste0(graph_dir, "constraint/zoning_built_year.png"), plot = p3, width = 4, height = 4, dpi = 300)

