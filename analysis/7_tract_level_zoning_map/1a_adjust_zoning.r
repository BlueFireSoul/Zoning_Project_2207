library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(mgcv)
library(lfe)
library(sf)
library(ggplot2)
library(readxl)

property_current <- readRDS(property_apt_rds)
zoning_atlas <- read_excel(paste0(data_dir,'MAPC/zoning_atlas.xlsx')) %>%
  mutate_all(~ ifelse(. == "NA", NA, .)) %>%
  mutate_all(~ ifelse(. == 0, NA, .)) %>%
  mutate_all(~ ifelse(. == "0", NA, .)) %>%
  select(zo_code, zo_usety, minlotsize, mnls_eff, pctlotcov, 
         plc_eff, far, far_calc, dupac, dupac_calc1, dupac_calc3, maxflrs, mxfl_calc, maxdu, mxdu_eff, lapdu)

column_names <- c('zo_usety', 'minlotsize', 'mnls_eff', 'pctlotcov', 'plc_eff', 'far', 
                  'far_calc', 'dupac', 'dupac_calc1', 'dupac_calc3', 'maxflrs', 'mxfl_calc', 'maxdu', 'mxdu_eff','lapdu')
for (col in column_names) {
  zoning_atlas[[col]] <- as.numeric(zoning_atlas[[col]])
}

property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1))) %>%
  merge(zoning_atlas, by = 'zo_code', how = 'inner')

property_plc <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  filter(is.na(far))%>%
  mutate(plc = col202_sum/col199/adj_land)

percentile_95 <- quantile(property_plc$plc, 0.95,na.rm = TRUE)

property_coord_dict <- property_coord_dict %>%
  mutate(far_adj = far,
         dupac_adj = dupac,
         dupac2_adj = dupac) %>%
  mutate(far_adj = ifelse(is.na(far_adj),plc_eff*maxflrs,pmin(far_adj, plc_eff*maxflrs, na.rm = TRUE)),
         dupac_adj = ifelse(is.na(dupac_adj),dupac_calc1,dupac_adj),
         dupac2_adj = ifelse(is.na(dupac2_adj),43560/minlotsize*maxdu,dupac2_adj)) %>%
  mutate(far_adj = ifelse(is.na(far_adj),plc_eff*mxfl_calc,pmin(far_adj, plc_eff*mxfl_calc, na.rm = TRUE)),
         dupac_adj = ifelse(is.na(dupac_adj),dupac_calc3,dupac_adj),
         dupac2_adj = ifelse(is.na(dupac2_adj),43560/minlotsize*mxdu_eff,dupac2_adj)) %>%
  mutate(far_adj = ifelse(is.na(far_adj),percentile_95*maxflrs,pmin(far_adj, percentile_95 * maxflrs, na.rm = TRUE)),
         dupac2_adj = ifelse(is.na(dupac2_adj),43560/mnls_eff*mxdu_eff,dupac2_adj)) %>%
  mutate(far_adj = ifelse(is.na(far_adj),percentile_95*mxfl_calc,pmin(far_adj, percentile_95 * mxfl_calc, na.rm = TRUE))) 

property_check <- property_coord_dict %>%
  mutate(dupacm = 43560/lapdu) %>%
  mutate(ratio = dupacm/dupac2_adj)

percentile_plot(property_check$ratio,1,60)

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
  mutate(dupac_ratio2 = property_dupac/dupac2_adj) %>%
  mutate(dupac_ratio = property_dupac/dupac_adj) %>%
  mutate(far_ratio = property_far/far_adj) %>%
  mutate(lot_ratio = adj_land/minlotsize) %>%
  mutate(dupac_m = 43560/lapdu)%>%
  mutate(dupacm_ratio = property_dupac/dupac_m)

property_modern <- property_current_mod %>%
  filter(col163>=1960)

percentile_plot(property_modern$lapdu,1,99)
percentile_plot(property_modern$minlotsize,1,99)

percentile_plot(property_modern$lot_ratio,1,80)

percentile_plot(property_modern$dupacm_ratio,1,80)

percentile_plot(property_modern$dupac_ratio,1,80)
percentile_plot(property_modern$dupac_ratio2,1,80)
percentile_plot(property_modern$dupac_ratio3,1,100)

frequency_table(property_current_mod$dupac_m)
frequency_table(property_coord_dict$dupac2)
frequency_table(property_coord_dict$dupac_adj)
frequency_table(property_coord_dict$dupac2_adj)

ggplot(property_current_mod) + 
  stat_ecdf(aes(x = dupac_adj, color = "blue"), linetype = "solid") +
  stat_ecdf(aes(x = dupac2_adj, color = "red"), linetype = "dashed") +
  labs(x = "DUPAC", y = '') +
  scale_x_continuous(limits = c(0, 40)) +
  scale_color_manual(values = c("blue" = "blue", "red" = "red"), labels = c("Specified DUPAC", "Inferred DUPAC")) +
  theme_minimal() +
  theme(
    legend.position = 'bottom',  # Adjust these values to position the legend as needed
    legend.background = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    panel.grid.major = element_line(colour = "#e5e5e5", size = 0.1, linetype = "solid"),
    panel.grid.minor = element_line(colour = "#e5e5e5", size = 0.05, linetype = "solid")
  )

