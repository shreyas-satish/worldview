root = this

class WorldView
  constructor: (@mapconfig) ->
    @map = new OpenLayers.Map(@mapconfig.mapid) 
    @map.addControl(new OpenLayers.Control.LayerSwitcher())
    @map.addLayers(WorldView.LayerDefinitions[layer].call(layer, options) for layer, options of @mapconfig.layers)
    @map.setCenter(WorldView.transformToMercator(@map, @mapconfig.lon, @mapconfig.lat), @mapconfig.zoom)

  setMapCenter: (lon, lat, zoom) ->
    @map.setCenter(WorldView.transformToMercator(@map, lon, lat), zoom)    

  @transformToMercator: (map, lon, lat) ->
    new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject())
  
  onPopupClose: (evt) => @featureControl.unselectAll()
  
class WorldView.VectorLayer

  constructor: (@map, name = "Vector Layer", options = {style: WorldView.Config.vectorMarkerStyle}) ->
    
    @vectorLayer = new OpenLayers.Layer.Vector(name, options)
    @map.addLayer(@vectorLayer)

  registerEventsOnVectorLayer: () ->
    featureControl = new OpenLayers.Control.SelectFeature(@vectorLayer)

    @vectorLayer.events.on({
      'featureselected':   this.onFeatureSelect,
      'featureunselected': this.onFeatureUnselect
    })

    @map.addControl(featureControl)        
    featureControl.activate()

  @initPopup: (feature) => new OpenLayers.Popup.FramedCloud("chicken", 
    feature.geometry.getBounds().getCenterLonLat(),
    new OpenLayers.Size(500,500),
    "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
    null, true, this.onPopupClose
  )

  initVectorMarker: (lon, lat, attributes = {}, style = WorldView.Config.vectorMarkerStyle) -> 
    lonLat = WorldView.transformToMercator(@map, lon, lat)
    feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style)
    feature

  
  addVectorMarker: (vectorMarkerOptions) ->
    feature = @initVectorMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat,
      vectorMarkerOptions.attributes, vectorMarkerOptions.style)
    @vectorLayer.addFeatures([feature])
    feature
  
  addVectorMarkers: (markersOptions) ->
    @registerEventsOnVectorLayer(@map) if markersOptions.events
    for point in markersOptions.points
      @addVectorMarker({
        lon: point.lon, lat: point.lat,
        style: markersOptions.style,
        attributes: {name: point.name, description: point.description}
      })


  onFeatureSelect: (event) ->
    feature = event.feature
    popup = WorldView.VectorLayer.initPopup(feature)
    feature.popup = popup
    @map.addPopup(popup)
      
  onFeatureUnselect: (event) =>
    feature = event.feature
    if feature.popup
      @map.removePopup(feature.popup)
      feature.popup.destroy()
      delete feature.popup



root.WorldView = WorldView