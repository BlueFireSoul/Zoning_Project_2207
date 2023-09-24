library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(data.table)

boston_counties <- c(9, 17, 21, 23, 25, 27)

column_names <- c('year','respondent_id', 'hm_loan_purpose', 'hm_owner_occupancy', 'hm_loan_amount', 'state_code', 'county_code','census_tract_number',
                  'ethnicity', 'hm_race', 'hm_sex', 'hm_income')

hmda_data_p1 <- data.frame(matrix(nrow = 0, ncol = length(column_names)))
colnames(hmda_data_p1) <- column_names

for (year in 2007:2017){
  hmda_path <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/HMDA/hmda_{year}.zip")
  file_list <- unzip(hmda_path, list = TRUE)
  txt_file <- file_list$Name[grep(".csv$", file_list$Name)]
  new_hmda_data <- fread(unzip(hmda_path, files = txt_file), select = c(1, 2, 11, 13, 14, 23, 25, 26, 28, 32, 52, 55), header = TRUE)
  names(new_hmda_data) <- c('year','respondent_id', 'hm_loan_purpose', 'hm_owner_occupancy', 'hm_loan_amount', 'state_code', 'county_code','census_tract_number',
                        'ethnicity', 'hm_race', 'hm_sex', 'hm_income')
  new_hmda_data %<>% filter(state_code == 25, county_code %in% boston_counties) %>% 
    mutate(census_tract_number = as.integer(census_tract_number*100)) %>%
    mutate(hm_sex = ifelse(hm_sex %in% c(1,2),hm_sex -1,NA)) %>%
    mutate(ethnicity = ifelse(ethnicity %in% c(1,2),-(ethnicity -2),NA)) %>%
    mutate(dm_asian = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_asian = ifelse(hm_race %in% c(2),1,dm_asian)) %>%
    mutate(dm_white = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_white = ifelse(hm_race %in% c(5),1,dm_white))%>%
    mutate(dm_african = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_african = ifelse(hm_race %in% c(3),1,dm_african)) %>%
    mutate(hm_owner_occupancy = ifelse(hm_owner_occupancy %in% c(1),1,0)) %>%
    mutate(hm_purpose_code = ifelse(hm_loan_purpose == 1,'P',NA))%>%
    mutate(hm_purpose_code = ifelse(hm_loan_purpose %in% c(3),'R',hm_purpose_code))%>%
    select(-hm_loan_purpose, -hm_race)%>%
    mutate(tractID = as.character(census_tract_number + county_code*1e6 + state_code*1e9))
  
  file.remove(txt_file)
  hmda_data_p1 <- rbind(hmda_data_p1, new_hmda_data)
}

column_names <- c('year','respondent_id', 'county_code2','census_tract_number2','hm_action','hm_loan_purpose', 'hm_loan_amount', 'hm_owner_occupancy','hm_income',
                  'ethnicity', 'hm_race', 'hm_sex')

hmda_data_p2 <- data.frame(matrix(nrow = 0, ncol = length(column_names)))
colnames(hmda_data_p2) <- column_names

for (year in 2018:2020){
  hmda_path <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/HMDA/hmda_{year}.zip")
  file_list <- unzip(hmda_path, list = TRUE)
  txt_file <- file_list$Name[grep(".csv$", file_list$Name)]
  new_hmda_data <- fread(unzip(hmda_path, files = txt_file), select = c(1, 2, 5, 6, 13, 17, 22, 41, 46, 50, 62, 74), header = TRUE)
  names(new_hmda_data) <- c('year','respondent_id', 'county_code2','tractID','hm_action','hm_loan_purpose', 'hm_loan_amount', 'hm_owner_occupancy','hm_income',
                            'ethnicity', 'hm_race', 'hm_sex')
  new_hmda_data %<>% mutate(state_code = floor(county_code2/1000)) %>%
    mutate(county_code = county_code2- state_code *1000, hm_loan_amount = floor(hm_loan_amount/1000)) %>% filter(county_code %in% boston_counties) %>% 
    mutate(census_tract_number = (tractID/1e6 - floor(tractID/1e6))*1e6) %>%
    mutate(tractID = as.character(tractID)) %>%
    filter(hm_action == 1) %>%
    mutate(hm_sex = ifelse(hm_sex %in% c(1,2),hm_sex - 1,NA))%>%
    mutate(ethnicity = ifelse(ethnicity %in% c(1,11,12,13,14,2),0,NA)) %>%
    mutate(ethnicity = ifelse(ethnicity %in% c(1,11,12,13,14),1,ethnicity)) %>%
    mutate(dm_asian = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_asian = ifelse(hm_race %in% c(2,21,22,23,24,25,26,27),1,dm_asian)) %>%
    mutate(dm_white = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_white = ifelse(hm_race %in% c(5),1,dm_white))%>%
    mutate(dm_african = ifelse(hm_race %in% c(6),NA,0)) %>%
    mutate(dm_african = ifelse(hm_race %in% c(3),1,dm_african)) %>%
    mutate(hm_owner_occupancy = ifelse(hm_owner_occupancy %in% c(2,3),0,1))%>%
    mutate(hm_purpose_code = ifelse(hm_loan_purpose == 1,'P',NA))%>%
    mutate(hm_purpose_code = ifelse(hm_loan_purpose %in% c(31,32),'R',hm_purpose_code))%>%
    select(-hm_action, -county_code2, -hm_loan_purpose, -hm_race)
  
  file.remove(txt_file)
  hmda_data_p2 <- rbind(hmda_data_p2, new_hmda_data)
}

hmda_data <- rbind(hmda_data_p1, hmda_data_p2)
saveRDS(hmda_data, file = hmda_data_rds)