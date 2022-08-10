### AGGREGATE THE PIXELS INTO SIMU
### CREATES A CSV FILE WHERE EACH ROW CONTAINS THE NUMBER OF PIXELS OF A
### GIVEN TILE THAT OVERLAPS A GIVEN SIMU

require(magrittr)

# WHERE PROCESSED TILES ARE STORED (CREATED BY PREVIOUS SCRIPT)
mdir <- "mapbiomas-split/"

files <- list.files(mdir, pattern = "\\.tif$")

mysum <- function(values) sum(values == 0, na.rm = TRUE)

biomes <- terra::vect("biomes-reproj.shp")

for(file in files){
  cat(paste0("Processing ", file, "\n"))  
  inputfile <- paste0(mdir, file)
  inputRaster <- terra::rast(inputfile) %>%
    terra::project(biomes)

  for(i in 2:4){
    cat(paste0("Processing CEZ ", i, "\n"))
    for(j in 6:1){
      
      data <- terra::vect(paste0("CEZ-", i, "biome-", j, ".shp"))

      pixels <- terra::extract(inputRaster, data, fun = mysum)
      names(pixels) <- c("id", "quantity")
      pixels$cez <- i
      pixels$biome <- j
      if(pixels$quantity[1] > 0)
        write.table(pixels, "result-unprotected-cez.csv", sep = ",", append = TRUE, row.names = FALSE, col.names = FALSE)
    }
  }
}
  
