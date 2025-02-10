ui <- fluidPage(
  shinyjs::useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  tags$style( 
    "
    .shiny-input-container {margin-bottom: 5px;}
    .control-label {font-size: 14px;}          
    .selectize-input {font-size: 12px;}         
    .shiny-bound-input {font-size: 12px;}       
    .date-control .form-control {font-size: 12px; }
    .selectize-dropdown { font-size: 12px; }         
    "
  ),
  navbarPage(
    theme = bslib::bs_theme(bootswatch = "slate"), "RFM Segmentation",  
    tabPanel(
      div(img(src='getting_started.svg', height='20', width='20'),"Getting Started"), 
      
      fluidRow(
        column(width = 6,
               div(
                 style = "display: flex; justify-content: center; align-items: flex-start; height: 70vh;",
                 tags$img(src = "homePage.svg", style = "width: 700px; height: auto; opacity: 0.4;")
               )  
        ),
        column(width = 6,  
               h3("Getting Started", style = "color: #a4b3b6; font-weight: bold;"),
               tags$hr(style="border-color: #009999; margin-top: 3px;"),
               
               br(),
               br(),
               
               h6( 
                 tags$img(src = "customer.svg", height = 30, width = 30),
                 "   RFM Segmentation", 
                 style = "color: #009899; font-weight: bold;"
               ),
               tags$hr(style="border-color: #009999; margin-top: 3px;"),
               p(HTML("• <b>Customers Data :&nbsp</b> Filter data for insights based on delivery date, customers and delivery location."),
                 style = "color: #a4b3b6; font-size: 14px;"),
               p(HTML("• <b>Customers Scoring :&nbsp</b> Score and segment customers based on their buying habits and achieved value (Revenue)."),
                 style = "color: #a4b3b6; font-size: 14px;"),
               p(HTML("• <b>Customer's Delivery Place Scoring :&nbsp</b> Score and segment customer's delivery place based on buying habits and achieved value (Revenue)."),
                 style = "color: #a4b3b6; font-size: 14px;"),
    
               br(),
               br(),
        )
      )
    ),
    tabPanel(
      div(img(src='customer.svg', height='20', width='20')," Customers"), 
      
      fluidRow(
        tabsetPanel(
          tabPanel(
            div(HTML(paste('<img src="table.svg" height="25" width="25" style="vertical-align: middle; margin-right: 4px;" />',
                           '<span style="vertical-align: middle;">&nbsp;</span>',
                           "Customers Data")),
                style="font-size: 13px;"
                
            ),
            br(),
            fluidRow(
              column(width = 3, align = "left", style = "border: 2px solid #16525e; border-radius: 10px;",
                     h6("Data Filtering", style = "color: #16525e; font-weight: bold;" ),
                     tags$hr(style="border-color: #009999; margin-top: 3px;"),
                     
                     
                     dateRangeInput("date_filter_customer", "Date:", start = NULL, end = NULL),
                     
                     p("Customers:", style = "margin-top: 0; font-size: 14px;"),
                     div( 
                       style = "max-height: 200px; min-height: 200px; overflow-y: auto;",
                       selectizeInput("customer_filter_customer", label="", choices = NULL, multiple = TRUE) 
                     ),
                     
                     p("Location:", style = "margin-top: 0; font-size: 14px;"),
                     div( 
                       style = "max-height: 200px; min-height: 200px; overflow-y: auto;",
                       selectizeInput("location_filter_customer", label="", choices = NULL, multiple = TRUE)  
                     ),
                     
              ),
              column(width = 9, align = "right", style = "border: 2px solid #16525e; border-radius: 10px;",
                     
                     withSpinner(uiOutput("customers_data"), type = 2)
              )
            )
          ),
          tabPanel(
            div(HTML(paste('<img src="customers_rfm.svg" height="25" width="25" style="vertical-align: middle; margin-right: 4px;" />',
                           '<span style="vertical-align: middle;">&nbsp;</span>',
                           "Customers Scoring")),
                style="font-size: 13px;"
            ),
            fluidRow(
              column(2,style = "border-left: 1px solid #16525e; border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",
                     
                     numericInput('select_frequency_bins', 'Frequency Bins', 5, min = 1, max = 9),
                     numericInput('select_recency_bins', 'Recency Bins', 5, min = 1, max = 9)
                     

              ),
              column(2, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",
                     
                     numericInput('select_monetary_bins', 'Monetary Bins', 5, min = 1, max = 9),
                     
                     dateInput("rfm_date_analysis", "Analysis Date:", value = Sys.Date())

              ),
              column(2, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",
                     br(),
                     actionButton("run_RFM", "Run Scoring"),
                     br(),
                     br(),
                     actionButton("open_modal_rfm_customers_table", "Results Table"),
                     
              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",
                     
              ),
            ),
            fluidRow(
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-right: 1px solid #16525e; border-radius: 5px;",
                     
                     withSpinner(plotlyOutput("rfm_bar_charts_customers"), type = 2)
                     
              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-left: 1px solid #16525e; border-radius: 5px;",
                     
                     withSpinner(plotlyOutput("rfm_heat_map_customers"), type = 2)
                    
              )
            ),
            fluidRow(
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-right: 1px solid #16525e; border-radius: 5px;",
                     
                     withSpinner(plotlyOutput("rfm_histogram_customers"), type = 2)
                     
              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-left: 1px solid #16525e;  border-radius: 5px;",
                     
                     withSpinner(plotlyOutput("rfm_scatter_plot_customers"), type = 2)
                     
              )
            )
          ),
          tabPanel(
            div(HTML(paste('<img src="delivery_place.svg" height="25" width="25" style="vertical-align: middle; margin-right: 4px;" />',
                           '<span style="vertical-align: middle;">&nbsp;</span>',
                           "Customer's Delivery Place Scoring")),
                style="font-size: 13px;"
            ),
            fluidRow(
              column(2,style = "border-left: 1px solid #16525e; border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",

                     numericInput('select_frequency_bins_locations', 'Frequency Bins', 5, min = 1, max = 9),
                     numericInput('select_recency_bins_locations', 'Recency Bins', 5, min = 1, max = 9)


              ),
              column(2, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",

                     numericInput('select_monetary_bins_locations', 'Monetary Bins', 5, min = 1, max = 9),

                     dateInput("rfm_date_analysis_locations", "Analysis Date:", value = Sys.Date())

              ),
              column(2, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",
                     br(),
                     actionButton("run_RFM_locations", "Run Scoring"),
                     br(),
                     br(),
                     actionButton("open_modal_rfm_locations_table", "Results Table"),


              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-radius: 5px;",


                     br(),
                     uiOutput("filters_info_RFM_locations"),
                     br()
              )
            ),
            fluidRow(
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-right: 1px solid #16525e; border-radius: 5px;",

                     withSpinner(plotlyOutput("rfm_bar_charts_locations"), type = 2)


              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-left: 1px solid #16525e; border-radius: 5px;",

                     withSpinner(plotlyOutput("rfm_heat_map_locations"), type = 2)

              )
            ),
            fluidRow(
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-right: 1px solid #16525e; border-radius: 5px;",

                     withSpinner(plotlyOutput("rfm_histogram_locations"), type = 2)


              ),
              column(6, style = "border-top: 1px solid #16525e; border-bottom: 1px solid #16525e; border-left: 1px solid #16525e;  border-radius: 5px;",

                     withSpinner(plotlyOutput("rfm_scatter_plot_locations"), type = 2)

              )
            )
          )
        )
      )
    )
  )
)





