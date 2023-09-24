library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(RODBC)

# Replace 'survey_path' with the actual path to your MDB file
survey_path <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/ma_local/Mass_HH_Final_Public_Release/Mass_HH_Final_Public_Release.mdb")

channel <- odbcConnectAccess2007(survey_path)
tables <- sqlTables(channel, schema = NULL, tableType = "TABLE")$TABLE_NAME
print(tables)

hh_df <- sqlFetch(channel, "HH")
per_df <- sqlFetch(channel, "PER")

odbcClose(channel)

tract_ma_df <- read_csv(tract_ma_2019_csv) %>%
  select(COUNTYFP, TRACTCE)

matrix_df <- read_csv(tract_ma_matrix_csv)

counties <- c('9', '17', '21', '23', '25', '27')
hh_df_process <- hh_df %>%
  select(SAMPN, HHVEH, HSTATE10, HCOUNTY10, HTRACT10, HBLOCK10)%>%
  filter(HCOUNTY10 %in% counties)

per_df_process <- per_df %>%
  select(SAMPN, PERNO, WORKS, WMODE, WSTATE10, WCOUNTY10, WTRACT10, PWGT, WBLOCK10) %>%
  filter(WCOUNTY10 %in% counties) %>%
  merge(hh_df_process, by = "SAMPN") %>%
  merge(tract_ma_df, by.x = c('WCOUNTY10','WTRACT10'), by.y = c('COUNTYFP','TRACTCE')) %>%
  merge(tract_ma_df, by.x = c('HCOUNTY10','HTRACT10'), by.y = c('COUNTYFP','TRACTCE'))

block_dict <- per_df_process %>%
  distinct(WSTATE10, WCOUNTY10, WTRACT10, WBLOCK10, HSTATE10, HCOUNTY10, HTRACT10, HBLOCK10)

write.csv(block_dict, file = temp_dir + "block_dict.csv", row.names = FALSE)
