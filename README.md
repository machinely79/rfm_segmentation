# RFM Segmentation Web App

RFM Segmentation is a user-friendly web app that allows users to easily perform RFM (Recency, Frequency, Monetary) analysis for customers and their locations through an intuitive interface. The app uses interactive charts and tables to help users identify patterns and gain insights into customer and location behavior based on three key parameters: recency (time since the last purchase), frequency (how often purchases occur), and monetary (amount spent).
     
   ![GettingStarted](https://github.com/machinely79/rfm_segmentation/blob/main/images/getting_started.png)


## Key Features

1. ### Interactive Visualization
   
**RFM Cross-distribution:**
   - Displays bar charts showing the cross-distribution of RFM scores for customers and their locations, helping to identify different customer segments based on their activity.

**Heatmap:**
   - Uses heatmaps to visualize average **monetary** values (spending amounts) across different combinations of **recency** and **frequency** scores, making the data easily interpretable for behavior analysis.

**Scatter Plots:**
   - Generates scatter plots displaying the relationship between spending amount and the number of days since the last purchase.




     ![RFMScoring](https://github.com/machinely79/rfm_segmentation/blob/main/images/customer_scoring.png)



2. ### Interactive Tables and Data Download
   - Enables users to download tables with RFM scores for further exploration and data manipulation.




 ![GetScores](https://github.com/machinely79/rfm_segmentation/blob/main/images/get_data_scores.png)



3. ### Customer and Location-based Analysis
   - Analyzes data based on customers and their locations, providing deeper insights into customer behavior patterns in specific areas.


The application is useful for business data analysis, marketing strategy optimization, customer segmentation, and improving targeted marketing campaigns.



## Technologies Used 🛠️
This application is built using the following technologies and packages:

 R (>= 4.3.1),
    shinymanager(>= 1.0.410),
    leaflet(>= 2.2.1),
    purrr(>= 1.0.2),
    rfm(>= 0.2.2),
    ggplot2(>= 3.4.3),
    reactablefmtr(>= 2.0.0),
    readxl(>= 1.4.3),
    shinythemes(>= 1.2.0),
    plotly(>= 4.10.2),
    shinyjs(>= 2.1.0),
    reactable(>= 0.4.4),
    shiny(>= 1.7.5),
    dplyr(>= 1.1.2),
    tidyr(>= 1.3.0),
    lubridate(>= 1.9.2),
    shinycssloaders(>= 1.0.0),
    data.table(>= 1.14.8),
    shinyWidgets(>= 0.7.6),
    openxlsx(>= 4.2.5.2)
