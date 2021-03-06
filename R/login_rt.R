#' Login to RT
#' 
#' Run this code to login to RT
#' RT Passwords are stored in keychain "r-RT"
#' If no passwords is stored, will ask for password and create new key
#' 
#' Note, to work with a cron job the following must be true:
#' key must be moved into the System keychain from the login keychain manually (within Keychain Access)
#' key has to have "Allow all applications to access this item" set to true
#'
#' @param RT_username (character) rt username
#'
#' @export
login_rt <- function(RT_username) {
  
  ## get password from keychain
  pass <- tryCatch({
    keyring::key_get("r-RT", username = RT_username)
  }, error = function(e) {
    keyring::key_set("r-RT", username = RT_username)
    keyring::key_get("r-RT", username = RT_username)
  })
  
  ## login to RT
  rt::rt_login(user = RT_username,
               pass = pass,
               rt_base = "https://support.nceas.ucsb.edu/rt")
  
}


## For now this is simply going to be: 
## login to RT
# maybe suppress messages
rt::rt_login(user = RT_USER,
             pass = RT_PASS,
             rt_base = RT_URL)


## Write this function 
check_rt_login()

rt::rt_ticket_search(query = "Queue:'arcticAwards'AND(Status='new')", rt_base = "https://support.nceas.ucsb.edu/rt")

base_api <- rt:::rt_url(rt_base, "search", "ticket?")

#based on httr::modify_url()
#possible TODO - turn this into its own function that can be used internally in the package
inputs <- rt:::compact(list(query = utils::URLencode(query, reserved = TRUE),
                       orderBy = orderBy,
                       format = format))

params <- paste(paste0(names(inputs), "=", inputs), collapse = "&")

url <- paste0(base_api, params)

out <- rt:::rt_GET(url)

if(format == "s"){
  out$content <- out$content %>%
    tidyr::gather(id, value)
}

if(format == "i"){
  out$content <- out$content %>%
    stringr::str_split("\n")
}

return(out)