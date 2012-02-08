class WorldView
  constructor: (@mapconfig) ->

    @map = new OpenLayers.Map(
      document.getElementById(@mapconfig.mapid), {
      theme: 'lib/css/map.css',
      projection: "EPSG:900913",
      numZoomLevels: 15,
      controls: []
      }
    )

    @mapID = @mapconfig.mapid

    @map.addControls([
      new OpenLayers.Control.Navigation(),
      new OpenLayers.Control.Attribution(),
      new OpenLayers.Control.PanZoomBar(),
      new OpenLayers.Control.LayerSwitcher()
    ])
    @map.addLayers(WorldView.LayerDefinitions[layer].call(layer, options) for layer, options of @mapconfig.layers)
    @map.setCenter(WorldView.transformToMercator(@map, @mapconfig.lon, @mapconfig.lat), @mapconfig.zoom)

  setMapCenter: (lon, lat, zoom) ->
    @map.setCenter(WorldView.transformToMercator(@map, lon, lat), zoom)    

  @transformToMercator: (map, lon, lat) ->
    new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject())
  
  onPopupClose: (evt) => @featureControl.unselectAll()

  initVectorLayer: ->
    new WorldView.VectorLayer(@map)

  initToolbar: (options) ->
    @initToolbarControls(options)
    @initToolbarDOM()
    
  initToolbarControls: (options) ->
    @controls =
      "point": @drawFeature(options.vectorLayer, OpenLayers.Handler.Point, options.callback)
      "line": @drawFeature(options.vectorLayer, OpenLayers.Handler.Path)
      "polygon": @drawFeature(options.vectorLayer, OpenLayers.Handler.Polygon, options.callback)
      "drag": new OpenLayers.Control.DragFeature(options.vectorLayer) 
    
    for key of @controls
      @map.addControl(@controls[key])
  
  initToolbarDOM: () ->
    div = OpenLayers.Util.createDiv(@map.id,null,null,null,"absolute",null,null,null)
    div.innerHTML = WorldView.Config.toolbarHTML
    mapDom = document.getElementById(@mapID)
    mapDom.insertBefore(div, mapDom.firstChild)

  drawFeature: (vectorLayer, handler, callback = -> alert "no callback") => 
    new OpenLayers.Control.DrawFeature(vectorLayer,
      handler,
      {'featureAdded': callback}
    )

  toggleControl: (element) ->
    for key of @controls
      control = @controls[key]
      if (element.value is key) or (element.title is key)# and element.checked
        control.activate()
      else
        control.deactivate()


  
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

  @initPopup: (feature) => 
    
    # popup = new OpenLayers.Popup("chicken",
    #                    feature.geometry.getBounds().getCenterLonLat(),
    #                    new OpenLayers.Size(100,100),
    #                    "example popup",
    #                    true)


    new OpenLayers.Popup.FramedCloud("popup-" + feature.attributes.name, 
      feature.geometry.getBounds().getCenterLonLat(),
      new OpenLayers.Size(500,500),
      "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
      null, true, this.onPopupClose
    )

  initMarker: (lon, lat, attributes = {}, style = WorldView.Config.vectorMarkerStyle) -> 
    lonLat = WorldView.transformToMercator(@map, lon, lat)
    feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style)
    feature

  
  addMarker: (vectorMarkerOptions) ->
    @registerEventsOnVectorLayer(@map) if vectorMarkerOptions.events
    feature = @initMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat,
      vectorMarkerOptions.attributes, vectorMarkerOptions.style)
    @addFeature(feature)
    feature
  
  addPolygon: (points) ->
    linear_ring = new OpenLayers.Geometry.LinearRing(points);
    feature = new OpenLayers.Feature.Vector(
      new OpenLayers.Geometry.Polygon([linear_ring]),
      null,
      {}
    )
    @addFeature(feature)
    feature

  addLine: (points) ->
    linefeature = new OpenLayers.Feature.Vector(
      new OpenLayers.Geometry.LineString(points),
      null,
      {}
    )
    @addFeature(feature)
    feature

  addCircle: (circleOptions) -> 
    circle = OpenLayers.Geometry.Polygon.createRegularPolygon(
      circleOptions.point,
      circleOptions.radius,
      20
    )
    feature = new OpenLayers.Feature.Vector(circle)
    @addFeature(feature)
    feature

  addFeature: (feature) ->
    @vectorLayer.addFeatures([feature])

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

WorldView.Config =
  lat: 0.0
  lon: 0.0
  size: new OpenLayers.Size(25, 25)
  icon_path: 'img/'

WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w/2), -WorldView.Config.size.h)

WorldView.Config.vectorMarkerStyle =
  externalGraphic: "http://openlayers.org/dev/img/marker.png",
  graphicHeight: 21,
  graphicWidth: 16,
  graphicOpacity: 1

# OpenLayers.ImgPath = 'http://openlayers.org/dev/img/'

OpenLayers.ImgPath = '/home/shreyas/dev/coffeescript/worldview/lib/img/'




WorldView.Config.toolbarHTML = 
  """
  <div id='wv-toolbar'>
    <ul id='controlToggle'>
      <li>
        <img src = 'lib/img/pan_on.png' value = 'none' onclick='world.toggleControl(this);' />
      </li>
      <li>
        <img src = "lib/img/add_point.png" name = "type" title = "point" id="pointToggle1" onclick="world.toggleControl(this);" />
      </li>
      <li>
        <img src = "lib/img/add_line.png" name = "type" title = "line" id="lineToggle1" onclick="world.toggleControl(this);" />
      </li>
      <li>
        <img src = "lib/img/add_polygon.png" name = "type" title = "polygon" id="polyToggle1" onclick="world.toggleControl(this);" />
      </li>

      <li>
        <img src = "lib/img/drag_feature.png" name = "type" title = "drag" id="dragToggle1" onclick="world.toggleControl(this);" />
      </li>
    </ul>
 </div>
 """

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

window.WorldView = WorldView
