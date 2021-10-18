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

#-------------------------------------------------------------------------------
#                                 SERVER
#-------------------------------------------------------------------------------


server = function(input, output, session) {
  
  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials),
    session = shiny::getDefaultReactiveDomain()
  )
  #---------------------------------------------------------------------------
  # MONGO DATABASE CONNECTION
  #---------------------------------------------------------------------------
  # collection_name_XXX = users_collection
  # database_name_XXX = dashboard
  # USER_XXX
  # PASS_XXX
  # SERVER_IP_OR_DNS
  # MONGO_PORT = 27017
  # DATABASE_XXX
  #---------------------------------------------------------------------------
  # DEMO DATA TO GENERATE COLLECTION:
  #
  # {
  #   "email" : "jhon.doe@shiny.com",
  #   "password" : "ASDF",
  #   "rol" : "FALSE",
  #   "start" : "2020-07-06",
  #   "expired" : "2022-07-31",
  #   "IBAN" : "CY17002001280000001200527600"
  # }
  # 
  # {
  #   "email" : "sussane.doe@shiny.com",
  #   "password" : "12345",
  #   "rol" : "FALSE",
  #   "start" : "2020-01-01",
  #   "expired" : "2022-12-31",
  #   "IBAN" : "ES6000491500051234567892"
  # }
  # 
  # {
  #   "email" : "murphy@shiny.com",
  #   "password" : "#456,QWeRty",
  #   "rol" : "TRUE",
  #   "start" : "2019-09-15",
  #   "expired" : "2021-12-31",
  #   "IBAN" : "AD1400080001001234567890"
  # }
  # 
  # {
  #   "email" : "celine@test.net",
  #   "password" : "xSf97",
  #   "rol" : "FALSE",
  #   "start" : "2020-04-01",
  #   "expired" : "2022-12-31",
  #   "IBAN" : "IS030001121234561234567890"
  # }
  #---------------------------------------------------------------------------
  # data_base <- mongo(collection = "collection_name_XXX", db = "database_name_XXX",
  #                    url ="mongodb://USER_XXX:PASS_XXX@SERVER_IP_OR_DNS:MONGO_PORT/DATABASE_XXX")
  
  df <- data_base$find(fields = '{"_id" : true, "email" : true,"password" : true, "rol" : true, "start" : true, "expired" : true, "IBAN": true}')

  object <- data.frame(df)
  
  output$users_table = renderDT(object, selection = 'single', rownames = F, editable = T, filter = 'bottom',options = list(scrollX = TRUE))
    
  #---------------------------------------------------------------------------
  # FUNCTION: updateDataFrame ()
  # DESCRIPTION: reload data frame to make reactive UI
  #---------------------------------------------------------------------------
  updateDataFrame <- function(){
      
    df <- data_base$find(fields = '{"_id" : true, "email" : true,"password" : true, "rol" : true, "start" : true, "expired" : true, "IBAN": true}')
      
    object <- data.frame(df)
      
    output$users_table = renderDT(object, selection = 'single', rownames = F, editable = T, filter = 'bottom',options = list(scrollX = TRUE))
  }
    
    
  #---------------------------------------------------------------------------
  # ADD USERNAME
  #---------------------------------------------------------------------------
  observeEvent(input$accept_button, {
  
    usuario <- paste('{"email":"',toString(input$label_email),'",
                      "password":"',toString(input$label_password),'",
                      "rol":"',toString(input$label_rol),'",
                      "start":"',toString(input$label_start),'",
                      "expired":"',toString(input$label_start),'",
                      "IBAN":"',toString(input$label_iban),'"
                      }', sep = "")
      
    #DATABASE INSERT
    data_base$insert(toString(usuario))
      
    #RELOAD DATAFRAME
    updateDataFrame()
      
    #CLOSE BSMODAL
    removeModal()
    toggleModal(session, modalId = "modal_add_button", toggle = "toggle")
  })
}
