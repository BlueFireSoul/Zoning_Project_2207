rm(list = ls())
cat("\014")
library(glue)
library(tidyverse)
library(magrittr)
library(data.table)

current_user <- Sys.info()["user"]

default_region <- "ma"
if (interactive()) {
  run_code <- default_region
} else {
  run_code <- ifelse(is.na(commandArgs(trailingOnly = TRUE)[1]), default_region, commandArgs(trailingOnly = TRUE)[1])
  run_code <- ifelse(run_code == "", default_region, run_code)
}

append_path <- function(file_path) {
  directory <- dirname(file_path)
  file_name <- basename(file_path)
  base_name <- tools::file_path_sans_ext(file_name)
  extension <- tools::file_ext(file_name)
  new_base_name <- paste0(base_name, "_", run_code)
  new_file_path <- file.path(directory, paste0(new_base_name, ".", extension))
  return(new_file_path)
}

append_ori_path <- function(file_path) {
  directory <- dirname(file_path)
  file_name <- basename(file_path)
  base_name <- tools::file_path_sans_ext(file_name)
  extension <- tools::file_ext(file_name)
  if (run_code == 'cas') {
    run_code <- 'ca'
  }
  new_base_name <- paste0(base_name, "_", run_code)
  new_file_path <- file.path(directory, paste0(new_base_name, ".", extension))
  return(new_file_path)
}

# routine folder
output_dir <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/")
output2_dir <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output2/")
temp_dir <- glue(ifelse(current_user == "dmh5950",
                        "C:/Users/dmh5950/Desktop/temp/",
                        "C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/temp/"))
dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
graph_dir <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/graph_output/")
data_dir <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/")
# raw data
property_current <- append_ori_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/CoreLogic/current/property_basic2/property_basic2.zip"))
mortgage_current <- append_ori_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/CoreLogic/current/mortgage_basic2/mortgage_basic2.zip"))

tract2019_shp <-  append_ori_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2019_tract/tl_2019_tract.shp"))

tract_pop_2019_csv <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/tract_pop_2019.csv")
block_0010_xwalk_csv <- append_ori_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/blk2000_blk2010.csv"))
block_pop_2000_csv <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/block_pop_2000.csv")

acs2019_csv_gz <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/census/acs2019.csv.gz")
# standard processed data
mortgage_current_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/mortgage_current.RDS"))
property_current_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_current.RDS"))
property_coord_dict_csv <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_coord_dict.csv"))
property_apt_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_apt.RDS"))
property_c_fadj_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_fadj_rds.RDS"))
property_c_block_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_block.RDS"))
property_c_xwalk_csv <-  append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_xwalk.csv"))
property_cdict_xwalk_csv <-  append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_cdict_xwalk.csv"))

hmda_data_rds <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/hmda_data.RDS")

tract_density_2019_csv <-  append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_density_2019.csv"))

scag_zoning_2016_csv <- glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/scag_zoning_2016.csv")

tract_ma_2019_csv = glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_ma_2019.csv")
tract_ma_matrix_csv = glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_ma_matrix.csv")
commute_cost_matrix_csv = glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output2/commute_cost_matrix.csv")

mortgage_merge1_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/mortgage_merge1.RDS"))
mortgage_merge2_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/mortgage_merge2.RDS"))
mortgage_merge3_rds <- append_path(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/mortgage_merge3.RDS"))
### Functions
frequency_table <- function(x) {
  count_df <- data.frame(table(x, useNA = "ifany"))
  count_df$percentage <- round(count_df$Freq / sum(count_df$Freq) * 100, 2)
  count_df <- count_df[order(-count_df$Freq), ]
  names(count_df) <- c("Value", "Frequency", "Percentage")
  return(count_df)
}

weighted_frequency_table <- function(x, y) {
  if (length(x) != length(y)) {
    stop("Vectors x and y must be the same length.")
  }
  repeated_x <- rep(x, y)
  count_df <- data.frame(table(repeated_x, useNA = "ifany"))
  count_df$percentage <- round(count_df$Freq / sum(count_df$Freq) * 100, 2)
  count_df <- count_df[order(-count_df$Freq), ]
  names(count_df) <- c("Value", "Frequency", "Percentage")
  return(count_df)
}

plot_frequency <- function(x, lower_perc = 0, upper_perc = 100) {
  lower_cutoff <- quantile(x, probs = lower_perc / 100, na.rm = TRUE)
  upper_cutoff <- quantile(x, probs = upper_perc / 100, na.rm = TRUE)
  x <- x[x >= lower_cutoff & x <= upper_cutoff]
  hist(x, breaks = 30, xlab = "Value", ylab = "Frequency", main = "Frequency Graph")
}

percentile_plot <- function(column_vector, perc1, perc2, column_name = "Input") {
  percentiles <- quantile(column_vector, probs = seq(perc1/100, perc2/100, 0.01), na.rm = TRUE)
  percentiles_df <- data.frame(
    Percentile = seq(perc1, perc2, 1) ,
    Value = percentiles
  )
  plot(percentiles_df$Percentile, percentiles_df$Value, type = 'l',
       xlab = "Percentile", ylab = "Value",
       main = paste("Percentile Plot of", column_name))
}

nonparametric_plot <- function(df,col2, col1, perc1, perc2) {
  if (!require("ggplot2", character.only = TRUE)) {
    install.packages("ggplot2")
    library(ggplot2)
  }
  if (!require("mgcv", character.only = TRUE)) {
    install.packages("mgcv")
    library(mgcv)
  }
  if(!(col1 %in% colnames(df)) | !(col2 %in% colnames(df))) {
    stop(paste("The columns", col1, "and/or", col2, "are not in the dataframe"))
  }
  if(!(is.numeric(perc1) && is.numeric(perc2) && perc1 >= 0 && perc1 <= 100 && perc2 >= 0 && perc2 <= 100 && perc1 < perc2)) {
    stop("Percentile values must be numbers between 0 and 100, and the first percentile must be less than the second percentile")
  }
  formula <- as.formula(paste(col2, "~ s(", col1, ")"))
  model <- gam(formula, data = df)
  lower <- quantile(df[[col1]], perc1/100, na.rm = TRUE)
  upper <- quantile(df[[col1]], perc2/100, na.rm = TRUE)
  
  new_data <- df[1, ] # Create a new dataframe with the same structure as df
  new_data <- new_data[rep(1,100),]
  new_data[[col1]] <- seq(lower, upper, length.out = 100)
  
  pred <- predict(model, newdata=new_data, type="response", se.fit=TRUE)
  
  plot_df <- data.frame(x = new_data[[col1]], predicted = pred$fit)
  
  plot_df$upper <- pred$fit + (1.96 * pred$se.fit) # upper bound
  plot_df$lower <- pred$fit - (1.96 * pred$se.fit) # lower bound
  
  ggplot(plot_df, aes(x=x, y=predicted)) +
    geom_line() +
    geom_ribbon(aes(ymin=lower, ymax=upper), alpha=0.2) +
    labs(x=col1, y=col2, title="Non-parametric regression with confidence intervals") 
}