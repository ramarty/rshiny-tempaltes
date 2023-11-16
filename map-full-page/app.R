# Crashmap

# Parameters -------------------------------------------------------------------
# To enable password landing page, set below to FALSE
Logged = FALSE

# Setup ------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinythemes)
library(dplyr)
library(leaflet)
library(leaflet.extras)
library(bcrypt)

options(warn=0)

# If need to run locally:
if(Sys.info()[["user"]] == "robmarty"){
  setwd("~/Documents/Github/CrashMap-Nairobi/Dashboards/ntsa_fatal_crashes")
}

# ui ---------------------------------------------------------------------------
ui_password <- function(){
  tagList(
    div(id = "login",
        h3("Dashboard", style = "text-align: center; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;"),
        wellPanel(textInput("userName", "Username"),
                  passwordInput("passwd", "Password"),
                  br(),actionButton("Login", "Log in")),
        htmlOutput("loginMessage")),
    tags$style(type="text/css", "#login {font-size:12px;   text-align: left;position:absolute;top: 40%;left: 50%;margin-top: -100px;margin-left: -150px;}")
  )}

ui = (htmlOutput("page"))

uif <- fluidPage(
  navbarPage("Dashboard", id="nav",
             
             tabPanel("Interactive map",
                      div(class="outer",
                          
                          tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("gomap.js")
                          ),
                          
                          # If not using custom CSS, set height of leafletOutput to a number instead of percent
                          leafletOutput("crashmap", width="100%", height="100%"),
                          
                          # Panel ----------------------------------------------
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                        width = 270, height = 400,

                                        style =  "overflow-y: scroll;",
                                        
                                        tags$style("#hourrange_map {
                                                    font-size:14px;
                                                    font-family: helvetica;
                                                   }"),

                                        h3("Crash Map"),
                                        
                                        h6("Notes.")
                          )
                      )
             ),
             conditionalPanel("false", icon("crosshair"))
  )
)

# Server -----------------------------------------------------------------------
server = (function(input, output, session) {
  
  USER <- reactiveValues(Logged = Logged)

  observe({ 
    if (USER$Logged == F) {
      if (!is.null(input$Login)) {
        if (input$Login > 0) {
          Username <- isolate(input$userName)
          Password <- isolate(input$passwd)
          
          passwords_df <- readRDS(file.path("data", "passwords.Rds"))

          if(Username %in% passwords_df$username){
            passwords_df_i <- passwords_df[passwords_df$username %in% Username,]
            
            if(checkpw(Password, passwords_df_i$hashed_password) %in% TRUE){
              USER$Logged <- TRUE
            } else {
              USER$Message <- "Incorrect username or password."
            }
          } else{
            USER$Message <- "Incorrect username or password."
          }
          
          
          
        } 
      }
    }    
  })
  observe({
    if (USER$Logged == FALSE) {
      
      output$page <- renderUI({
        div(class="outer",do.call(bootstrapPage,c("",ui_password())))
      })
      
      output$loginMessage <- renderText({
        paste0("<b><p style='color:red;'>", USER$Message, "</p></b>")
      })
      
    }
    if (USER$Logged == TRUE) 
    {
      output$page <- renderUI({
        div(uif)
      })
      
      # Map --------------------------------------------------------------------
      police_df <- readRDS("data/sample_coords.Rds")

      output$crashmap <- renderLeaflet({
        
        # Subset Data --------------------------------------------------------------
        leaflet_map <-  leaflet() %>%
          addTiles() %>%
          addFullscreenControl() %>%
          addCircles(data = police_df)
        
        leaflet_map
        
      })
    
    }
  })
})

# Run the app ------------------------------------------------------------------
shinyApp(ui, server)
