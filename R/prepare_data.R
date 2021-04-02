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


# Globals ----------------------------------------------------------------------


# Define a list with the correct names and IDS.
map_names <- list(
    PC     = "Piste cyclable",
    BC     = "Bande cyclable",
    CD     = "Chaussée désignée",
    FUTUR  = "Améliorations 2021",
    RW     = "Travaux routiers"
)


# Imports ----------------------------------------------------------------------


# Quebec city cycle network.
lines_qc <- rgdal::readOGR(
  dsn              = file.path("data", "reseau_qc"),
  layer            = "vdq-reseaucyclable",
  use_iconv        = TRUE,
  encoding         = "UTF-8",
  stringsAsFactors = FALSE
)

# Quebec city road work.
road_work <- rgdal::readOGR(
    dsn              = file.path("data", "travaux"),
    layer            = "travaux",
    use_iconv        = TRUE,
    encoding         = "UTF-8",
    stringsAsFactors = FALSE
)


# Quebec city cycle network ----------------------------------------------------


# Dimension.
dim(lines_qc)

# Columns names.
names(lines_qc)

# Five first lines.
head(lines_qc@data)

# Unique <TYPE>.
table(lines_qc@data$TYPE, useNA = "always")

# Replaces NAs by "N".
lines_qc$FUTUR[is.na(lines_qc$FUTUR)]   <-  "N"


# Split into multiple polygons -------------------------------------------------


# Pistes cyclables (PC).
lines_pc <- rgeos::gLineMerge(lines_qc[
    lines_qc$TYPE   == map_names[["PC"]] &
    lines_qc$FUTUR  != "Y"
, ])

# Bandes cyclablaes (BC).
lines_bc <- rgeos::gLineMerge(lines_qc[
    lines_qc$TYPE   == map_names[["BC"]] &
    lines_qc$FUTUR  != "Y"
, ])

# Chaussée désignée (CD).
lines_cd <- rgeos::gLineMerge(lines_qc[
    lines_qc$TYPE   == map_names[["CD"]] &
    lines_qc$FUTUR  != "Y"
, ])

# Amélioration au réseau.
lines_futur <- lines_qc[lines_qc$FUTUR == "Y", ]


# Define palette for Road Work -------------------------------------------------


pal_rw <- leaflet::colorFactor(
    palette = c("red", "yellow"),
    domain  = c("WARNING", "CLOSED")
)


# Create the leaflet map -------------------------------------------------------


# Create the base map.
leaflet::leaflet() %>%
    
# Add a tile.
leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Voyager) %>%
    
# Add "Pistes Cyclables".
leaflet::addPolylines(
    data         = lines_pc,
    layerId      = map_names[["PC"]],
    group        = map_names[["PC"]],
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
    layerId      = map_names[["BC"]],
    group        = map_names[["BC"]],
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
    group        = map_names[["CD"]],
    stroke       = TRUE,
    color        = "green",
    weight       = 2.5,
    opacity      = 0.95,
    dashArray    = NULL,
    smoothFactor = 1
) %>%
    
# Add the "Améliorations".
leaflet::addPolylines(
    data         = lines_futur,
    group        = map_names[["FUTUR"]],
    stroke       = TRUE,
    color        = "#2E8DEC",
    weight       = 2.5,
    opacity      = 0.95,
    dashArray    = NULL,
    smoothFactor = 1,
    popup        = ~DESC
) %>%
    
# Add the "Travaux".
leaflet::addCircleMarkers(
    data        = road_work,
    group       = map_names[["RW"]],
    radius      = 5L,
    stroke      = TRUE,
    weight      = 2,
    color       = "black",
    opacity     = 1L,
    fillColor   = ~pal_rw(TYPE),
    fillOpacity = 1L,
    popup       = ~DESC
) %>%
    
# Hide groups.
leaflet::hideGroup(
    group = c(map_names[["FUTUR"]], map_names[["RW"]])
) %>%

# Add controls.
leaflet::addLayersControl(
    overlayGroups = unlist(map_names, use.names = FALSE),
    options       = layersControlOptions(collapse = FALSE)
)
    