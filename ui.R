#-------------------------------------------------------------------------------
# R-Shiny Project | DASHBOARD: AN OPEN BETA
# pdrmerinodlg@gmail.com 
# https://www.linkedin.com/in/pedro-merino-4b87b7221
# 
# The purpose of this panel is to connect to a mongo database and manage user control to an online banking application.
# 
# In this version I show how to:
#   
#   - connect to mongo database
#   - create user
#
# This beta is inspired by the work of Jason Bryer -> https://github.com/jbryer
#-------------------------------------------------------------------------------
library(shinydashboard)
library(shinymanager)
library(shinythemes)
library(mongolite)
library(tidyr)
library(DT)
library(DTedit)
library(shiny)
library(shinyBS)
library(jsonlite)

#-------------------------------------------------------------------------------
#                                     [UI]
#-------------------------------------------------------------------------------


#Define some credentials, mandatory for shinymanager library
credentials <- data.frame(
  user = c("shiny", "shinymanager"), # mandatory
  password = c("azerty", "12345"), # mandatory
  start = c("2019-04-15"), # optinal (all others)
  expire = c(NA, "2019-12-31"),
  admin = c(FALSE, TRUE),
  comment = "Simple and secure authentification mechanism 
  for single ‘Shiny’ applications.",
  stringsAsFactors = FALSE
)

ui <- dashboardPage(
    skin = "purple",
    dashboardHeader(
      title = span("DASHBOARD")
    ),
    
   dashboardSidebar(
      sidebarMenu(
        menuItem("Users", tabName = "tab_user", icon = icon("users"))
      )
    ),
    
    dashboardBody(
      tabItems(
        
      #------------------------------ USERS TAB ------------------------------
      tabItem(tabName = "tab_user",
                
              actionButton("add_button", "New User", icon = icon("user-plus")),
              br(),
                
              #--------------------- BS MODAL (FORM) ADD USER ----------------
              bsModal(id='modal_add_button',title = "NEW USERNAME", trigger = "add_button",
                        
                      tags$head(tags$style("#modal_add_button .modal-footer{ display:none}")),
                        
                      textInput("label_email","email",
                                placeholder = 'email@preving.com',
                                width = "100%"),
                        
                      textInput("label_password","password",
                                placeholder = 'pasword12345',
                                width = "100%"
                      ),
                        
                      selectInput("label_rol","rol",
                                  choices = list("true" = "true", "false" = "false"),
                                  width = "100%"
                      ),
                        
                      dateInput("label_start", "start",
                                value = "2021-01-01",width = "100%"),
                        
                      dateInput("label_end", "expired",
                                value = "2021-01-01",width = "100%"),
                        
                        
                      textInput("label_iban","IBAN",
                                placeholder = 'ESXX',
                                width = "100%"
                      ),
                        
                      #Accept button embebed in a row
                      fluidRow(
                        column(12, align="right",
                               actionButton("accept_button", "Accept"),
                               modalButton('Cancel')
                        )
                      )
                ),
      
                br(),
                
                DTOutput('users_table')
        )
      )
    )
)

#Set labels for login page (language module), mandatory for library shinymanager
set_labels(
  language = "en",
  "Please authenticate" = "",
  "Username:" = "Username:",
  "Password:" = "Password:"
)

#Wrap your UI with secure_app with shinymanager library
ui <- secure_app(ui,
                 
                 tags_top =  tags$div( tags$img(
                   src = "https://blog.rstudio.com/2021/02/01/shiny-1-6-0/thumbnail.jpg", width="50%")
                 ),
                 choose_language = FALSE,
                 theme = shinytheme("cyborg")
)
