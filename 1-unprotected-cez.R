
cez_file <- "C:/Users/pedro/Dropbox/pesquisa/2021/r+/fernando/abc3436_Data_file_S1/Data_file_S1/tif and lyr/CEZs.tif"
biomes_file <- "C:/Users/pedro/Dropbox/pesquisa/2020/rplus/heitor/2020-10-08-DadosParaHeitor/br_biomes.shp"

biomes <- sf::read_sf(biomes_file)
cez <- terra::rast(cez_file)

# CEZs Grid values: 3 = Level 1 CEZs; 2 = Level 2 CEZs; 1 = Level 3 CEZs; 0 = Other area 

require(magrittr)
biomes <- biomes %>% sf::st_transform(crs = terra::crs(cez))

protected_file <- "C:/Users/pedro/Dropbox/pesquisa/2021/r+/areas-protegidas/redd-pac/wfs_protectedareas.shp"

protected <- sf::read_sf(protected_file) %>%
  sf::st_transform(sf::st_crs(biomes))

sf::write_sf(protected, "protected-reproj.shp")

sf::write_sf(biomes, "biomes-reproj.shp")


biomes <- terra::vect("biomes-reproj.shp")
protected <- terra::vect("protected-reproj.shp")

cezunprot <- terra::crop(cez, biomes) %>%
  terra::mask(protected, inverse = TRUE, updatevalue = 5)

terra::writeRaster(cezunprot, "cez-unprot-3.tif")

result <- terra::as.polygons(cezunprot)

terra::writeVector(result, "CEZ-br-unprot.shp")

data <- sf::read_sf("CEZ-br-unprot.shp")
biomes <- sf::read_sf("biomes-reproj.shp")

for(i in 2:4){
  datai <- data[i,]

  for(j in 6:1){
    cat(paste0("Processing CEZ ", i, " biome ", j, "\n"))
    biomesj <- biomes[j,]
    
    intersec <- sf::st_intersection(datai, biomesj)

    sf::write_sf(intersec, paste0("CEZ-", i, "biome-", j, ".shp"))
  }
}

