library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

library(RODBC)
library(sandwich)
library(matrixStats)

# Replace 'survey_path' with the actual path to your MDB file
survey_path <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/ma_local/Mass_HH_Final_Public_Release/Mass_HH_Final_Public_Release.mdb")

channel <- odbcConnectAccess2007(survey_path)
tables <- sqlTables(channel, schema = NULL, tableType = "TABLE")$TABLE_NAME
print(tables)

hh_df <- sqlFetch(channel, "HH")
per_df <- sqlFetch(channel, "PER")

odbcClose(channel)

block_time <- read_csv(output_dir + '/block_survey_time.csv') %>%
  select(-wlat,-wlon,-hlat,-hlon)

counties <- c('9', '17', '21', '23', '25', '27')
hh_df_process <- hh_df %>%
  select(SAMPN, HHVEH, HSTATE10, HCOUNTY10, HTRACT10, HBLOCK10)%>%
  filter(HCOUNTY10 %in% counties)

per_df_process <- per_df %>%
  select(SAMPN, PERNO, WORKS, WMODE, WSTATE10, WCOUNTY10, WTRACT10, PWGT, WBLOCK10) %>%
  filter(WCOUNTY10 %in% counties) %>%
  merge(hh_df_process, by = "SAMPN") %>%
  filter(WMODE %in% c(1,3,4,5,6,7,8,9)) %>%
  mutate(mode = ifelse(WMODE %in% c(3,4,8,9),2,1)) %>%
  mutate(mode = ifelse(WMODE == 1, 0, mode)) %>%
  mutate(vehicle = ifelse(HHVEH == 0,0,1)) %>%
  filter(!(mode == 2 & vehicle==0)) %>%
  select(-WMODE, -HHVEH) %>%
  merge(block_time, by = c('HSTATE10', 'HCOUNTY10', 'HTRACT10', 'HBLOCK10', 'WSTATE10', 'WCOUNTY10', 'WTRACT10', 'WBLOCK10'))%>%
  select(PWGT, mode, vehicle, walking, transit, driving) %>%
  filter(!(mode == 1 & transit <=0)) %>%
  mutate(transit = ifelse(transit <= 0 & driving > 0, 99999,transit)) %>%
  mutate(transit = ifelse(transit < 0, 99999,transit))%>%
#  mutate(transit = ifelse(transit < driving, driving,transit))%>%
#  filter(!(transit==0 & driving==0 & walking==0))%>%
  mutate(driving = ifelse(vehicle==0, 99999, driving))

per_df_0 <- per_df_process %>%
  filter(mode == 0)

per_df_1 <- per_df_process %>%
  filter(mode == 1)

per_df_2 <- per_df_process %>%
  filter(mode == 2)

parameters <- c(0.015, -0.069, 0.261)
weight0 <- as.vector(per_df_0 %>% pull(PWGT)) 
mode0t0 <- as.vector(per_df_0 %>% pull(walking)) 
mode0t1 <- as.vector(per_df_0 %>% pull(transit)) 
mode0t2 <- as.vector(per_df_0 %>% pull(driving)) 

weight1 <- as.vector(per_df_1 %>% pull(PWGT)) 
mode1t0 <- as.vector(per_df_1 %>% pull(walking)) 
mode1t1 <- as.vector(per_df_1 %>% pull(transit)) 
mode1t2 <- as.vector(per_df_1 %>% pull(driving)) 

weight2 <- as.vector(per_df_2 %>% pull(PWGT)) 
mode2t0 <- as.vector(per_df_2 %>% pull(walking)) 
mode2t1 <- as.vector(per_df_2 %>% pull(transit)) 
mode2t2 <- as.vector(per_df_2 %>% pull(driving)) 

likelihood_function <- function(parameters) {
  mode0t0_adj = -parameters[1]* mode0t0
  mode0t1_adj = -parameters[1]* mode0t1 + parameters[2]
  mode0t2_adj = -parameters[1]* mode0t2 + parameters[3]
  sum0 = sum(weight0 * (mode0t0_adj -log(exp(mode0t0_adj)+ exp(mode0t1_adj)+exp(mode0t2_adj))))
  
  mode1t0_adj = -parameters[1]* mode1t0
  mode1t1_adj = -parameters[1]* mode1t1 + parameters[2]
  mode1t2_adj = -parameters[1]* mode1t2 + parameters[3]
  sum1 = sum(weight1 * (mode1t1_adj -log(exp(mode1t1_adj)+exp(mode1t0_adj)+exp(mode1t2_adj))))
  
  mode2t0_adj = -parameters[1]* mode2t0
  mode2t1_adj = -parameters[1]* mode2t1 + parameters[2]
  mode2t2_adj = -parameters[1]* mode2t2 + parameters[3]
  sum2 = sum(weight2 * (mode2t2_adj -log(exp(mode2t2_adj)+exp(mode2t1_adj)+exp(mode2t0_adj))))
  
  return(-sum0-sum1-sum2)
}
initial_guess <- c(0.015, -0.069, 0.261) 
likelihood_function(initial_guess)
result <- optim(par = initial_guess, fn = likelihood_function, method = "Nelder-Mead")

mle_parameters <- result$par

hessian <- numDeriv::hessian(likelihood_function, mle_parameters)
cov_matrix <- solve(hessian) 
standard_errors <- sqrt(diag(cov_matrix))
print(mle_parameters)
print(standard_errors)