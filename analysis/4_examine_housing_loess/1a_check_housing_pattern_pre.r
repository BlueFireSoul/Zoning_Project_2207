library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(lfe)

property_current <- readRDS(property_apt_rds)

property_current_mod <- property_current %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, pu_land = adj_land/col201, far =col202_sum/adj_land )%>%
  filter(pu_size<5000, pu_size>500)

property_current_mod2 <- property_current %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, pu_land = adj_land/col201, far =col202_sum/adj_land )%>%
  filter(pu_size>500)
property_current_mod3 <- property_current %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201, pu_land = adj_land/col201, far =col202_sum/adj_land )

nonparametric_plot(property_current_mod,'far','pu_size',5,95)
nonparametric_plot(property_current_mod2,'far','pu_size',5,95)
nonparametric_plot(property_current_mod3,'far','pu_size',5,95)

nonparametric_plot(property_current_mod,'pu_land','pu_size',5,95)
