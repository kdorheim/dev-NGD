
library(magrittr)
INPUT_DIR <- file.path('inputs', 'CanESM', 'subset')
OUT_DIR <- file.path(INPUT_DIR, 'test')
dir.create(OUT_DIR)

in_nc  <- file.path(INPUT_DIR, 'tasmax_day_CanESM2_historical_rcp85_r10i1p1_19500101-21001231.nc_subset.nc')
out_file <- file.path(OUT_DIR, 'testing.nc')
system2('cdo', args = c('splitmon', in_nc, out_file))

# So i think that the way that this is going to go is is  that it will have to split up 
# by year and month, concat monts of how we define the seson togeher, the do the stat thing
# and then concatethe seasonal values together.... which like is possible although kind of annoying

