# UI
shinyUI(
  navbarPage(
    title = div(
      div(id = 'logo-id', img(src = "NPTlogos2.png", height = 70)),
      tags$a("DFRM Home", href = 'http://www.nptfisheries.org')
    ),
    id = "kus_navbar",
    windowTitle = "Hydrosystem Power Generation",
    theme = "styles.css",
    position = "fixed-top",
    collapsible = TRUE,
    footer = div(
      hr(),
      column(10, offset=1,
             div(
               id = "footer-id",
               "The data presented in this web application may not be solely collected, managed or owned
        by the Nez Perce Tribe. All data should be considered draft and is not guaranteed for
        accuracy.  Permission to use the data should be sought from the original collectors and data managers."
             )
      )
    ),
    
    sidebarPanel(width = 3,
                 fluidRow(
                   column(12,
                          h3("Hydrosystem Power Generation"),
                          h5("The web applicaiton tool enables users to browse through historic 
                  summaries of power generation at the FCRPS four Lower Snake River dams."),
                          h6(tags$a("Created by the Nez Perce Tribe, Department of Fisheries Resources Management",
                                    href = 'http://nptfisheries.org')),
                          
                          hr(),
                          # Project Select (DAM)
                          radioButtons(inputId = 'project_input',
                                       label = h3('Select Hydrosystem Project:'),
                                       choices = projects,
                                       selected = 'Lower Granite', inline = FALSE),
                          # Statistic select
                          checkboxGroupInput(inputId = 'stat_input',
                                             label = h3('Statistics:'),
                                             choices = c('Minimum' = 'min', 
                                                         'Mean' = 'mean', 
                                                         'Maximum' = 'max'),
                                             selected = 'mean', inline = FALSE),
                          # Timespan select
                          radioButtons(inputId = 'span_input',
                                       label = h3('Summary timespan:'),
                                       choices = c('Daily' = 'date', 
                                                   'Monthly' = 'year_month', 
                                                   'Yearly'= 'year'),
                                       selected = 'date', inline = FALSE),
                          hr(),
                          fluidRow(
                            align = 'center',
                            h5("Data obtained using the USACE Dataquery 2.0 tool at:"),
                            h5(tags$a("https://www.nwd-wc.usace.army.mil/dd/common/dataquery/www/", style = 'color:blue'))
                          )
                          
                   )
                 )
    ), # close sidebarPanel
    
    # BODY
    mainPanel(width = 9,
              
              fluidRow(
                br(),
                plotlyOutput('power_plot2', height = '90vh')
                
              ) # close MainPanel
    )# close fluidRow
    
  ) # close navBarPage
) # closes shinyUI
