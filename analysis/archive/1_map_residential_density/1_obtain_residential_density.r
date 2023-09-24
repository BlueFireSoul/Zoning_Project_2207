library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

define_counties <- function() {
  if (run_code == "ca") {
    sf_counties <- c(1, 13, 41, 47, 55, 69, 75, 77, 81, 85, 87, 95, 97, 99)
    los_counties <- c(37, 59, 111, 71, 65)
    san_diego <- c(73)
    counties <- c(sf_counties,los_counties,san_diego)
  } else if (run_code == "tx") {
    dallas_counties <- c(85, 113, 121, 139, 231, 257, 397, 251, 367, 439, 497)
    houston_counties <- c(15, 39, 71, 157, 167, 201, 291, 339, 473)
    counties <- c(dallas_counties, houston_counties)
  } else if (run_code == "ny") {
    ny_ny_counties <- c(47, 81, 61, 5, 85, 119, 79, 71, 87, 59, 103)
    counties <- ny_ny_counties
  } else if (run_code == "nj") {
    ny_nj_counties <- c(3, 17, 31, 23, 25, 29, 35, 13, 39, 27, 37, 19)
    counties <- ny_nj_counties
  } else if (run_code == "ma") {
    boston_counties <- c(21, 23, 25, 9, 17)
    counties <- boston_counties
  }
  return(counties)
}

define_statefp <- function() {
  if (run_code == "ca") {
    return(6)
  } else if (run_code == "tx") {
    return(48)
  } else if (run_code == "ny") {
    return(36)
  } else if (run_code == "nj") {
    return(34)
  } else if (run_code == "ma") {
    return(25)
  }
}
### Obtain residential density
property <- read.csv(property_c_xwalk_csv) %>%
  filter(house_type %in% c('s','lm','sm')) %>%
  group_by(STATEFP, COUNTYFP, TRACTCE) %>%
  summarise(sum_col202 = sum(col202), sum_adj_land = sum(adj_land), GEOID = first(GEOID), ALAND = first(ALAND))

counties <- define_counties()
selected_state <- define_statefp()

tract_pop <- read.csv(tract_pop_2019_csv) %>% 
                rename(pop19 = ALUBE001) %>% 
                select(STATEA, COUNTYA, TRACTA, pop19) %>% 
                rename(STATEFP = STATEA, COUNTYFP = COUNTYA, TRACTCE = TRACTA) %>%
                filter(COUNTYFP%in%counties, STATEFP == selected_state)
              
merged_data <- inner_join(property, tract_pop, by = c("STATEFP", "COUNTYFP", "TRACTCE")) %>%
  mutate(pla_den = pop19/sum_adj_land, 
         pfl_den = pop19/sum_col202, 
         ptla_den = pop19/ALAND,
         aflra = sum_col202/sum_adj_land)

### Merge year 2000 pop
block_xwalk <- read.csv(block_0010_xwalk_csv, colClasses = c("character", "character", "numeric", "numeric")) %>%
  mutate(STATEA00 = as.integer(str_sub(GEOID00, 1, 2)),
         COUNTYA00 = as.integer(str_sub(GEOID00, 3, 5)),
         TRACTA00 = as.integer(str_sub(GEOID00, 6, 11)),
         BLOCKA00 = as.integer(str_sub(GEOID00, 12, 15)),
         STATEA = as.integer(str_sub(GEOID10, 1, 2)),
         COUNTYA = as.integer(str_sub(GEOID10, 3, 5)),
         TRACTA = as.integer(str_sub(GEOID10, 6, 11)),
         BLOCKA = as.integer(str_sub(GEOID10, 12, 15)))

block_pop <- read.csv(block_pop_2000_csv) %>%
  rename(pop00 = FXS001, STATEA00 = STATEA, COUNTYA00 = COUNTYA, TRACTA00 = TRACTA, BLOCKA00 = BLOCKA) %>%
  select(pop00, STATEA00, COUNTYA00, TRACTA00, BLOCKA00)

block_pop <- merge(block_xwalk, block_pop, by = c("STATEA00", "COUNTYA00", "TRACTA00", "BLOCKA00")) %>%
  mutate(pop00 = WEIGHT * pop00) %>%
  group_by(STATEA, COUNTYA, TRACTA) %>%
  summarise(pop00 = sum(pop00))

block_pop %<>%  select(STATEA, COUNTYA, TRACTA, pop00) %>% 
                rename(STATEFP = STATEA, COUNTYFP = COUNTYA, TRACTCE = TRACTA) %>%
                filter(COUNTYFP%in%counties, STATEFP == selected_state)
              
merged_data <- left_join(merged_data, block_pop, by = c("STATEFP", "COUNTYFP", "TRACTCE")) %>%
  mutate(pop00 = ifelse(pop00 == 0, NA, pop00)) %>%
  mutate(cpop0019 = pop19/pop00)

### Compare building before and after 2000
property <- read.csv(property_c_xwalk_csv) %>%
  filter(!is.na(col163)) %>%
  mutate(year_2000_dummy = ifelse(col163>=2000,1,0)) %>%
  group_by(STATEFP, COUNTYFP, TRACTCE, year_2000_dummy) %>%
  summarise(col202 = sum(col202), adj_land = sum(adj_land), GEOID = first(GEOID)) %>%
  pivot_wider(id_cols = GEOID, names_from = year_2000_dummy, values_from = c(col202, adj_land), names_prefix = "built_") %>%
  mutate(fl00share = col202_built_1/(col202_built_1 + col202_built_0),
         la00share = adj_land_built_1/(adj_land_built_1 + adj_land_built_0),
         flra00 = (col202_built_1/adj_land_built_1)/(col202_built_0/adj_land_built_0))

merged_data <- merge(merged_data, property, by = "GEOID", all = TRUE)

write.csv(merged_data, tract_density_2019_csv, row.names = FALSE)
