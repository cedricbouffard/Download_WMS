library(magrittr)
canada <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(name == "Canada") %>% sf::st_transform(4326)

bbox <- sf::st_bbox(canada) %>% as.numeric()
xmin <- bbox[1]
ymin <- bbox[2]
xmax <- bbox[3]
ymax <- bbox[4]

output = tempfile(fileext = ".tif")
system(noquote(paste0('gdalwarp -tr .01 .01 "',
  glue::glue("WMS:https://geo.weather.gc.ca/geomet?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX={ymin},{xmin},{ymax},{xmax}&CRS=EPSG:4326&LAYERS=RADAR_1KM_RRAI"),
  '" ',output
)))

image <- raster::brick(output)

