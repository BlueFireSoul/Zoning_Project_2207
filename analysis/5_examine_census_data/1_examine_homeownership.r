library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
property_coord_dict <- read.csv(property_cdict_xwalk_csv)

tract_id_list <- property_coord_dict %>% distinct(tractID19)

census_folder <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/census/")

puma_list <- read.csv(paste0(census_folder,"2010_tract_to_puma.txt"), colClasses = "character") %>%
  mutate(tractID19 = paste0(STATEFP,COUNTYFP,TRACTCE)) %>%
  select(tractID19, PUMA5CE) %>%
  merge(tract_id_list, by = 'tractID19', how = "inner") %>%
  distinct(PUMA5CE) %>% 
  rename(PUMA = PUMA5CE)
puma_list$PUMA <- as.numeric(puma_list$PUMA)

acs_data <- read.csv(gzfile(paste0(census_folder, 'acs2019_birthplace.csv.gz')))

acs_data %<>% merge(puma_list, by = 'PUMA', how = 'inner')

acs_household_data <- acs_data %>% group_by(SERIAL) %>% summarize(OWNERSHP = first(OWNERSHP), HHWT = first(HHWT), 
                                                                  MOVEDIN = first(MOVEDIN), HHINCOME = first(HHINCOME))

weighted_frequency_table(acs_data$OWNERSHP, acs_data$PERWT)
weighted_frequency_table(acs_household_data$OWNERSHP, acs_household_data$HHWT)

weighted_frequency_table(acs_household_data$MOVEDIN, acs_household_data$HHWT)

nonparametric_plot(acs_household_data,'OWNERSHP','HHINCOME',1,90)

percentile_plot(acs_household_data$HHINCOME,1,99)

household_income_df <- acs_household_data %>%
  filter(HHINCOME != 9999999, OWNERSHP!=0)%>%
  mutate(OWNERSHP= 2-OWNERSHP)

nonparametric_plot(household_income_df,'OWNERSHP','HHINCOME',1,95)
percentile_plot(household_income_df$HHINCOME,1,95)
