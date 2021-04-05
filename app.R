# app.R


# Project : carte_reseau_cyclable_qc
# Author  : Jeremie Boudreault
# Email   : JeremieBoudreault11@gmail.com
# Depends : R (v3.6.3)
# License : ---



# Libraries --------------------------------------------------------------------


library(leaflet)
library(shiny)


# Load data --------------------------------------------------------------------


source(file.path("R", "prepare_data.R"))


# Server part of the app -------------------------------------------------------


server <- function(input, output) {

    output$leaflet_map <- leaflet::renderLeaflet(map)

}


# App --------------------------------------------------------------------------


shiny::shinyApp(
    server = server,
    ui     = shiny::fluidPage(
        leaflet::leafletOutput(
            outputId = "leaflet_map",
            height   = 700L
            )
    )
)


