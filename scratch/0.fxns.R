# Define user functions 

# The libraries
library(data.table)
library(assertthat)


# Find and format nc files for a single variable 
#
# Args 
#   var: a variable string 
#   INPUT_DIR: a directory that contains the netcdf files to process
# Return
#  a data frame of the netcdf files and cmip information
find_nc_files <- function(var, INPUT_DIR){
  
  # Find the netcdf files 
  files <- list.files(INPUT_DIR, paste0(var, '_'), full.names = TRUE)
  assertthat::assert_that(all(file.exists(files))) # Check to make sure that all the files exist
  assertthat::assert_that(length(files) >= 1, msg = paste0('no ', var, ' files found')) # Make sure that more than one file exists
  assertthat::assert_that(all(grepl(pattern = '.nc', x = files))) # Make sure that the files are netcdf files so that they can be processed with cdo
  
  # Extract information about each netcdf 
  name  <- gsub(pattern = '.nc', replacement = '', x = basename(files)) # Parse out the base name
  list_list <- strsplit(x = name, split = '_') # Parse out the cmip information from the name

  # Create a data frame of the cmip information
  cmip_data        <- as.data.frame(matrix(data = unlist(list_list), ncol = length(list_list[[1]]), byrow = TRUE), 
                                    stringsAsFactors = FALSE)
  names(cmip_data) <- c('variable', 'domain', 'model','experiment1', 'experiment2', 'ensemble', 'time')
  cmip_data        <- cmip_data[, names(cmip_data) %in% c('variable', 'model', 'ensemble')]
  
  return(cbind(files, cmip_data))
  
}
