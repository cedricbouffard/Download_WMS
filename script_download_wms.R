library(magrittr)
library(dplyr)
canada <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(name == "Canada") %>% sf::st_transform(4326)

bbox <- sf::st_bbox(canada) %>% as.numeric()
xmin <- bbox[1]
ymin <- bbox[2]
xmax <- bbox[3]
ymax <- bbox[4]
date <- "2022-06-06"
hour <- "20:40:00"

date =tidyr::crossing(jour = format(c(lubridate::today(tzone = 'UTC'), lubridate::today(tzone = 'UTC')-1), '%Y-%m-%d'),
                      heure = formatC(0:23, width = 2, format = "d", flag = "0"),
                      minute = formatC(seq(0,50, by = 10), width = 2, format = "d", flag = "0")) %>%
  mutate(date_chr = paste0(jour,'T', heure,':', minute,':00')) %>% 
  mutate(date = lubridate::as_datetime(date_chr, tz='UTC')) %>%
  filter(date>= lubridate::now(tzone = 'UTC')-lubridate::hours(3) & date <= lubridate::now(tzone = 'UTC'))

dwnld = function(x,bbox){
  xmin <- bbox[1]
  ymin <- bbox[2]
  xmax <- bbox[3]
  ymax <- bbox[4]
  output = tempfile(fileext = ".tif")
  system(noquote(paste0('gdalwarp -tr .01 .01 "',
                        glue::glue("WMS:https://geo.weather.gc.ca/geomet?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX={ymin},{xmin},{ymax},{xmax}&CRS=EPSG:4326&LAYERS=RADAR_1KM_RRAI&TIME={x}Z"),
                        '" ',output
  )))
  
  return(output)
  
}

liste_image = purrr::pmap(.l = list(x =date$date_chr),
            .f = dwnld,
            bbox = bbox)

r=raster::brick(liste_image[1])