
server <- function(input, output, session) { 
  source("D:/MyData/Application_B2B_sales/scripts/rfm_analysis.R") 
  
  
  # Loads customer data from a CSV file and makes it reactive
  data_customer <- reactive({
    df <- read.csv("D:/MyData/Application_B2B_sales/data/customers.csv", sep = ";")
  })
  
  
  
  # Creates a reactiveValues object to store customer data
  rv_customer <- reactiveValues(
    df_customer = NULL
  )
  
  
  
  # Observes changes in customer data and updates reactive values and input filters accordingly
  observe({
    df_customer <- data_customer()
    rv_customer$df_customer <- df_customer
    updateDateRangeInput(session, "date_filter_customer", start = min(df_customer$order_date), end = max(df_customer$order_date))
    updateSelectizeInput(session, "customer_filter_customer", choices = unique(df_customer$customer_id), selected = unique(df_customer$customer_id), server = TRUE)
    updateSelectizeInput(session, "location_filter_customer", choices = unique(df_customer$delivery_location), selected = unique(df_customer$delivery_location), server = TRUE)
    
  })
  
  
  # Filters data based on selected date range, customer ID, and delivery location
  filtered_customer_data <- reactive({
    req(rv_customer$df_customer)
    filtered_data <- rv_customer$df_customer %>%
      filter(
        order_date >= input$date_filter_customer[1] & order_date <= input$date_filter_customer[2],
        customer_id %in% input$customer_filter_customer,
        delivery_location %in% input$location_filter_customer
      )
    
    return(filtered_data)
    
  })
  
  
  # Renders a reactive table (reactable) to display filtered customer data with various UI options
  output$customers_data <- renderUI({
    reactable(
      filtered_customer_data(),
      defaultPageSize = 15,
      filterable = TRUE,
      searchable = TRUE,
      showSortable = TRUE,
      resizable = TRUE,
      wrap = FALSE,
      bordered = TRUE,
      minRows = 10,
      highlight = TRUE,
      style = list(
        #backgroundColor = "#a3bcc0",
        #color = "#000000"     # Change the color of the content to blue
      )
    )
    
  })
  

  #Creates a reactiveValues object to store the RFM analysis results for customers
  rfm_result_table_customers <- reactiveValues(rfm_customers_table = NULL)

  
  # Performs RFM analysis on filtered customer data when the button is clicked 
  # and updates the UI to display the results in a reactive table
  observeEvent(input$run_RFM, {
      if (input$run_RFM) {
        monetary_bins <- input$select_monetary_bins
        frequency_bins <- input$select_frequency_bins
        recency_bins <- input$select_recency_bins
        analysis_date  <- input$rfm_date_analysis
        df_customer <- filtered_customer_data()
    
        rfm_customer_table <- rfm_customers(df_customer, analysis_date, recency_bins, frequency_bins, monetary_bins)
        
        rfm_result_table_customers$rfm_customers_table <- rfm_customer_table 
                                                          
        output$modal_customer_rfm_table <- renderUI({
          
          fluidRow(
            
            reactable(
              rfm_customer_table,
              defaultPageSize = 15,
              filterable = TRUE,
              searchable = TRUE,
              showSortable = TRUE,
              resizable = TRUE,
              wrap = FALSE,
              bordered = TRUE,
              minRows = 15,
              highlight = TRUE,
              style = list(
                #backgroundColor = "#a3bcc0",
                #color = "#000000"     # Change the color of the content to blue
              )
            )
          )
        })
      }
    })
    
    
  
  
  # Displays a modal dialog with the RFM analysis results and a download option when triggered
  observeEvent(input$open_modal_rfm_customers_table, {
      showModal(modalDialog(
        title = "RFM Analysis by Customers",
        easyClose = TRUE,  
        size = "xl",
        uiOutput("modal_customer_rfm_table"),
        footer = tagList(
          downloadButton("download_rfm_customer_df", "Download Data"),
          modalButton("Close")
       )
    ))
  })
    
    
  # Handles the download of the RFM customer analysis results as an Excel file
  output$download_rfm_customer_df <- downloadHandler(
    filename = function() {
        "myRFMcustomers.xlsx"
      },
    content = function(file) {
      rfm_customer_table <- rfm_result_table_customers$rfm_customers_table
      write.xlsx(rfm_customer_table, file)
    }
  )
    
    
    
  # Creates a reactiveValues object to store the RFM analysis results for locations
  rfm_result_table_locations <- reactiveValues(rfm_locations_table = NULL)

    
  
  # Performs RFM analysis on filtered customer data by location when the button is clicked 
  # and updates the UI to display the results in a reactive table
  observeEvent(input$run_RFM_locations, {
    if (input$run_RFM_locations) {

        monetary_bins <- input$select_monetary_bins_locations
        frequency_bins <- input$select_frequency_bins_locations
        recency_bins <- input$select_recency_bins_locations
        analysis_date  <- input$rfm_date_analysis_locations
        df_customer <- filtered_customer_data()
        rfm_locations_df <- rfm_locations(df_customer, analysis_date, recency_bins, frequency_bins, monetary_bins)

        rfm_locations_df <- rfm_locations_df %>%
          rename(delevery_location_id = customer_id)

        rfm_result_table_locations$rfm_locations_table <- rfm_locations_df

        output$modal_location_rfm_table <- renderUI({

          fluidRow(
            reactable(
              rfm_locations_df,
              defaultPageSize = 15,
              filterable = TRUE,
              searchable = TRUE,
              showSortable = TRUE,
              resizable = TRUE,
              wrap = FALSE,
              bordered = TRUE,
              minRows = 15,
              highlight = TRUE,
              style = list(
                #backgroundColor = "#a3bcc0",
                #color = "#000000"     # Change the color of the content to blue
            )
          )
        )
      })
    }
  })
    
  
  
  
  
  # Displays a modal dialog with the RFM analysis results by location and a download option when triggered
    observeEvent(input$open_modal_rfm_locations_table, {
      showModal(modalDialog(
        title = "RFM Analysis by Delivery Place",
        easyClose = TRUE,  
        size = "xl",
        uiOutput("modal_location_rfm_table"),
        footer = tagList(
          downloadButton("download_rfm_location_df", "Download Data"),
          modalButton("Close")
        )
      ))
    })
    
    
    
    
  
    # Handles the download of the RFM location analysis results as an Excel file
    output$download_rfm_location_df <- downloadHandler(
      filename = function() {
        "myRFMdeliveryPlace.xlsx"
      },
      content = function(file) {
        rfm_locations_df <- rfm_result_table_locations$rfm_locations_table
        write.xlsx(rfm_locations_df, file)
      }
    )
    

    

    # Renders a Plotly bar chart to visualize RFM analysis for customers, faceted by recency and frequency scores
    output$rfm_bar_charts_customers <- renderPlotly({
      if (input$run_RFM) {
      rfm_customer_table <- rfm_result_table_customers$rfm_customers_table
      rfm_customer_table$monetary_score  <- as.factor(rfm_customer_table$monetary_score)
      rfm_customer_table$frequency_score <- paste("Frequency\n Score: ", rfm_customer_table$frequency_score)
      rfm_customer_table$recency_score <- paste("Recency\n Score: ", rfm_customer_table$recency_score)
      
      gg <- ggplot(rfm_customer_table, aes(x = monetary_score)) +
        geom_bar(stat = "count", fill = "#66CDAA") +
        facet_grid(recency_score ~ frequency_score, scales = "free") +
        labs(x = "Monetary Scores",   size = 12) +
        
        theme(strip.text.y = element_text(angle = 0, hjust = 1),
              strip.text.x = element_text(angle = 0, hjust = 0.5),
              axis.title.y = element_blank(),  
              axis.text.y = element_blank(),  
              axis.text.x = element_text(colour ="#a4b3b6" ),
              axis.title.x = element_text(colour ="#a4b3b6" ),
              axis.ticks.y = element_blank(), 
              panel.grid.major = element_blank(),  
              panel.grid.minor = element_blank(),  
              panel.background = element_rect(fill = "#1b1d1f"),    
              plot.background = element_rect(fill = "#1b1d1f"),  
              
              strip.background = element_rect(fill = "#1b1d1f", linewidth = 1),
              strip.text = element_text(colour = "#a4b3b6", face = "bold")
        )
      
      gg
      
      p_plotly <- ggplotly(gg) %>% layout(title = list(text = 'Cross RFM Scores - Bar Charts', font = list(size = 16, 
                                                                                                           color = '#a4b3b6')),
                                          margin = list(l = 50,
                                                        r = 100,
                                                        b = 50,
                                                        t = 80))
      }
    })
    
    
    
    
    
    # Renders a Plotly bar chart to visualize RFM analysis for locations, faceted by recency and frequency scores
    output$rfm_bar_charts_locations <- renderPlotly({
      if (input$run_RFM_locations) {
        rfm_locations_df <- as.data.frame(rfm_result_table_locations$rfm_locations_table)
        
        rfm_locations_df$monetary_score  <- as.factor(rfm_locations_df$monetary_score)
        rfm_locations_df$frequency_score <- paste("Frequency\n Score: ", rfm_locations_df$frequency_score)
        rfm_locations_df$recency_score <- paste("Recency\n Score: ", rfm_locations_df$recency_score)
        
        gg <- ggplot(rfm_locations_df, aes(x = monetary_score)) +
          geom_bar(stat = "count", fill = "#66CDAA") +
          facet_grid(recency_score ~ frequency_score, scales = "free") +
          labs(x = "Monetary Scores",   size = 12) +
          theme(strip.text.y = element_text(angle = 0, hjust = 1),
                strip.text.x = element_text(angle = 0, hjust = 0.5),
                axis.title.y = element_blank(),  
                axis.text.y = element_blank(),   
                axis.text.x = element_text(colour ="#a4b3b6" ),
                axis.title.x = element_text(colour ="#a4b3b6" ),
                axis.ticks.y = element_blank(), 
                panel.grid.major = element_blank(),  
                panel.grid.minor = element_blank(),   
                panel.background = element_rect(fill = "#1b1d1f"),  
                plot.background = element_rect(fill = "#1b1d1f"),  
                strip.background = element_rect(fill = "#1b1d1f", linewidth = 1),
                strip.text = element_text(colour = "#a4b3b6", face = "bold")
          )
        
        p_plotly <- ggplotly(gg) %>% layout(title = list(text = 'Cross RFM Scores - Bar Charts', font = list(size = 16, 
                                                                                                             color = '#a4b3b6')),
                                            margin = list(l = 50,
                                                          r = 100,
                                                          b = 50,
                                                          t = 80))
        p_plotly
      }
    })
    
    
    
    
    # Renders a Plotly heat map to visualize the mean revenue based on RFM scores for customers
    output$rfm_heat_map_customers <- renderPlotly({
      if (input$run_RFM) {
        
        rfm_customer_table <- rfm_result_table_customers$rfm_customers_table
        

        rfm_customer_table$monetary_score  <- as.factor(rfm_customer_table$monetary_score)
        rfm_customer_table$frequency_score <- paste("Frequency\n Score: ", rfm_customer_table$frequency_score)
        rfm_customer_table$recency_score <- paste("Recency\n Score: ", rfm_customer_table$recency_score)
        
       
        data_heat_map <- rfm_customer_table %>%
          group_by(frequency_score, recency_score) %>%
          reframe(mean_amount = mean(amount, na.rm = TRUE))
        
        
        plot <- plot_ly(
          x = data_heat_map$frequency_score,
          y = data_heat_map$recency_score,
          z = data_heat_map$mean_amount,
          type = "heatmap",
          text = paste(
                        "Frequency: ", substr(data_heat_map$frequency_score, nchar(data_heat_map$frequency_score), nchar(data_heat_map$frequency_score)),
                        "<br>Recency: ", substr(data_heat_map$recency_score, nchar(data_heat_map$recency_score), nchar(data_heat_map$recency_score)),
                       "<br>Mean Revenue: ", round(data_heat_map$mean_amount, 1)),
          hoverinfo = "text",
          colorscale = list(c(0, "#ade0cf"), c(1, "#026e49")), 
          showscale = TRUE,
          colorbar = list(title = list(text = "Mean Amount", font = list(size = 12, color = "#a4b3b6")),
                          tickfont = list(size = 12, color = "#a4b3b6")
          )
        ) %>% layout(
          title = list(text = 'RFM Customers - Heat Map', font = list(color = '#a4b3b6')),
          xaxis = list(
            title = "Frequency", 
            titlefont = list(size = 12, color = "#a4b3b6"),
            tickfont = list(size = 12, color = "#a4b3b6")),
          yaxis = list(
            title = "Recency",
            titlefont = list(size = 12, color = "#a4b3b6"),  
            tickfont = list(size = 12, color = "#a4b3b6"),
            side = "left" 
          ),
          paper_bgcolor = "#1b1d1f", 
          plot_bgcolor = "#1b1d1f",   
          showlegend = FALSE,  
          margin = list(l = 10, r = 10, t = 50, b = 10) 
        )
        
      }
      
    })
    
    
    
  
    # Renders a Plotly heat map to visualize the mean revenue based on RFM scores for locations
    output$rfm_heat_map_locations <- renderPlotly({
      if (input$run_RFM_locations) {
        rfm_locations_df <- rfm_result_table_locations$rfm_locations_table
        rfm_locations_df$monetary_score  <- as.factor(rfm_locations_df$monetary_score)
        rfm_locations_df$frequency_score <- paste("Frequency\n Score: ", rfm_locations_df$frequency_score)
        rfm_locations_df$recency_score <- paste("Recency\n Score: ", rfm_locations_df$recency_score)
        
        data_heat_map <- rfm_locations_df %>%
          group_by(frequency_score, recency_score) %>%
          reframe(mean_amount = mean(amount, na.rm = TRUE))
        
        plot <- plot_ly(
          x = data_heat_map$frequency_score,
          y = data_heat_map$recency_score,
          z = data_heat_map$mean_amount,
          type = "heatmap",
          text = paste(
            "Frequency: ", substr(data_heat_map$frequency_score, nchar(data_heat_map$frequency_score), nchar(data_heat_map$frequency_score)),
            "<br>Recency: ", substr(data_heat_map$recency_score, nchar(data_heat_map$recency_score), nchar(data_heat_map$recency_score)),
            "<br>Mean Revenue: ", round(data_heat_map$mean_amount, 1)),
          hoverinfo = "text",
          colorscale = list(c(0, "#ade0cf"), c(1, "#026e49")), 
          showscale = TRUE,
          colorbar = list(title = list(text = "Mean Amount", font = list(size = 12, color = "#a4b3b6")),
                          tickfont = list(size = 12, color = "#a4b3b6")
          )
        ) %>% layout(
          title = list(text = 'RFM Customers - Heat Map', font = list(color = '#a4b3b6')),
          xaxis = list(
            title = "Frequency", 
            titlefont = list(size = 12, color = "#a4b3b6"),
            tickfont = list(size = 12, color = "#a4b3b6")),
          yaxis = list(
            title = "Recency",
            titlefont = list(size = 12, color = "#a4b3b6"),  
            tickfont = list(size = 12, color = "#a4b3b6"),
            side = "left" 
          ),
          paper_bgcolor = "#1b1d1f",  
          plot_bgcolor = "#1b1d1f",   
          showlegend = FALSE,  
          margin = list(l = 10, r = 10, t = 50, b = 10)
        )
      }
    })
    
    
    

    output$rfm_histogram_customers <- renderPlotly({
      
      if (input$run_RFM) {
        df_customer <- filtered_customer_data()
        data_histogram <- df_customer %>%
          group_by(customer_id) %>% 
          reframe(Count = n())

        plot <- data_histogram %>%
          plot_ly(x = ~Count, 
                  type = 'histogram',
                  xbins = list(size = 0.5), marker = list(color = '#04697d'),
                  marker = list(color = '#04697d', line = list(color = 'white', width = 0.5)),
                  hovertemplate = '%{y} Customers made %{x} Orders'
                  
          )%>%
          layout( 
            title = list(text = 'Customers by Orders', font = list(color = '#a4b3b6')),
            xaxis = list(
              title = "Orders", 
              tick0 = 1, 
              dtick = 1,
              titlefont = list(size = 12, color = "#a4b3b6"),
              tickfont = list(size = 12, color = "#a4b3b6")),
            yaxis = list(
              title = "Customers",
              titlefont = list(size = 12, color = "#a4b3b6"),  
              tickfont = list(size = 12, color = "#a4b3b6"),
              side = "left",
              gridcolor = "#626b6d",
              tickmode = 'linear',
              dtick = 1
            ),
            
            paper_bgcolor = "#1b1d1f",  
            plot_bgcolor = "#1b1d1f",   
            showlegend = FALSE,  
            margin = list(l = 10, r = 10, t = 50, b = 10) 
            
          )
      }
    })
    
    
    
    # Renders a Plotly histogram to visualize the distribution of customers based on the number of orders
    output$rfm_histogram_locations <- renderPlotly({
      if (input$run_RFM_locations) {
        
        df_customer <- filtered_customer_data()
        data_histogram <- df_customer %>%
          group_by(delivery_location) %>% 
          reframe(Count = n())
        
        plot <- data_histogram %>%
          plot_ly(x = ~Count, 
                  type = 'histogram',
                  xbins = list(size = 0.5), marker = list(color = '#04697d'),
                  marker = list(color = '#04697d', line = list(color = 'white', width = 0.5)),
                  hovertemplate = '%{y} Delivery Places made %{x} Orders '
                  
          )%>%
          layout( 
            title = list(text = 'Orders by Delivery Place', font = list(color = '#a4b3b6')),
            xaxis = list(
              title = "Orders", 
              tick0 = 1, 
              dtick = 1,
              titlefont = list(size = 12, color = "#a4b3b6"),
              tickfont = list(size = 12, color = "#a4b3b6")),
            yaxis = list(
              title = "Delivery Place",
              titlefont = list(size = 12, color = "#a4b3b6"),  
              tickfont = list(size = 12, color = "#a4b3b6"),
              side = "left", 
              gridcolor = "#626b6d",
              tickmode = 'linear',
              dtick = 1
            ),
            
            paper_bgcolor = "#1b1d1f", 
            plot_bgcolor = "#1b1d1f",   
            showlegend = FALSE,  
            margin = list(l = 10, r = 10, t = 50, b = 10) 
            
          )
        
        
        
        
      }
      
    })
    
    
    
    
    # Renders a Plotly scatter plot to visualize the relationship between the number of days since the last order and the amount spent by customers
    output$rfm_scatter_plot_customers <- renderPlotly({
      if (input$run_RFM) {
        rfm_customer_table <- rfm_result_table_customers$rfm_customers_table
        sorted_data <- rfm_customer_table[order(rfm_customer_table$amount), ]
        custom_ticks <- c(sorted_data$amount[1],
                          quantile(sorted_data$amount, c(0.25, 0.5, 0.75)), 
                          sorted_data$amount[length(sorted_data$amount)])
        
        custom_ticklabels <- c(paste("Min: ", custom_ticks[1]), 
                               "Q1", "Median", "Q3", 
                               paste("Max: ", custom_ticks[length(custom_ticks)]))
        
        scatter_plot <- rfm_customer_table %>%
          plot_ly(
            x = ~amount,
            y = ~recency_days,
            type = 'scatter',
            mode = 'markers',
            marker = list(color = '#04697d'),
            marker = list(color = '#04697d', line = list(color = 'white', width = 0.5)),
            hovertemplate = 'Number of days since the last Order: %{y}<br>Amount: %{x} '
          ) %>%
          layout( 
            title = list(text = 'Number of days since the last Order vs Amount ', font = list(color = '#a4b3b6')),
            xaxis = list(
              title = "Amount", 
              tickmode = 'array',
              tickvals = custom_ticks,
              ticktext = custom_ticklabels,
              titlefont = list(size = 12, color = "#a4b3b6"),
              tickfont = list(size = 12, color = "#a4b3b6")
            ),
            yaxis = list(
              title = "Number of days - last Order",
              titlefont = list(size = 12, color = "#a4b3b6"),  
              tickfont = list(size = 12, color = "#a4b3b6")
            ),
            paper_bgcolor = "#1b1d1f", 
            plot_bgcolor = "#1b1d1f",   
            showlegend = FALSE, 
            margin = list(l = 10, r = 10, t = 50, b = 10) 
          )
        
        
        
        
      }
      
    })
    
    
    
    # Generates a Plotly scatter plot to visualize the relationship between the number of days since the last order and the amount spent by customers.
    output$rfm_scatter_plot_locations <- renderPlotly({
      if (input$run_RFM_locations) {
        rfm_locations_df <- rfm_result_table_locations$rfm_locations_table
        sorted_data <- rfm_locations_df[order(rfm_locations_df$amount), ]
        custom_ticks <- c(sorted_data$amount[1],
                          quantile(sorted_data$amount, c(0.25, 0.5, 0.75)), 
                          sorted_data$amount[length(sorted_data$amount)])
        
        custom_ticklabels <- c(paste("Min: ", custom_ticks[1]), 
                               "Q1", "Median", "Q3", 
                               paste("Max: ", custom_ticks[length(custom_ticks)]))
        
        scatter_plot <- rfm_locations_df %>%
          plot_ly(
            x = ~amount,
            y = ~recency_days,
            type = 'scatter',
            mode = 'markers',
            marker = list(color = '#04697d'),
            marker = list(color = '#04697d', line = list(color = 'white', width = 0.5)),
            hovertemplate = 'Number of days since the last Order: %{y}<br>Amount: %{x} '
          ) %>%
          layout( 
            title = list(text = 'Number of days since the last Order vs. Amount ', font = list(color = '#a4b3b6')),
            xaxis = list(
              title = "Amount", 
              tickmode = 'array',
              tickvals = custom_ticks,
              ticktext = custom_ticklabels,
              titlefont = list(size = 12, color = "#a4b3b6"),
              tickfont = list(size = 12, color = "#a4b3b6")
            ),
            yaxis = list(
              title = "Number of days - last Order",
              titlefont = list(size = 12, color = "#a4b3b6"),  
              tickfont = list(size = 12, color = "#a4b3b6")
             
            ),
            paper_bgcolor = "#1b1d1f", 
            plot_bgcolor = "#1b1d1f",  
            showlegend = FALSE,  
            margin = list(l = 10, r = 10, t = 50, b = 10) 
          )
      }
    })
}