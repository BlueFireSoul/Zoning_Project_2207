library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

aei_land <- read_csv(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/land/aei_land.csv"), skip = 1, col_names = FALSE) %>%
  rename(tractID19 = X3, year = X4, landv_ac = X5, landv_lot = X6, lcost_share = X7) %>%
#  mutate(state = str_sub(tractID19, start = 1, end = 2)) %>%
#  mutate(county = str_sub(tractID19, start = 4, end = 5)) %>%
#  mutate(tract = str_sub(tractID19, start = 6, end = 11)) %>%
#  mutate(tractID19 = paste0(state,county,tract))%>%
  filter(year == 2019) %>%
  mutate(tractID19 = as.numeric(tractID19))

aei_land$lcost_share <- as.numeric(sub("%", "", aei_land$lcost_share))/100

aei_land %<>% mutate(lcost_share0 = ifelse(X9 == "N",lcost_share,NA))%>%
  select(tractID19, landv_ac, landv_lot, lcost_share,lcost_share0)


nonparametric_plot(aei_land,'landv_ac','landv_lot',1,99)
lm_result <- lm(landv_ac ~ landv_lot, data = aei_land)
summary(lm_result)


write_csv(aei_land, output_dir + "aei_land.csv")

property_cdict <- read_csv(property_cdict_xwalk_csv)

if ("landv_ac" %in% colnames(property_cdict)) {
  print("land_value_ac column exists.")
} else {
  property_cdict %<>%
    merge(aei_land, by = 'tractID19', all.x = TRUE)
  write_csv(property_cdict, property_cdict_xwalk_csv)
}
