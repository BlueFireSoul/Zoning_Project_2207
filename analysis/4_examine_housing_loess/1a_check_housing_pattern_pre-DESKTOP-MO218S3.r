library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(lfe)

property_current <- readRDS(property_apt_rds)

property_current_mod <- property_current %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201)%>%
  filter(pu_size<5000, pu_size>500)

