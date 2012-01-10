WorldView.Config =
  lat: 0.0
  lon: 0.0
  size: new OpenLayers.Size(25, 25)
  icon_path: 'img/'

WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w/2), -WorldView.Config.size.h)


WorldView.Config.toolbarOptions =
  'point':
    handler: OpenLayers.Handler.Point
    id: "wv-toolbar-point"

  'line':
    handler: OpenLayers.Handler.Path
    id: "wv-toolbar-line"

  'polygon':
    handler: OpenLayers.Handler.Polygon
    id: "wv-toolbar-polygon"


WorldView.Config.vectorMarkerStyle =
  externalGraphic: "http://openlayers.org/dev/img/marker.png",
  graphicHeight: 21,
  graphicWidth: 16,
  graphicOpacity: 1

OpenLayers.ImgPath = 'http://openlayers.org/dev/img/'

WorldView.LayerDefinitions =
  'OSM': -> new OpenLayers.Layer.OSM()
  
  'Google Streets': -> new OpenLayers.Layer.Google("Google Streets", {numZoomLevels: 20})
  
  'Google Physical': -> new OpenLayers.Layer.Google("Google Physical",
    {type: google.maps.MapTypeId.TERRAIN}
  )
  
  'Google Hybrid': ->
    new OpenLayers.Layer.Google("Google Hybrid", {type: google.maps.MapTypeId.HYBRID, numZoomLevels: 20})
  
  'Google Satellite': -> new OpenLayers.Layer.Google("Google Satellite",
    {type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22}
  )

  'Yahoo': -> new OpenLayers.Layer.Yahoo("Yahoo")
  
  'Bing Road': (options) -> new OpenLayers.Layer.Bing({name: "Road", key: options.apiKey, type: "Road" })
  
  'Bing Hybrid': (options) -> new OpenLayers.Layer.Bing({name: "Hybrid", key: options.apiKey, type: "AerialWithLabels"})
  
  'Bing Aerial': (options) -> new OpenLayers.Layer.Bing({name: "Aerial", key: options.apiKey, type: "Aerial"})
  
  'WMS': -> new OpenLayers.Layer.WMS("OpenLayers WMS", "http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'})