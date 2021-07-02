# prepare_data.R


# Project : carte_reseau_cyclable_qc
# Author  : Jeremie Boudreault
# Email   : JeremieBoudreault11@gmail.com
# Depends : R (v3.6.3)
# License : ---



# Libraries --------------------------------------------------------------------


library(leaflet)
library(rgdal)
library(rgeos)
library(sp)


# Globals ----------------------------------------------------------------------


# Define a list with the correct names and IDS.
map_names <- list(
    RCE    = "Réseau cyclable estival",
    PC     = "Piste cyclable",
    BC     = "Bande cyclable",
    CD     = "Chaussée désignée",
    FUTUR  = "Améliorations 2021",
    WINTER = "Réseau 4 saisons",
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
lines_qc$WINTER[is.na(lines_qc$WINTER)] <-  "N"


# Add characteristics ----------------------------------------------------------


# Adjust size of the line.
lines_qc$LWD <- 0
lines_qc$LWD[lines_qc$TYPE == map_names["PC"]] <- 3
lines_qc$LWD[lines_qc$TYPE == map_names["BC"]] <- 2.5
lines_qc$LWD[lines_qc$TYPE == map_names["CD"]] <- 2.5


# Adjust color.
lines_qc$COL <- ""
lines_qc$COL[lines_qc$TYPE == map_names["PC"]] <- "darkgreen"
lines_qc$COL[lines_qc$TYPE == map_names["BC"]] <- "green"
lines_qc$COL[lines_qc$TYPE == map_names["CD"]] <- "green"


# Adjust dash.
lines_qc$DASH <- ""
lines_qc$DASH[lines_qc$TYPE == map_names["PC"]] <- ""
lines_qc$DASH[lines_qc$TYPE == map_names["BC"]] <- ""
lines_qc$DASH[lines_qc$TYPE == map_names["CD"]] <- "4"


# Extract <WINTER> and <FUTUR> -------------------------------------------------


# Réseau quatre saisons.
lines_winter <- lines_qc[lines_qc$WINTER == "Y", ]

# Amélioration au réseau.
lines_futur <- lines_qc[lines_qc$FUTUR == "Y", ]

# Remove amélioration au réseau.
lines_qc <- lines_qc[lines_qc$FUTUR != "Y", ]


# Create icons for road work ---------------------------------------------------


icons_rw <- leaflet::iconList(
    CLOSED  = leaflet::makeIcon(
        iconUrl     = file.path("www", "closed.png"),
        iconWidth   = 20L,
        iconHeight  = 20L,
        iconAnchorX = 8L,
        iconAnchorY = 8L
    ),
    WARNING = leaflet::makeIcon(
        iconUrl      = file.path("www", "warning.png"),
        iconWidth   = 20L,
        iconHeight  = 20L,
        iconAnchorX = 10L,
        iconAnchorY = 10L
    )
)


# Create the leaflet map -------------------------------------------------------


# Create the base map.
map <- leaflet::leaflet() %>%

# Add a tile.
leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Voyager) %>%

# Add "Reseau cyclable estival".
leaflet::addPolylines(
    data         = lines_qc,
    group        = map_names[["RCE"]],
    stroke       = TRUE,
    color        = ~COL,
    weight       = ~LWD,
    opacity      = 1L,
    dashArray    = ~DASH,
    smoothFactor = 1
) %>%

# Add the "Améliorations".
leaflet::addPolylines(
    data         = lines_futur,
    group        = map_names[["FUTUR"]],
    stroke       = TRUE,
    color        = "#EB5E28",
    weight       = ~LWD,
    opacity      = 0.95,
    dashArray    = ~DASH,
    smoothFactor = 1,
    #label        = ~DESC,
    #labelOptions = leaflet::labelOptions(noHide = TRUE, minZoom = 12L),
    popup        = ~DESC,
    popupOptions = leaflet::popupOptions(maxWidth = 200L)
) %>%

# Add the "Winter".
leaflet::addPolylines(
    data         = lines_winter,
    group        = map_names[["WINTER"]],
    stroke       = TRUE,
    color        = "#2E8DEC",
    weight       = ~LWD,
    opacity      = 0.95,
    dashArray    = NULL,
    smoothFactor = 1
) %>%

# Add the "Travaux".
leaflet::addMarkers(
    data        = road_work,
    group       = map_names[["RW"]],
    icon        = ~icons_rw[TYPE],
    popup       = ~DESC
) %>%

# Hide groups.
leaflet::hideGroup(
    group = unlist(map_names[c("FUTUR", "RW", "WINTER")], use.names = FALSE)
) %>%

# Add controls.
leaflet::addLayersControl(
    overlayGroups = unlist(
        x         = map_names[c("RCE", "WINTER", "FUTUR", "RW")],
        use.names = FALSE
    ),
    options       = layersControlOptions(collapse = FALSE)
)

# Add legend.
# leaflet::addLegend("bottomright",
#    colors = c("darkgreen", "darkgreen", "green"),
#    labels = unlist(map_names[c("PC", "BC", "CD")], use.names = FALSE),
#    group = map_names[["RCE"]]
#
# )

map


