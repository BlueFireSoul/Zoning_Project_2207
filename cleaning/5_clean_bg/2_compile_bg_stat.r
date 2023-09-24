library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

property_xwalk_bg <- read.csv(output_dir + 'property_xwalk_bg.csv', header = TRUE, sep = ",")

property <- readRDS(property_c_fadj_rds) 

property$col1 <- as.character(property$col1)
property_xwalk_bg$col1 <- as.character(property_xwalk_bg$col1)
merged_data <- merge(property, property_xwalk_bg, by = "col1")

summary <- merged_data %>%
  group_by(STATEFP, COUNTYFP, TRACTCE,BLKGRPCE)  %>%
  summarize(total_land = sum(adj_land))

write.csv(summary, file = output_dir + "bg_total_land.csv", row.names = FALSE)
