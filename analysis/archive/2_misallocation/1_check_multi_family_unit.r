library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)

data <- read.csv(gzfile(acs2019_csv_gz))
la_data = data %>% 
    filter(STATEFIP == 6)%>% 
    filter(COUNTYFIP %in% c(37, 59, 111, 71, 65))

la_center_data = la_data %>% filter(COUNTYFIP == 37)
frequency_table(la_data$HHWT)
frequency_table(la_data$NFAMS)
frequency_table(la_data$UNITSSTR)
frequency_table((la_data %>% filter(UNITSSTR == 3))$NFAMS)
frequency_table(la_center_data$NFAMS)
frequency_table(la_center_data$UNITSSTR)
frequency_table((la_center_data %>% filter(UNITSSTR == 3))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 4))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 5))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 6))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 7))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 8))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 9))$NFAMS)
frequency_table((la_center_data %>% filter(UNITSSTR == 10))$NFAMS)

weighted_frequency_table(la_data$NFAMS,la_data$HHWT)
weighted_frequency_table(la_data$UNITSSTR,la_data$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 3))$NFAMS,(la_data %>% filter(UNITSSTR == 3))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 4))$NFAMS,(la_data %>% filter(UNITSSTR == 4))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 5))$NFAMS,(la_data %>% filter(UNITSSTR == 5))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 6))$NFAMS,(la_data %>% filter(UNITSSTR == 6))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 7))$NFAMS,(la_data %>% filter(UNITSSTR == 7))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 8))$NFAMS,(la_data %>% filter(UNITSSTR == 8))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 9))$NFAMS,(la_data %>% filter(UNITSSTR == 9))$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 10))$NFAMS,(la_data %>% filter(UNITSSTR == 10))$HHWT)

weighted_frequency_table(la_data$NUMPREC,la_data$HHWT)
weighted_frequency_table((la_data %>% filter(UNITSSTR == 3))$NUMPREC,(la_data %>% filter(UNITSSTR == 3))$HHWT)
