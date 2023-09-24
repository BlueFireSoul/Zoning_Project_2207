library(glue)
current_user <- Sys.info()["user"]
source(glue("C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/config.r"))

data_folder <- "C:/Users/dmh5950/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/SCAG/csv/"

la_csv <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_Los_Angeles_County.csv",sep=''))
o_csv <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_Orange_County.csv",sep=''))
r_csv <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_Riverside_County.csv",sep=''))
sb_csv <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_San_Bernardino_County.csv",sep=''))
v_csv <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_Ventura_County.csv",sep=''))

zoning_data <- read.csv(paste(data_folder,"2016_Land_Use_Information_for_Los_Angeles_County.csv",sep='')) %>%
    filter(substr(SCAG_GP_CO,1,2)=="11")
frequency_table(zoning_data$DENSITY)
frequency_table(zoning_data$HIGH)
frequency_table(zoning_data$LOW)
frequency_table(zoning_data$ACRES)
plot_frequency(zoning_data$ACRES, upper_perc = 90)
frequency_table(zoning_data$SCAG_GP_CO)
plot_frequency(zoning_data$HIGH)
plot_frequency(zoning_data$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1111"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1112"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1113"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1110"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1120"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1122"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1125"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1140"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1100"))$HIGH, upper_perc = 90)

names(la_csv)
names(o_csv)
names(r_csv)
names(sb_csv)
names(v_csv)


la_csv %<>% select(DENSITY, HIGH, LOW, SCAG_GP_CO, ACRES)
o_csv %<>% select(DENSITY, HIGH, LOW, SCAG_GP_CO, ACRES)
r_csv %<>% select(DENSITY, HIGH, LOW, SCAG_GP_CO, ACRES)
sb_csv %<>% select(DENSITY, HIGH, LOW, SCAG_GP_CO, ACRES)
v_csv %<>% select(DENSITY, HIGH, LOW, SCAG_GP_CO, ACRES)
zoning_data <- bind_rows(la_csv, o_csv, r_csv, sb_csv, v_csv) %>%
  filter(substr(SCAG_GP_CO,1,2)=="11")

frequency_table(zoning_data$DENSITY)
frequency_table(zoning_data$HIGH)
frequency_table(zoning_data$LOW)
plot_frequency(zoning_data$ACRES, upper_perc = 90)
frequency_table(zoning_data$SCAG_GP_CO)
plot_frequency(zoning_data$HIGH)
plot_frequency(zoning_data$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1111"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1112"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1113"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1110"))$HIGH, upper_perc = 99)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1120"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1122"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1125"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1140"))$HIGH, upper_perc = 90)
plot_frequency((zoning_data%>%filter(SCAG_GP_CO=="1100"))$HIGH, upper_perc = 90)

