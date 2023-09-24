library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

la_csv <- read.csv(file.path(temp_dir, paste0('scag_xwalk/2016_Land_Use_Information_for_Los_Angeles_County.csv')))
o_csv <- read.csv(file.path(temp_dir, paste0('scag_xwalk/2016_Land_Use_Information_for_Orange_County.csv')))
r_csv <- read.csv(file.path(temp_dir, paste0('scag_xwalk/2016_Land_Use_Information_for_Riverside_County.csv')))
sb_csv <- read.csv(file.path(temp_dir, paste0('scag_xwalk/2016_Land_Use_Information_for_San_Bernardino_County.csv')))
v_csv <- read.csv(file.path(temp_dir, paste0('scag_xwalk/2016_Land_Use_Information_for_Ventura_County.csv')))

all_csv <- rbind(la_csv, o_csv, r_csv, sb_csv, v_csv)

frequency_table((all_csv%>%mutate(code=substr(SCAG_GP_CO,1,3)))$code)

all_csv_adj <- all_csv %>% 
    mutate(HIGH = ifelse(HIGH == 0, median(HIGH, na.rm = TRUE), HIGH)) %>%
    filter(substr(SCAG_GP_CO,1,3)!="113") %>%
    filter(substr(SCAG_GP_CO,1,3)!="115") %>%
    mutate(zoning = 'mix') %>%
    mutate(zoning = ifelse(substr(SCAG_GP_CO,1,3) == "111",'sf',zoning)) %>%
    mutate(zoning = ifelse(substr(SCAG_GP_CO,1,3) == "112",'mf',zoning))

frequency_table(all_csv_adj$zoning)

plot_frequency((all_csv_adj%>%filter(zoning=="mix"))$HIGH, upper_perc = 90)
plot_frequency((all_csv_adj%>%filter(zoning=="sf"))$HIGH, upper_perc = 90)
plot_frequency((all_csv_adj%>%filter(zoning=="mf"))$HIGH, upper_perc = 90)

all_csv_sz_area <- all_csv_adj %>% 
    group_by(STATEFP,COUNTYFP,TRACTCE,zoning) %>% 
    summarize(sz_area = sum(intersect_area)) 

all_csv_tract_area <- all_csv_adj %>% 
    group_by(STATEFP,COUNTYFP,TRACTCE) %>% 
    summarize(tres_area = sum(intersect_area))

merged_data <- merge(all_csv_sz_area, all_csv_tract_area, by = c("STATEFP", "COUNTYFP", "TRACTCE")) %>%
  merge(all_csv_adj, by = c("STATEFP", "COUNTYFP", "TRACTCE",'zoning'))

all_csv_agg <- merged_data %>% 
    mutate(aH_lim = (intersect_area/sz_area)*HIGH) %>% 
    group_by(STATEFP,COUNTYFP,TRACTCE,zoning) %>% 
    summarize(H = sum(aH_lim), sz_area = first(sz_area), tres_area = first(tres_area)) %>% 
    mutate(sz_share = sz_area/tres_area)

wide_all_csv_agg <- all_csv_agg %>%
  pivot_wider(names_from = zoning, values_from = c(H, sz_area, tres_area, sz_share)) %>%
  mutate_at(vars(sz_area_sf, sz_area_mf, sz_area_mix, tres_area_sf, tres_area_mf, tres_area_mix, sz_share_sf, sz_share_mf, sz_share_mix), ~ifelse(is.na(.), 0, .))
a <- frequency_table(wide_all_csv_agg$H_mix)
a <- frequency_table(wide_all_csv_agg$H_mf)
a <- frequency_table(wide_all_csv_agg$H_sf)
plot_frequency(wide_all_csv_agg$H_sf, upper_perc = 90)
plot_frequency(wide_all_csv_agg$H_mf, upper_perc = 90)
plot_frequency(wide_all_csv_agg$H_mix, upper_perc = 90)

write.csv(wide_all_csv_agg,scag_zoning_2016_csv, row.names = FALSE)
