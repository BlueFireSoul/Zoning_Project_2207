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
       far_ov = ifelse(property_far>far_adj*1.1,1,0))

percentile_plot(property_modern$dupac_ratio,1,95)

p1 <- ggplot(property_current_mod) + 
  stat_ecdf(aes(x = dupac_ratio60, color = "blue"), linetype = "solid") +
  stat_ecdf(aes(x = dupac_ratio18, color = "red"), linetype = "solid") +
  labs(x = "observed_DUPAC/DUPAC_restriction", y = '') +
  scale_color_manual(values = c("blue" = "blue", "red" = "red"), labels = c("built after 1960", "built before 1918")) +
  theme_minimal() +
  theme(
    legend.position = 'bottom',
    legend.background = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    panel.grid.major = element_line(colour = "#e5e5e5", size = 0.1, linetype = "solid"),
    panel.grid.minor = element_line(colour = "#e5e5e5", size = 0.05, linetype = "solid")
  ) +
  coord_cartesian(xlim = c(0, 4))  
print(p1)
ggsave(paste0(graph_dir, "constraint/dupac_ratio_modern.png"), plot = p1, width = 4, height = 4, dpi = 300)

p2 <- ggplot(property_current_mod) + 
  stat_ecdf(aes(x = far_ratio60, color = "blue"), linetype = "solid") +
  stat_ecdf(aes(x = far_ratio18, color = "red"), linetype = "solid") +
  labs(x = "observed_FAR/FAR_restriction", y = '') +
  scale_color_manual(values = c("blue" = "blue", "red" = "red"), labels = c("built after 1960", "built before 1918")) +
  theme_minimal() +
  theme(
    legend.position = 'bottom',
    legend.background = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    panel.grid.major = element_line(colour = "#e5e5e5", size = 0.1, linetype = "solid"),
    panel.grid.minor = element_line(colour = "#e5e5e5", size = 0.05, linetype = "solid")
  ) +
  coord_cartesian(xlim = c(0, 2))  
print(p2)
ggsave(paste0(graph_dir, "constraint/far_ratio_modern.png"), plot = p2, width = 4, height = 4, dpi = 300)

percentile_plot(property_modern$dupac_ratio,1,80)
percentile_plot(property_modern$far_ratio,1,98)


gam_model <- gam(dupac_ov ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$dupac_ovp <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(dupac_e ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$dupac_ep <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(far_e ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$far_ep <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(far_ov ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$far_ovp <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(far_v ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$far_vp <- predict(gam_model, newdata = property_modern, type = "response")
gam_model <- gam(dupac_v ~ s(distance), data = property_modern, family = binomial(link = "probit"))
property_modern$dupac_vp <- predict(gam_model, newdata = property_modern, type = "response")

p3 <- ggplot(property_modern) +
  geom_smooth(aes(x = distance, y = far_ovp, color = "FAR"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  geom_smooth(aes(x = distance, y = dupac_ovp, color = "DUPAC"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  labs(title = "",
       x = "distance (m)",
       y = "",
       color = "") +
  scale_color_manual(values = c("FAR" = "red", "DUPAC" = "blue")) +
  coord_cartesian(xlim = c(0, 40000))  +
  theme(legend.position = "bottom")
print(p3)
ggsave(paste0(graph_dir, "constraint/zoning_ov.png"), plot = p3, width = 4, height = 4, dpi = 300)


p4 <- ggplot(property_modern) +
  geom_smooth(aes(x = distance, y = far_ep, color = "FAR"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  geom_smooth(aes(x = distance, y = dupac_ep, color = "DUPAC"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  labs(title = "",
       x = "distance (m)",
       y = "",
       color = "") +
  scale_color_manual(values = c("FAR" = "red", "DUPAC" = "blue"))+
  coord_cartesian(xlim = c(0, 40000))  +
  theme(legend.position = "bottom")
print(p4)
ggsave(paste0(graph_dir, "constraint/zoning_e.png"), plot = p4, width = 4, height = 4, dpi = 300)

p5 <- ggplot(property_modern) +
  geom_smooth(aes(x = distance, y = far_vp, color = "FAR"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  geom_smooth(aes(x = distance, y = dupac_vp, color = "DUPAC"), 
              method = "gam", 
              formula = y ~ s(x, bs = "cs"), 
              se = FALSE) +
  labs(title = "",
       x = "distance (m)",
       y = "",
       color = "") +
  scale_color_manual(values = c("FAR" = "red", "DUPAC" = "blue"))+
  coord_cartesian(xlim = c(0, 40000))  +
  theme(legend.position = "bottom")
print(p5)
ggsave(paste0(graph_dir, "constraint/zoning_v.png"), plot = p5, width = 4, height = 4, dpi = 300)


property_modern_tract <- property_current_mod %>%
  filter(col163>=1960)%>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj*0.9,1,0),
         dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj*0.9,1,0),
         dupac_ov = ifelse(property_dupac>dupac_adj*1.1,1,0),
         far_v = ifelse(property_far>far_adj*0.9,1,0),
         far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj*0.9,1,0),
         far_ov = ifelse(property_far>far_adj*1.1,1,0)) %>%
  mutate(year_ov = ifelse(dupac_ov == 1,col163,NA),
        year_er = ifelse(dupac_ov == 0,col163,NA)) %>%
  group_by(tractID19) %>%
  summarise(dupac_v = mean(dupac_v, na.rm = TRUE), dupac_e= mean(dupac_e, na.rm = TRUE), far_v = mean(far_v, na.rm = TRUE), 
            dupac_ov = mean(dupac_ov, na.rm = TRUE), far_e= mean(far_e, na.rm = TRUE), far_ov= mean(far_ov, na.rm = TRUE), distance = mean(distance),
            year_ov = mean(year_ov, na.rm = TRUE), year_er = mean(year_er, na.rm = TRUE), 
            dupac_adj = mean(dupac_adj, na.rm = TRUE), far_adj = mean(far_adj, na.rm = TRUE)) %>%
  mutate(year_diff10 = ifelse(dupac_ov>=0.1 & dupac_ov <= 0.9,year_er-year_ov,NA),
        year_diff20 = ifelse(dupac_ov>=0.2 & dupac_ov <= 0.9,year_er-year_ov,NA),
        year_diff = year_er-year_ov) %>%
  mutate(year_diff10 = ifelse(is.na(year_diff10),999,year_diff10),
         year_diff20 = ifelse(is.na(year_diff20),999,year_diff20),
         year_diff = ifelse(is.na(year_diff),999,year_diff),
         dupac_v = ifelse(is.na(dupac_adj),999,dupac_v),
         dupac_e = ifelse(is.na(dupac_adj),999,dupac_e),
         dupac_ov = ifelse(is.na(dupac_adj),999,dupac_ov),
         far_v = ifelse(is.na(far_adj),999,far_v),
         far_e = ifelse(is.na(far_adj),999,far_e),
         far_ov = ifelse(is.na(far_adj),999,far_ov))

write.csv(property_modern_tract, file = paste0(output_dir,'tract_zoning_summary.csv'), row.names = FALSE)

percentile_plot(property_modern_tract$year_diff10,1,99)
percentile_plot(property_modern_tract$year_diff20,1,99)

nonparametric_plot(property_modern_tract,'year_diff10','distance',1,99 )
nonparametric_plot(property_modern_tract,'year_diff20','distance',1,99 )

property_dom_tract <- property_current_mod %>%
  filter(col163>=1960)%>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj,1,0),
         dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj,1,0),
         far_v = ifelse(property_far>far_adj,1,0),
         far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj,1,0)) %>%
  filter(dupac_v+far_v==1)%>%
  group_by(tractID19) %>%
  summarise(dupac_v = mean(dupac_v), dupac_e= mean(dupac_e), far_v = mean(far_v), far_e= mean(far_e), distance = mean(distance))


nonparametric_plot(property_dom_tract,'dupac_v','distance',1,95)
nonparametric_plot(property_dom_tract,'far_v','distance',1,95)

percentile_plot(property_current_mod$distance,1,95)

plot(property_dom_tract$distance, property_dom_tract$dupac_v,
     main = "Scatter Plot Example",
     xlab = "X-axis Label",
     ylab = "Y-axis Label",
     col = "blue",
     pch = 19)

property_2_tract <- property_current_mod %>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj,1,0),
         dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj,1,0),
         far_v = ifelse(property_far>far_adj,1,0),
         far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj,1,0)) %>%
  mutate(both_v = ifelse(dupac_v+far_v==2,1,0))%>%
  mutate(one_v = ifelse(dupac_v+far_v==1,1,0))%>%
  mutate(any_v = ifelse(dupac_v+far_v>=1,1,0))%>%
  group_by(tractID19) %>%
  summarise(both_v = mean(both_v), any_v = mean(any_v), one_v = mean(one_v), distance = mean(distance))

nonparametric_plot(property_2_tract,'both_v','distance',1,95)
nonparametric_plot(property_2_tract,'one_v','distance',1,95)
nonparametric_plot(property_2_tract,'any_v','distance',1,95)

property_dom2_tract <- property_current_mod %>%
  mutate(dupac_v = ifelse(property_dupac>dupac_adj,1,0),
         dupac_e = ifelse(property_dupac<dupac_adj*1.1 & property_dupac>dupac_adj,1,0),
         far_v = ifelse(property_far>far_adj,1,0),
         far_e = ifelse(property_far<far_adj*1.1 & property_far>far_adj,1,0)) %>%
  filter(dupac_v+far_v>=1)%>%
  mutate(dupac_v2 = ifelse(far_v==1,0,dupac_v), far_v2 = ifelse(dupac_v==1,0,far_v))%>%
  group_by(tractID19) %>%
  summarise(dupac_v = mean(dupac_v2), far_v = mean(far_v2), distance = mean(distance))


nonparametric_plot(property_dom2_tract,'dupac_v','distance',1,95)
nonparametric_plot(property_dom2_tract,'far_v','distance',1,95)
