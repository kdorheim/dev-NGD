
# 0. Set Up ---------------------------------------------------------------------------------
# Define the directories, note that this will need to change. 
INPUT_DIR <-"/Users/dorh012/Documents/2020/dev-NGD/inputs/CanESM/subset"
TEMP_DIR  <- file.path(INPUT_DIR, 'temp-df'); dir.create(TEMP_DIR)
OUT_DIR <- file.path(INPUT_DIR, 'fd'); dir.create(OUT_DIR)

# Load libraries and helper functions, this will also have to change.
source(here::here('scratch', '0.fxns.R'))

# Define the function to calculate the frost days 
#
# Args
#   file: the tasmin file to process
#   temp_dir: location to save all of the intermediate files too, note there will be a lot of them!
#   out_dir: the location where to save the final output files to
#   cleaUp: boolean default set to TRUE, to remove all of the intermediate files
calculate_fd <- function(file, temp_dir, out_dir, cleanUp = TRUE){
  
  # Make sure that the number of frost days is being calcualted on the tasmin. 
  assert_that(grepl(pattern = 'tasmin', x = file), msg = 'Can only process tasmin files')
  
  # Make sure that the directories actually exist 
  assert_that(file.exists(temp_dir))
  assert_that(file.exists(out_dir))
  
  # Split up the netcdf file into individual years
  t_file <- file.path(temp_dir, 'tasmin')
  system2('cdo', args = c('splityear', file, t_file))
  
  # Find all of the individual files and calculate the freeze days 
  tasmin_single_year <- list.files(path = temp_dir, pattern = '.nc', full.names = TRUE)
  fd_files <- unlist(lapply(tasmin_single_year, function(f){
    
    out_f <- paste0(f, '-fd.nc')
    system2('cdo', args = c('eca_fd', f, out_f))
    return(out_f)
    
  })) 
  
  # Concatenate all fo the fd files into a single netcdf. 
  outfile <- file.path(out_dir, paste0('FD-', basename(file)))
  if(file.exists(outfile)) file.remove(outfile)
  system2('cdo', args = c('-a cat', fd_files, outfile))

  
  # Remove the intermediate files
  if(cleanUp){
    file.remove(tasmin_single_year, fd_files)
  }
  
  # Return the single netcdf file of the frost days. 
  return(outfile)
  
}

# 1. Calculate frost days ---------------------------------------------------------------------

# First find all of the netcdf files to process
to_process <- find_nc_files('tasmin', INPUT_DIR)

# For each entry in the data frame process the netcdf file, note tthat the 
outfiles <- lapply(as.character(to_process$files), function(f){
  message('Processing ', f, '\n')
  calculate_fd(file = f, temp_dir = TEMP_DIR, out_dir = OUT_DIR)
  }) 

unlist(outfiles) %>%  
  nc_open() %>%  
  ncvar_get('time')

nc_close(unlist(outfiles))
