# Generate Username and Passwords

#### Setup
library(bcrypt)

if(Sys.info()[["user"]] == "robmarty"){
  dash_dir <- "~/Documents/Github/rshiny-templates/map-full-page"
}

#### Generate username/passwords
PASSWORD <- readline(prompt = "Enter password: ")

password_df <- data.frame(username = c("robmarty"),
                          hashed_password = hashpw(PASSWORD),
                          stringsAsFactors = F)

#### Export
saveRDS(password_df, file.path(dash_dir, "data", "passwords.Rds"))

