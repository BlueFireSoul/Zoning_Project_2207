library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(sf)
library(ggplot2)

property_current <- readRDS(property_c_fadj_rds)
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

mortgage_data <- readRDS(mortgage_merge3_rds) %>%
  group_by(col1) %>%
  summarize(m_amount = mean(m_amount), hm_income = mean(hm_income))

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  merge(mortgage_data, by = 'col1') %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201) 

coordinates <- st_as_sf(property_current_mod, coords = c("col49.x", "col48.x"), crs = 4326)
specific_point <- st_point(c(-71.05804050694815,42.36038876047336))
specific_point <- st_sfc(specific_point, crs = 4326)

specific_point_utm <- st_transform(specific_point, 32619) 
coordinates_utm <- st_transform(coordinates, 32619)

# Calculate the distance
property_current_mod$distance <- st_distance(coordinates_utm, specific_point_utm)
property_current_mod$distance <- as.numeric(property_current_mod$distance)


percent_to_sample <- 0.1
sampled_df <- property_current_mod %>% sample_frac(percent_to_sample)
df <- sampled_df

df <- df %>%
  mutate(income_percentile = percent_rank(hm_income))

p <- ggplot(df, aes(x = income_percentile, y = distance/1000)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Income Percentile", y = "Distance from City Center (km)") +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "white", color = "white"),  # Set panel background color to white
        plot.background = element_rect(fill = "white", color = "white"),  # Set plot background color to white
        panel.grid.major = element_line(color = alpha("gray", 0.3)),  # Make grid lines more transparent
        panel.grid.minor = element_blank(),
        axis.text = element_text(size = 14),  # Set the axis text size to 14
        axis.title = element_text(size = 14),
        plot.title = element_text(size = 16, hjust = 0.5),
        axis.line.x = element_line(color = "black"),
        axis.line.y = element_line(color = "black"),
        axis.ticks = element_line(color = "black"),
        legend.position = "right",
        panel.border = element_blank()) +
  scale_x_continuous(breaks = seq(0.1, 0.9, 0.1),  # Set breaks from 0.1 to 0.9 with 0.1 interval
                     labels = paste0("p", seq(10, 90, 10)),  # Labels from p10 to p90
                     limits = c(0.01, 0.99),  # Set x-axis limits
                     expand = c(0, 0))  # Do not expand the x-axis beyond the specified limits

# Print the plot
print(p)
ggsave(paste0(graph_dir, "distance_income_percentile.png"), plot = p, width = 7, height = 4, dpi = 300)