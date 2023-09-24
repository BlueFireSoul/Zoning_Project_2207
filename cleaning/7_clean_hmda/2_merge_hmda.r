library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(data.table)

hmda_data <- readRDS(hmda_data_rds)

property_cdict <- read.csv(property_cdict_xwalk_csv) %>%
  select(col1, tractID20, tractID19, tractID08) %>%
  mutate(col1 = as.character(col1), tractID20 = as.character(tractID20), tractID19 = as.character(tractID19), tractID08 = as.character(tractID08) )

mortgage_data <- readRDS(mortgage_current_rds) %>%
  merge(property_cdict, by = 'col1')

print(nrow(mortgage_data %>% distinct(col1)))

mortgage_data_process <- mortgage_data %>%
  mutate(tractID = ifelse(year>=2010,paste0("19" ,tractID19), paste0("08",tractID08))) %>%
  mutate(tractID = ifelse(year==2020,paste0("20" ,tractID20), tractID)) %>%
  select(-tractID19,-tractID20,-tractID08)%>%
  mutate(mID = 1:n())%>%
  filter(year != 2020)

hmda_data_process <- hmda_data %>%
  mutate(tractID = ifelse(year>=2010,paste0("19" ,tractID), paste0("08",tractID))) %>%
  mutate(tractID = ifelse(year==2020,paste0("20" ,tractID), tractID)) %>%
  filter(hm_owner_occupancy == 1)%>%
  rename(m_amount = hm_loan_amount)%>%
  mutate(hID = 1:n())%>%
  select(-hm_owner_occupancy)%>%
  filter(year != 2020)

print(nrow(mortgage_data_process %>% distinct(col1)))

### First Match. Base on year, tractID, m_amount

hmda1 <- hmda_data_process %>%
  group_by(year, tractID, m_amount) %>%
  dplyr::summarize(hID = first(hID), respondent_id = first(respondent_id), N = n()) %>%
  filter(N == 1) %>%
  select(-N) %>%
  ungroup()

mortgage1 <- mortgage_data_process %>%
  group_by(year, tractID, m_amount) %>%
  dplyr::summarize(mID = first(mID),m_lendn=first(m_lendn),m_lendc108=first(m_lendc108), N = n()) %>%
  filter(N==1) %>%
  select(-N) %>%
  ungroup()

merge1 <- merge(hmda1, mortgage1, by = c("year", "tractID", "m_amount"), all = FALSE)
match_dict1 <- merge1 %>% select(hID, mID) 

respondent_dict0 <- merge1 %>% group_by(respondent_id, m_lendn) %>% 
  dplyr::summarize(resp_N = n()) %>%
  ungroup() %>% 
  filter(m_lendn != '* OTHER INSTITUTIONAL LENDERS', m_lendn != '') 

weighted.mode <- function(x, w) {
  unique_x <- unique(x)
  unique_weights <- tapply(w, x, sum)
  unique_x[which.max(unique_weights)]
}

respondent_dict1 <- respondent_dict0 %>%
  group_by(respondent_id) %>%
  dplyr::summarize(m_lendn = as.character(weighted.mode(m_lendn, resp_N)))

respondent_dict2 <- respondent_dict0 %>%
  group_by(m_lendn) %>%
  dplyr::summarize(respondent_id = as.character(weighted.mode(respondent_id, resp_N)))

### Second Match. Base on year, tractID, m_amount, and respondent_id

hmda2 <- hmda_data_process %>%
  anti_join(match_dict1, by = "hID") %>%
  group_by(year, tractID, m_amount, respondent_id) %>%
  dplyr::summarize(hID = first(hID), N = n()) %>%
  filter(N==1) %>%
  select(-N) %>%
  ungroup()

mortgage2 <- mortgage_data_process %>%
  anti_join(match_dict1, by = "mID") %>%
  group_by(year, tractID, m_amount, m_lendn) %>%
  dplyr::summarize(mID = first(mID), N = n()) %>%
  filter(N==1) %>%
  select(-N) %>%
  ungroup()

hmda2a <- merge(hmda2, respondent_dict1, by = 'respondent_id')
merge2 <- merge(hmda2a, mortgage2, by = c("year", "tractID", "m_amount","m_lendn"), all = FALSE) %>% select(hID, mID) 
match_dict2 <- rbind(match_dict1,merge2)

mortgage2b <- merge(mortgage2, respondent_dict2, by = 'm_lendn')
merge2b <- merge(mortgage2b, hmda2, by = c("year", "tractID", "m_amount","respondent_id"), all = FALSE) %>% select(hID, mID) 
match_dict2 <- rbind(match_dict2,merge2b)%>% distinct(hID, mID) %>%
  group_by(hID) %>%
  dplyr::summarize(mID = first(mID), N=n()) %>%
  filter(N==1)%>%
  select(-N) %>%
  ungroup()

### Third Match. Base on year, tractID, m_amount, and respondent_id N-to-N matching

hmda3 <- hmda_data_process %>%
  anti_join(match_dict2, by = "hID")%>%
  group_by(year, tractID, m_amount, respondent_id) %>%
  dplyr::summarize(hID = first(hID), N = n()) %>%
  filter(N==1) %>%
  select(-N) %>%
  ungroup()

mortgage3 <- mortgage_data_process %>%
  anti_join(match_dict2, by = "mID")%>%
  group_by(year, tractID, m_amount, m_lendn) %>%
  dplyr::summarize(mID = first(mID), N = n()) %>%
  filter(N==1) %>%
  select(-N) %>%
  ungroup()

#mortgage_data_check <- mortgage_data_process %>%
#  merge(match_dict, by = 'mID') %>%
#  distinct(col1)


respondent_dict0a <- respondent_dict0

respondent_dict0b <- respondent_dict0a %>% 
  group_by(respondent_id) %>%
  dplyr::summarize(m_lendn = first(m_lendn))%>%
  ungroup()

N <- respondent_dict0a %>% 
  group_by(respondent_id) %>% dplyr::summarize(N = n()) %>% ungroup() %>% dplyr::summarize(N = max(N)) %>% pull(N)
  
hmda3a <- merge(hmda3, respondent_dict0b, by = 'respondent_id')
merge3 <- merge(mortgage3, hmda3a, by = c("year", "tractID", "m_amount","m_lendn"), all = FALSE) %>% select(hID, mID) 
match_dict3 <- rbind(match_dict2,merge3)

for (i in 1: N-1){
  print(i)
  respondent_dict0a <- anti_join(respondent_dict0a,respondent_dict0b,by = c('respondent_id','m_lendn'))
  
  respondent_dict0b <- respondent_dict0a %>% 
    group_by(respondent_id) %>%
    dplyr::summarize(m_lendn = first(m_lendn))%>%
    ungroup()
  print(nrow(respondent_dict0b))
  hmda3a <- merge(hmda3, respondent_dict0b, by = 'respondent_id')
  merge3 <- merge(mortgage3, hmda3a, by = c("year", "tractID", "m_amount","m_lendn"), all = FALSE) %>% select(hID, mID) 
  match_dict3 <- rbind(match_dict3,merge3)
}

match_dict3 <- match_dict3 %>% 
  distinct(hID, mID) %>%
  group_by(hID) %>%
  dplyr::summarize(mID = first(mID), N=n()) %>%
  filter(N==1)%>%
  select(-N) %>%
  ungroup()

deflator_df <- read_csv(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/FRED/CUURA103SA0.csv")) %>%
  rename(deflator = CUURA103SA0) %>%
  mutate(deflator = deflator/266.9210)

data1 = mortgage_data_process %>%
  merge(match_dict1, by = 'mID') %>%
  merge(hmda_data_process, by = c('hID',"year", "tractID", "m_amount")) %>%
  merge(deflator_df, by = 'year') %>%
  rename(m_year = year) %>%
  mutate(m_amount = m_amount/deflator, hm_income = hm_income/deflator) %>%
  select(col1, m_year, m_amount, ethnicity, hm_sex, hm_income, dm_asian, dm_white, dm_african, hm_purpose_code)

data2 = mortgage_data_process %>%
  merge(match_dict2, by = 'mID') %>%
  merge(hmda_data_process, by = c('hID',"year", "tractID", "m_amount")) %>%
  merge(deflator_df, by = 'year') %>%
  rename(m_year = year) %>%
  mutate(m_amount = m_amount/deflator, hm_income = hm_income/deflator) %>%
  select(col1, m_year, m_amount, ethnicity, hm_sex, hm_income, dm_asian, dm_white, dm_african, hm_purpose_code)

data3 = mortgage_data_process %>%
  merge(match_dict3, by = 'mID') %>%
  merge(hmda_data_process, by = c('hID',"year", "tractID", "m_amount")) %>%
  merge(deflator_df, by = 'year') %>%
  rename(m_year = year) %>%
  mutate(m_amount = m_amount/deflator, hm_income = hm_income/deflator) %>%
  select(col1, m_year, m_amount, ethnicity, hm_sex, hm_income, dm_asian, dm_white, dm_african, hm_purpose_code)

saveRDS(data1, file = mortgage_merge1_rds)
saveRDS(data2, file = mortgage_merge2_rds)
saveRDS(data3, file = mortgage_merge3_rds)

print(nrow(mortgage_data_process %>% merge(match_dict3, by = 'mID')))
print(nrow(mortgage_data_process %>% merge(match_dict3, by = 'mID')))

frequency_table(data1$m_year)
frequency_table(data2$m_year)
      