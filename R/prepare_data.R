# prepare_data.R


# Project : map_reseau_cyclable_qc
# Author  : Jeremie Boudreault 
# Email   : JeremieBoudreault11@gmail.com
# Depends : R 3.6.3
# License : ---



# Libraries --------------------------------------------------------------------


library(leaflet)
library(rgdal)
library(rgeos)
library(sp)


# Imports ----------------------------------------------------------------------


lines_qc <- rgdal::readOGR(
  dsn       = file.path("data", "reseau_qc"),
  layer     = "vdq-reseaucyclable",
  use_iconv = TRUE,
  encoding  = "UTF-8"
)


# Check fields -----------------------------------------------------------------


# Dimension.
dim(lines_qc)

# Columns names.
names(lines_qc)

# Five first lines.
head(lines_qc@data)

# Unique <TYPE>.
table(lines_qc@data$TYPE, useNA = "always")

# Define a list with the correct names and IDS.
type_names <- list(
    PC = "Piste cyclable",
    BC = "Bande cyclable",
    CD = "Chaussée désignée"
)

# Create subclass --------------------------------------------------------------


# Pistes cyclables (PC).
lines_pc <- rgeos::gLineMerge(lines_qc[lines_qc$TYPE == type_names[["PC"]], ])

# Bandes cyclblaes (BC).
lines_bc <- rgeos::gLineMerge(lines_qc[lines_qc$TYPE == type_names[["BC"]], ])

# Chaussée désignée (CD).
lines_cd <- rgeos::gLineMerge(lines_qc[lines_qc$TYPE == type_names[["CD"]], ])


# Create the leaflet map -------------------------------------------------------


# Create the base map.
leaflet::leaflet() %>%
    
# Add a tile.
leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Voyager) %>%
    
# Add "Pistes Cyclables".
leaflet::addPolylines(
    data         = lines_pc,
    layerId      = type_names[["PC"]],
    group        = type_names[["PC"]],
    stroke       = TRUE,
    color        = "darkgreen",
    weight       = 3L,
    opacity      = 1L,
    dashArray    = NULL,
    smoothFactor = 1
) %>%

# Add the "Bandes cyclables".
leaflet::addPolylines(
    data         = lines_bc,
    layerId      = type_names[["BC"]],
    group        = type_names[["BC"]],
    stroke       = TRUE,
    color        = "green",
    weight       = 3L,
    opacity      = 1L,
    dashArray    = NULL,
    smoothFactor = 1
) %>%

# Add the "Chaussée Désignée".
leaflet::addPolylines(
    data         = lines_cd,
    layerId      = type_names[["CD"]],
    group        = type_names[["CD"]],
    stroke       = TRUE,
    color        = "green",
    weight       = 2.5,
    opacity      = 0.95,
    dashArray    = NULL,
    smoothFactor = 1
) %>%

# Add controls.
leaflet::addLayersControl(
    overlayGroups = unlist(type_names, use.names = FALSE),
    options       = layersControlOptions(collapse = FALSE)
)
