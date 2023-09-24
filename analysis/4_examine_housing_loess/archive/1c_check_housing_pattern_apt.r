library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(lfe)

property_current <- readRDS(property_apt_rds)
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201)%>%
  filter(pu_size<5000, pu_size>500)

percent_to_sample <- 0.05
sampled_df <- property_current_mod %>% sample_frac(percent_to_sample)

# Load the necessary libraries
library(ggplot2)
library(dplyr)
library(tidyverse)

# Assuming your data is in a data frame named df
df <- sampled_df

# First, calculate the percentiles for the housing unit size.
df <- df %>%
  mutate(housing_unit_size_percentile = percent_rank(pu_size))


# Then plot the data
p <- ggplot(df, aes(x = pu_size, y = adj_land/col201)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Housing Unit Size (sq ft)", y = "Land per Housing Unit (sq ft)") +
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
        panel.border = element_blank()) 

# Print the plot
print(p)
ggsave(paste0(graph_dir, "density_size_apt.png"), plot = p, width = 7, height = 4, dpi = 300)


# Then plot the data
p <- ggplot(df, aes(x = pu_size, y = adj_f_ratio)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Housing Unit Size (sq ft)", y = "FAR") +
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
        panel.border = element_blank()) 

# Print the plot
print(p)
ggsave(paste0(graph_dir, "area_size_apt.png"), plot = p, width = 7, height = 4, dpi = 300)
