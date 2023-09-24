library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(data.table)

define_counties <- function(){
  if (run_code %in%  c("ca",'cas') ){
    sf_counties <- c(06001, 06013, 06041, 06047, 06055, 06069, 06075, 06077, 06081, 06085, 06087, 06095, 06097, 06099)
    los_counties <- c(06037, 06059, 06111, 06071, 06065)
    san_diego <- c(06073)
    #counties <- c(sf_counties,los_counties,san_diego)
    counties <- los_counties
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

process_procedure <- function(prop_data) {
  counties <- define_counties()

  prop_data <- prop_data %>%
    filter(col3 %in% counties) %>%
    filter(
       !is.na(col48) & !is.na(col49)
     )
  
  # Convert data types
  prop_data$col41 <- as.integer(prop_data$col41)
  prop_data$col201 <- as.integer(prop_data$col201)
  prop_data$col161 <- as.numeric(prop_data$col161)
  prop_data$col202 <- as.numeric(prop_data$col202)

  # Add new columns
  s <- c(163)
  sm <- c(100, 102, 148, 115, 151, 165, 132)
  lm <- c(111, 112, 117, 106, 133)
  prop_data <- prop_data %>%
    filter(col34 %in% c(s,sm,lm)) %>%
    mutate(house_type = case_when(col34 %in% s ~ "s",
                                  col34 %in% sm ~ "sm",
                                  col34 %in% lm ~ "lm",
                                  TRUE ~ NA_character_),
          col202 = ifelse(col202 < 100, NA, col202),
          col161 = ifelse(col161 < 100, NA, col161),
          f_ratio = col202/col161)
  return(prop_data)
}

# Load data
file_list <- unzip(property_current, list = TRUE)
txt_file <- file_list$Name[grep(".txt$", file_list$Name)]
prop_data <- fread(unzip(property_current, files = txt_file), select = c(1, 3, 34, 41, 48, 49, 95, 161, 163, 201, 202, 142, 144, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 165, 149, 151, 199), skip = 1, header = FALSE, sep = "|")
names(prop_data) <- paste0("col", c(1, 3, 34, 41, 48, 49, 95, 161, 163, 201, 202, 142, 144, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 165, 149, 151, 199))
file.remove(txt_file)
if (run_code == 'cas'){
  set.seed(81)
  prop_data %<>% sample_frac(0.05)
}


prop_data %<>% mutate(col1 = as.character(col1)) %>%
  process_procedure()
  

# Export data
saveRDS(prop_data, file = property_current_rds)

coord_dict <- prop_data %>% select(col1, col48, col49, col161, col163, col201) %>% mutate(core_dupac = 43560/col161)
coord_dict[] <- lapply(coord_dict, as.character)
write.csv(coord_dict, property_coord_dict_csv, quote = TRUE, row.names = FALSE)

