library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(data.table)

define_counties <- function(){
  if (run_code == "ca"){
    sf_counties <- c(06001, 06013, 06041, 06047, 06055, 06069, 06075, 06077, 06081, 06085, 06087, 06095, 06097, 06099)
    los_counties <- c(06037, 06059, 06111, 06071, 06065)
    san_diego <- c(06073)
    counties <- c(sf_counties,los_counties,san_diego)
  } else if (run_code == "tx") {
    dallas_counties <- c(48085, 48113, 48121, 48139, 48231, 48257, 48397, 48251, 48367, 48439, 48497)
    houston_counties <- c(48015, 48039, 48071, 48157, 48167, 48201, 48291, 48339, 48473)
    counties <- c(dallas_counties,houston_counties)
  } else if (run_code == "ny") {
    ny_ny_counties <- c(36047, 36081, 36061, 36005, 36085, 36119, 36079, 36071, 36087, 36059, 36103)
    counties <- ny_ny_counties
  } else if (run_code == "nj") {
    ny_nj_counties <- c(34003, 34017, 34031, 34023, 34025, 34029, 34035, 34013, 34039, 34027, 34037, 34019)
    counties <- ny_nj_counties
  } else if (run_code == "ma") {
    boston_counties <- c(25009, 25017, 25021, 25023, 25025, 25027)
    counties <- boston_counties
  }
  return(counties)
}

file_list <- unzip(mortgage_current, list = TRUE)
txt_file <- file_list$Name[grep(".txt$", file_list$Name)]
mort_data <- fread(unzip(mortgage_current, files = txt_file), select = c(1, 3, 42, 43, 44, 108, 109, 110, 87, 56), skip = 1, header = FALSE, sep = "|")
names(mort_data) <- c('col1', 'col3', 'm_amount', 'm_date43', 'm_date44', 'm_lendc108', 'm_lendn109', 'm_lendn110', 'borrower_corp_d', 'mort_type')
file.remove(txt_file)

counties <- define_counties()

mort_data_mod <- mort_data %>%
  filter(col3 %in% counties) %>%
  mutate(m_lendn = ifelse(!nzchar(m_lendn109),m_lendn110,m_lendn109)) %>%
  mutate(year = floor(m_date44/10000)) %>%
  mutate(m_amount = floor(m_amount/1000)) %>%
  mutate(mort_type = ifelse(mort_type %in% c('P','R'),mort_type,'')) %>%
  filter(year <= 2020, year >= 2007, borrower_corp_d != 'Y') %>%
  select(-m_lendn110, -m_lendn109, -m_date44, -m_date43, -borrower_corp_d) %>%
  mutate(col1 = as.character(col1))

saveRDS(mort_data_mod, file = mortgage_current_rds)

