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
library(mongolite)
library(tidyr)
library(DT)
library(DTedit)
library(shiny)
library(shinyBS)
library(jsonlite)

shinyApp(
  
  #-----------------------------------------------------------------------------
  #                                     [UI]
  #-----------------------------------------------------------------------------
  ui = dashboardPage(
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
                        
                        dateInput("label_start", "inicio",
                                  value = "2021-01-01",width = "100%"),
                        
                        dateInput("label_end", "fin",
                                  value = "2021-01-01",width = "100%"),
                        
                        
                        textInput("label_obra","IBAN",
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
  ),
  
  
  
  #-----------------------------------------------------------------------------
  #                                 SERVER
  #-----------------------------------------------------------------------------
  server = function(input, output, session) {
    
    
    #---------------------------------------------------------------------------
    # MONGO DATABASE CONNECTION
    #---------------------------------------------------------------------------
    # collection_name_XXX
    # database_name_XXX
    # USER_XXX
    # PASS_XXX
    # SERVER_IP_OR_DNS
    # MONGO_PORT
    # DATABASE_XXX
    #---------------------------------------------------------------------------
    data_base <- mongo(collection = "collection_name_XXX", db = "database_name_XXX",
                       url ="mongodb://USER_XXX:PASS_XXX@SERVER_IP_OR_DNS:MONGO_PORT/DATABASE_XXX")
    
    df <- data_base$find(fields = '{"_id" : true, "email" : true,"password" : true, "rol" : true, "start" : true, "expired" : true}')

    object <- data.frame(df)
  
    output$tabla_completa <- renderDataTable(object, options = list(pageLength = 5,searchHighlight = FALSE) )
    
    x = object
    
    output$users_table = renderDT(x, selection = 'single', rownames = F, editable = T, filter = 'bottom',options = list(scrollX = TRUE))
    
    
    #---------------------------------------------------------------------------
    # ADD USERNAME
    #---------------------------------------------------------------------------
    observeEvent(input$accept_button, {
  
      usuario <- paste('{"email":"',toString(input$label_email),'",
                        "password":"',toString(input$label_password),'",
                        "rol":"',toString(input$label_rol),'",
                        "start":"',toString(input$label_start),'",
                        "expired":"',toString(input$label_start),'"
                        }', sep = "")
      
      #DATABASE INSERT
      data_base$insert(toString(usuario))
      
      #CLOSE BSMODAL
      removeModal()
      toggleModal(session, modalId = "modal_add_button", toggle = "toggle")
    })
    
  })
