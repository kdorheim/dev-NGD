# 0. Set Up ---------------------------------------------------------------------------------
# Define the directories, note that this will need to change. 
INPUT_DIR <-"/Users/dorh012/Documents/2020/dev-NGD/inputs/CanESM/subset"
TEMP_DIR  <- file.path(INPUT_DIR, 'temp-df'); dir.create(TEMP_DIR)
OUT_DIR   <- file.path(INPUT_DIR, 'TXx'); dir.create(OUT_DIR)

# Load libraries and helper functions, this will also have to change.
source(here::here('scratch', '0.fxns.R'))

# Define the TXx function to calculate the monthly maximum 
# 
# Args
#   file: path to the tasmax file to process
#   OUT_DIR: the location where to write the output to 

calculate_TXx <- function(file, OUT_DIR){
  
  assert_that(grepl(pattern = 'tasmax', x = file))
  
  out_file <- file.path(OUT_DIR, paste0('TXx-', basename(file)))
  if(file.exists(out_file)) file.remove(out_file)
  
  system2('cdo', args = c('-a -monmax', file, out_file))
  return(out_file)
  
}


# 1. Calculate the monthly daily max temperture ------------------------------------------------

# First find all of the netcdf files to process
to_process <- find_nc_files('tasmax', INPUT_DIR)

# Calculate TXx! 
files <- unlist(lapply(as.character(to_process$files), function(f){
  message('processing ', f, '\n')
  calculate_TXx(f, OUT_DIR)
}))
