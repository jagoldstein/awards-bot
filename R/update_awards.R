#' Read in awards 
#' 
#' Run this to get the awards database file 
#' 
#' @param DATABASE_PATH (character) globally defined 
#' 
#' @export
import_awards_db <- function(DATABASE_PATH) {
  tryCatch({
    adc_nsf_awards <- utils::read.csv(DATABASE_PATH) %>% 
      data.frame(stringsAsFactors = FALSE) %>%
      apply(2, as.character) # force all fields into characters
  },
  error = function(e) {
    slackr_bot("I failed to read in the awards database file")
  })
}

#' Update Awards Database
#' 
#' Run this code to get the awards database with updated awards
#'
#' @param awards_db (data.frame) awards database to file containing database
#' @param from_date (date) date to begin search from 
#' @param to_date (date) date to end search at 
#'
#' @export
update_awards <- function(awards_db, from_date, to_date) {
  
  ## format dates
  format <- "%m/%d/%Y"
  to_date <- format(to_date, format)
  from_date <- format(from_date, format)
  
  ## get new awards from NSF API
  new_nsf_awards <- datamgmt::get_awards(from_date = from_date, to_date = to_date)
  new_nsf_awards <- new_nsf_awards[!(new_nsf_awards$id %in% awards_db$id), ]
  
  ## combine awards
  awards_db <- suppressWarnings(dplyr::bind_rows(awards_db, new_nsf_awards))
  
  return(awards_db)
}


## deal with dates ##

## this is needed if someone opens the database in excel and saves it as a csv, the dates format changes in this case
## Also NSF dates are m-d-y whereas R dates are y-m-d
## potentially there is a more elegant solution than the one here
## Forcing date columns to y-m-d

# is_date <- which(colnames(adc_nsf_awards) %in% c("date",
#                                                  "expDate",
#                                                  "startDate",
#                                                  "contact_initial",
#                                                  "contact_3mo",
#                                                  "contact_1mo",
#                                                  "contact_1wk"))
# 
# adc_nsf_awards[, is_date] <- apply(adc_nsf_awards[, is_date], c(1,2), function(x){
#   if (!is.na(x)) {  
#     
#     ## if not NA try to reformat date from m-d-y to y-m-d
#     ## may need to test edge cases to ensure this always works
#     tryCatch({
#       paste0(lubridate::mdy(x))
#     }, warning = function(w) {
#       x
#     })
#     
#   } else {
#     NA
#   }
# })