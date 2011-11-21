root = this

class WorldView
  constructor: (@mapconfig) ->
    @map = new OpenLayers.Map(@mapconfig.mapid) 
    @map.addControl new OpenLayers.Control.LayerSwitcher()
    @map.addLayers(WorldView.LayerDefinitions[layer].call(layer, options) for layer, options of @mapconfig.layers)
    @map.setCenter(WorldView.transformToMercator(@map, @mapconfig.lon, @mapconfig.lat), @mapconfig.zoom)

  setMapCenter: (lon, lat, zoom) ->
    @map.setCenter(WorldView.transformToMercator(@map, lon, lat), zoom)    

  @transformToMercator: (map, lon, lat) ->
    new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject())
  
  initVectorMarker: (lon, lat, attributes = {}, style = WorldView.Config.vectorMarkerStyle) -> 
    lonLat = WorldView.transformToMercator(@map, lon, lat)
    feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style)
    feature
  
  addVectorMarker: (vectorMarkerOptions) ->
    feature = this.initVectorMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat,
      vectorMarkerOptions.attributes, vectorMarkerOptions.style)
    vectorMarkerOptions.vectorLayer.addFeatures([feature])
    feature
  
  addVectorMarkers: (markersOptions) ->
    for lonLat in markersOptions.lonLats
      this.addVectorMarker {lon: lonLat.lon, lat: lonLat.lat, vectorLayer: markersOptions.vectorLayer,
      style: markersOptions.style}

  initVectorLayer: (name = "Vector Layer", options = {style: WorldView.Config.vectorMarkerStyle}) ->
    vectorLayer = new OpenLayers.Layer.Vector(name, options);
    @map.addLayer vectorLayer
    vectorLayer

root.WorldView = WorldView

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


WorldView.Config =
  lat: 0.0
  lon: 0.0
  size: new OpenLayers.Size(25, 25)
  icon_path: 'img/'

WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w/2), -WorldView.Config.size.h)

WorldView.Config.vectorMarkerStyle =
  externalGraphic: "img/marker.png",
  graphicHeight: 21,
  graphicWidth: 16,
  graphicOpacity: 1  