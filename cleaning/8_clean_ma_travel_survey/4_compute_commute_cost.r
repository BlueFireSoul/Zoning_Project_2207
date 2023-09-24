library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

kappa <- 0.03449438 
xi_car <- 0.24362778
xi_tran <- 0.05760465 

matrix_df <- read_csv(tract_ma_matrix_csv)

v_walk <- as.vector(matrix_df %>% pull(walking))
v_transit <- as.vector(matrix_df %>% pull(transit))
v_drive <- as.vector(matrix_df %>% pull(driving))

inc_walk <- exp(- kappa* v_walk)
inc_transit <- exp(- kappa* v_transit + xi_tran)
inc_drive <- exp(- kappa* v_drive + xi_car)

base <- inc_walk + inc_transit + inc_drive

average_time <- (inc_walk*v_walk + inc_transit*v_transit + inc_drive*v_drive)/base 

cost <- exp(-kappa*average_time)

matrix_mod <- matrix_df %>%
  mutate(commute_cost = cost) %>%
  select(origin, destination, commute_cost)

write.csv(matrix_mod, file = commute_cost_matrix_csv, row.names = FALSE)