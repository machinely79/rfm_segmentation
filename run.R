
library(shinymanager)
library(leaflet)
library(purrr)  
library(rfm)
library(ggplot2)
library(reactablefmtr)
library(readxl)
library(shinythemes)
library(plotly)
library(shinyjs)
library(reactable)
library(shiny)
library(dplyr)
library(tidyr)
library(lubridate)
library(shinycssloaders)
library(data.table)
library(shinyWidgets)
library(openxlsx)

options(scipen = 999)



# Options for reactable --------------------------------------------------------------

header_style <- list(fontSize = "13px")
cell_style <- list(fontSize = "12px")

options(reactable.theme = reactableTheme(
  color = "hsl(233, 9%, 87%)",
  backgroundColor = "#1b1d1f" ,  
  borderColor =  "hsl(233, 9%, 22%)",
  stripedColor = "#051524",    
  highlightColor =  "#009899", "hsl(233, 12%, 24%)",
  inputStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  selectStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonHoverStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
  pageButtonActiveStyle = list(backgroundColor = "hsl(233, 9%, 28%)"),
  cellStyle =  cell_style,
  headerStyle = header_style

))

#Options for Spinner------------------------------------------------------------------
options(spinner.color="#66CDAA", spinner.color.background="#1b1d1f", spinner.size=2)

#Set limit to 50 MB
options(shiny.maxRequestSize = 50 * 1024^2)


#---------------------------- RUN SHINY ------------------------------
ui <- source("ui.R")$value
server <- source("server.R")$value
shinyApp(ui = ui, server = server)
