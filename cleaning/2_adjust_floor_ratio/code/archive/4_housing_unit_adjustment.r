library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(reshape2)

property_current <- readRDS(property_current_rds)
frequency_table(property_current$col201)
frequency_table(property_current$col165)
property_current_ns <-  property_current%>% 
  mutate(col201 = ifelse(house_type=='s' & is.na(col201),1,col201))

property_current_ns <- property_current %>% filter(house_type!="s")

frequency_table((property_current%>%filter(house_type=='s'))$col201)
frequency_table((property_current%>%filter(is.na(col201)))$col165)
frequency_table(property_current$house_type)
frequency_table(property_current_ns$col165)
frequency_table(property_current_ns$col201)
frequency_table(property_current_ns$house_type)

model <- lm(col202/col161 ~ col165, data = property_current)
summary(model)

# property_current %<>%
#   filter(
#     !is.na(col34) & !is.na(col48) &
#       !is.na(col49) & !is.na(col161) & !is.na(col202)
#   ) %>%
#   mutate(temp_id = row_number()) 

# property_current_remove <- property_current %>%
#   group_by(col34, col48, col49, col161) %>%
#   mutate(group_count = n()) %>%
#   filter(group_count > 2) %>%
#   mutate(q50 = quantile(col202, 0.50, na.rm = TRUE),
#          outliner = ifelse(col202 > q50*5,"c1","c0")) %>%
#   filter(any(outliner == "c1")) %>% 
#   ungroup() 

# if (nrow(property_current_remove)==0){
#   property_current_adj_floorspace <- property_current
# } else {
#   property_current_remove_sum <- property_current_remove %>% 
#     group_by(col34, col48, col49, col161, outliner) %>% 
#     summarize(col202_sum = sum(col202)) %>% 
#     ungroup() %>% 
#     pivot_wider(
#       names_from = outliner,
#       values_from = col202_sum,
#       id_cols = c("col34", "col48", "col49", "col161")
#     )
  
#   property_current_remove %<>% right_join(property_current_remove_sum, by = c("col34", "col48", "col49", "col161")) %>% 
#     filter(
#       outliner == "c0" & c0 <= c1 |
#         outliner == "c1" & c0 > c1
#     ) %>%
#     select(temp_id)
  
#   property_current_adj_floorspace <- anti_join(property_current, property_current_remove, by = "temp_id") %>%
#     select(-temp_id)
# }

# property_current_land_sum <- property_current_adj_floorspace %>%
#   group_by(col48, col49, col161) %>%
#   summarize(col202_sum = sum(col202))

# property_current_adj_land <- full_join(property_current_adj_floorspace, property_current_land_sum, by = c("col48", "col49", "col161")) %>%
#   mutate(adj_land = col161*(col202/col202_sum), adj_f_ratio = col202/adj_land)

# saveRDS(property_current_adj_land, property_c_fadj_rds)


