# Create Data for Dashboard

#### Setup
library(dplyr)

if(Sys.info()[["user"]] == "robmarty"){
  dash_dir <- "~/Documents/Github/rshiny-templates/map-full-page"
}

#### Make dummy data
latlon_df <- data.frame(
  uid = 1:100,
  latitude = runif(100)*45,
  longitude = runif(100)*90) %>%
  mutate(text = paste0("ID: ", uid))

#### Export
saveRDS(latlon_df, file.path(dash_dir, "data", "sample_coords.Rds"))

