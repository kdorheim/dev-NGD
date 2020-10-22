# 0. Set Up ---------------------------------------------------------------------------------
# Define the directories, note that this will need to change. 
INPUT_DIR <-"/Users/dorh012/Documents/2020/dev-NGD/inputs/CanESM/subset"
TEMP_DIR  <- file.path(INPUT_DIR, 'temp-df'); dir.create(TEMP_DIR)
OUT_DIR   <- file.path(INPUT_DIR, 'W'); dir.create(OUT_DIR)

# Load libraries and helper functions, this will also have to change.
source(here::here('scratch', '0.fxns.R'))

# Define the function to calculate wettest day of the year
# 
# Args
#   file: path to the pr file to process
#   OUT_DIR: the location where to write the output to 

calculate_W <- function(file, OUT_DIR){
  
  assert_that(grepl(pattern = 'pr', x = file))
  
  out_file <- file.path(OUT_DIR, paste0('W-', basename(file)))
  if(file.exists(out_file)) file.remove(out_file)
  
  system2('cdo', args = c('-a -yearmax', file, out_file))
  return(out_file)
  
}

# 1. Figure out what the wettest day of the year ------------------------------------------------

# First find all of the netcdf files to process

# First find all of the precip files to process
to_process <- find_nc_files('pr', INPUT_DIR)

# Wettest day of the year
files <- unlist(lapply(as.character(to_process$files), function(f){
  message('processing ', f, '\n')
  calculate_W(f, OUT_DIR)
}))
