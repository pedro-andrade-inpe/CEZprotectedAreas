
### SPLIT RASTER DATA INTO SEVERAL TILES
require(magrittr)

# MAPBIOMAS PIXEL VALUES
pixelValues = c(1, 3, 4, 5, 49, 10, 11, 12, 32, 29, 13, 14, 15, 18, 19, 39, 20, 40, 41, 36, 46, 47, 48, 9, 21, 22, 23, 24, 30, 25, 26, 33, 31, 27)
repValues = rep(0, length(pixelValues))

repValues[pixelValues %in% c(14, 15, 18, 19, 39, 20, 40, 41, 36, 46, 47, 48, 9, 21)] <- 1
repValues[pixelValues %in% c(22, 23, 24, 30, 25 )] <- 1
repValues[pixelValues %in% c(27)] <- 1

reclassifyValues <- cbind(pixelValues, repValues)

# DIRECTORY WHERE MAPBIOMAS TIFF FILES FOR BRAZIL ARE STORED
mdir <- "C:/Users/pedro/Dropbox/pesquisa/2022/aline/"

# SPLIT RASTER INTO SEVERAL TILES
splitRaster <- function(inputFile, outputDir, n.side){
  r  <- raster::raster(inputFile)
  er <- raster::extent(r)
  
  dx <- (er[2] - er[1]) / n.side  # extent of one tile in x direction
  dy <- (er[4] - er[3]) / n.side  # extent of one tile in y direction
  xs <- seq(er[1], by = dx, length = n.side) #lower left x-coordinates
  ys <- seq(er[3], by = dy, length = n.side) #lower left y-coordinates
  cS <- expand.grid(x = xs, y = ys)
  
  ## loop over extents and crop
  for(i in 1:nrow(cS)) {
    cat(paste0("tile ", i, "/", nrow(cS), "\n"))
    outputFile <- paste0(tools::file_path_sans_ext(basename(inputFile)), "-tile-", i, ".tif")
    output <- paste0(outputDir, "/", outputFile)
    if(file.exists(output))
      cat("File already exists\n")
    else{
      ex1 <- c(cS[i, 1], cS[i, 1] + dx, cS[i, 2], cS[i, 2] + dy)  # create extents for cropping raster
      cl1 <- raster::crop(r, ex1, progress = "text") %>%
        raster::reclassify(reclassifyValues, progress = "text")
      
      if(1 %in% raster::unique(cl1))
        raster::writeRaster(cl1, output, progress = "text", overwrite = TRUE)
      else
        cat(paste0("Raster without any pixels from the selected class(es)\n"))
    }
  }
}

# TIF FILE TO BE PROCESSED
# THE SCRIPT WILL CREATE A DIRECTORY WITH THE SAME NAME OF THE FILE
# TO STORE THE SPLITTED RASTERS
file <- list.files(mdir, pattern = "\\.tif$")[2] # [2] AS 2000 DATA IS ALSO IN THE DIRECTORY

fname <- tools::file_path_sans_ext(file)
file_with_path <- paste0(mdir, file)
mraster <- raster::raster(file_with_path)
break_dim <- ceiling(sqrt(raster::ncell(mraster) / 1e8)) # TILES WITH 1e8 X 1e8 PIXELS 
newdir <- paste0("mapbiomas-split")
dir.create(newdir)

splitRaster(file_with_path, newdir, break_dim)

