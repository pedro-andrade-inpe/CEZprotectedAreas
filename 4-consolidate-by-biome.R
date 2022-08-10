### AGGREGATE THE PIXELS INTO SIMU
### CREATES A CSV FILE WHERE EACH ROW CONTAINS THE NUMBER OF PIXELS OF A
### GIVEN TILE THAT OVERLAPS A GIVEN SIMU

require(magrittr)

biomes <- sf::read_sf("biomes-reproj.shp")

# THE CSV CREATED BY THE LAST SCRIPT
mcez <- read.table("result-unprotected-cez.csv", sep=",", header = FALSE)
names(mcez) <- c("ID", "quantity", "CEZlevel", "biome")

mcez$CEZlevel <- 5 - mcez$CEZlevel
mcez$biome <- biomes$name[mcez$biome]

units::install_unit("kha", "1e3ha")
units::install_unit("Mha", "1e6ha")

pixelToha <- function(value) units::set_units(value * 0.09, "ha")
pixelTokha <- function(value) units::set_units(pixelToHa(value), "kha")
pixelToMha <- function(value) units::set_units(pixelToHa(value), "Mha")

mcez <- mcez %>%
  dplyr::mutate(area = pixelToMha(quantity)) %>%
  dplyr::group_by(CEZlevel, biome) %>%
  dplyr::summarize(anthropizedAreaOutiseProtectedAreas = sum(area))


