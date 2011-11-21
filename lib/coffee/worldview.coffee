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