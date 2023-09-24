library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))
library(utils)
library(ggplot2)

property_current <- readRDS(property_c_fadj_rds)
property_coord_dict <- read.csv(property_cdict_xwalk_csv) %>%
  mutate(col1 = as.character((col1)))

mortgage_data <- readRDS(mortgage_merge3_rds) %>%
  group_by(col1) %>%
  summarize(m_amount = mean(m_amount), hm_income = mean(hm_income), dm_white = mean(dm_white), dm_african = mean(dm_african))

property_current_mod <- property_current %>%
  merge(property_coord_dict, by = 'col1') %>%
  merge(mortgage_data, by = 'col1') %>%
  mutate(dupac = col201/adj_land*43560, pu_size = col202_sum/col201) 

percent_to_sample <- 0.1
sampled_df <- property_current_mod %>% sample_frac(percent_to_sample)

# Load the necessary libraries
df <- sampled_df

df <- df %>%
  mutate(housing_unit_size_percentile = percent_rank(pu_size))

y_min <- quantile(df$pu_size, 0.01, na.rm= TRUE)
y_max <- quantile(df$pu_size, 0.99, na.rm= TRUE)

p <- ggplot(df, aes(x = housing_unit_size_percentile, y = pu_size)) + 
  geom_line(color = "blue") +
  labs(x = "Housing Unit Size Percentile", y = "Housing Unit Size (sq ft)") +
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
                     expand = c(0, 0)) +  # Do not expand the x-axis beyond the specified limits
  scale_y_continuous(limits = c(y_min, y_max)) # Do not expand the x-axis beyond the specified limits

print(p)


# Then plot the data
p <- ggplot(df, aes(x = housing_unit_size_percentile, y = hm_income)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Housing Unit Size Percentile", y = "Income (000s)") +
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
ggsave(paste0(graph_dir, "income_size_percentile.png"), plot = p, width = 7, height = 4, dpi = 300)

# Then plot the data
p <- ggplot(df, aes(x = housing_unit_size_percentile, y = m_amount/hm_income)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Housing Unit Size Percentile", y = "mortgage-to-income ratio") +
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
ggsave(paste0(graph_dir, "mortgage_ratio_size_percentile.png"), plot = p, width = 7, height = 4, dpi = 300)

# Then plot the data
p <- ggplot(df, aes(x = housing_unit_size_percentile, y = dm_white)) + 
  geom_smooth(method = "loess", se = TRUE, level = 0.95, color = "blue", fill = "lightblue") +
  labs(x = "Housing Unit Size Percentile", y = "mortgage-to-income ratio") +
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