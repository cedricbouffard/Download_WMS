canada <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(name == "Canada")

bbox <- sf::st_bbox(canada) %>% as.numeric()
xmin <- bbox[1]
ymin <- bbox[2]
xmax <- bbox[3]
ymax <- bbox[4]
date <- "2022-06-05"
hour1 <- "12:00:00"
hour2 <- "15:00:00"

image <- curl::curl_download(
  url = glue::glue("https://geo.weather.gc.ca/geomet?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX={ymin},{xmin},{ymax},{xmax}&CRS=EPSG:4326&WIDTH=2400&HEIGHT=2400&LAYERS=RADAR_1KM_RRAI&FORMAT=image/png&timeDimensionExtent={date}T{hour1}Z/{date}T{hour2}Z"),
  destfile = tempfile(fileext = ".png")
)

raster_img <- raster::brick(image, crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
raster::extent(raster_img) <- raster::extent(c(xmin, xmax, ymin, ymax))
raster::writeRaster(raster_img, "test.tif")
