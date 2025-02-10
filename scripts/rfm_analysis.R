
#Function for running RFM analysis by customers
rfm_customers <- function(customer_data, analysis_date, recency_bins, frequency_bins, monetary_bins){

  analysis_date <- as_date(analysis_date)
  customer_data$order_date <- as.Date(customer_data$order_date)
  rfm_customers <- rfm_table_order(customer_data,
                                   customer_id = customer_id,
                                   order_date = order_date,
                                   revenue = amount,
                                   analysis_date = analysis_date,
                                   recency_bins = recency_bins,
                                   frequency_bins = frequency_bins,
                                   monetary_bins = monetary_bins)

  rfm_customers <- rfm_customers$rfm

  return(rfm_customers)
}




#Function to run RFM analysis by customer location
rfm_locations <- function(customer_data, analysis_date_location, recency_bins_location, frequency_bins_location, monetary_bins_location){
  analysis_date_location <- as_date(analysis_date_location)
  customer_data$order_date <-as.Date(customer_data$order_date)
  rfm_locations <- rfm_table_order(customer_data, 
                                   customer_id = delivery_location,
                                   order_date = order_date,
                                   revenue = amount,
                                   analysis_date = analysis_date_location,
                                   recency_bins = recency_bins_location,
                                   frequency_bins = frequency_bins_location,
                                   monetary_bins = monetary_bins_location)
  
  rfm_locations <- rfm_locations$rfm
  
  return(rfm_locations = rfm_locations)
  
}
