class WorldView
  constructor: (@mapconfig) ->

    @map = new OpenLayers.Map(
      document.getElementById(@mapconfig.mapid), {
      theme: @mapconfig.cssPath,
      projection: "EPSG:900913",
      numZoomLevels: 15,
      controls: []
      }
    )

    OpenLayers.ImgPath = @mapconfig.imagesPath || 'http://openlayers.org/dev/img/'

    @mapID = @mapconfig.mapid

    @map.addControls([
      new OpenLayers.Control.Navigation(),
      new OpenLayers.Control.Attribution(),
      new OpenLayers.Control.PanZoomBar(),
      new OpenLayers.Control.LayerSwitcher()
    ])
    @map.addLayers(WorldView.LayerDefinitions[layer].call(layer, options) for layer, options of @mapconfig.layers)
    @map.setCenter(WorldView.transformToMercator(@map, @mapconfig.initialCoordinates.lon, @mapconfig.initialCoordinates.lat), @mapconfig.initialZoom)

  setMapCenter: (lon, lat, zoom) ->
    @map.setCenter(WorldView.transformToMercator(@map, lon, lat), zoom)    

  @transformToMercator: (map, lon, lat) ->
    new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject())
  
  onPopupClose: (evt) => @featureControl.unselectAll()

  initVectorLayer: ->
    new WorldView.VectorLayer(@map)

  initToolbar: (options) ->
    new WorldView.Toolbar(options, @map, @mapID)
  
class WorldView.Toolbar

  constructor: (options, map, mapID) ->
    @map = map
    @mapID = mapID
    @initToolbarDOM()
    @initToolbarControls(options, @map)

  initToolbarDOM: () ->
    div = OpenLayers.Util.createDiv("wv-toolbar",null,null,null,"absolute",null,null,null)
    ul = document.createElement("ul")
    ul.setAttribute("id", 'controlToggle')
    div.appendChild(ul)
    mapDom = document.getElementById(@mapID)
    mapDom.insertBefore(div, mapDom.firstChild)

  initToolbarControls: (options) ->
    @toolbarItems =
      # "navigate":
      #   id: "navigate"
      #   value: "none"
      #   img: "pan_on.png"

      "point":
        id: "point"
        title: "point"
        img: "marker_rounded_violet.png"
        control: @drawFeature(options.vectorLayer, OpenLayers.Handler.Point, options.callback)
      
      "line":
        id: "line"
        title: "line"
        img: "draw_line.png"
        control: @drawFeature(options.vectorLayer, OpenLayers.Handler.Path, options.callback)

      "polygon":
        id: "polygon"
        title: "polygon"
        img: "add_polygon.png"
        control: @drawFeature(options.vectorLayer, OpenLayers.Handler.Polygon, options.callback)

      "drag":
        id: "drag"
        title: "drag"
        img: "drag_feature.png"
        control: new OpenLayers.Control.DragFeature(options.vectorLayer) 
    
    
    @createToolbarItem(navigate_button)

    for item of @toolbarItems
      @createToolbarItem(item)
      @map.addControl(@toolbarItems[item].control)
  
  createToolbarItem: (item) ->
    item = @toolbarItems[item]
    li = document.createElement("li")
    im = document.createElement("img")
    im.setAttribute("src", OpenLayers.ImgPath + item.img)
    im.setAttribute("title", item.title)
    im.setAttribute("id", item.id)
    li.appendChild(im)
    document.getElementById('controlToggle').appendChild(li)
    @registerEventListenersForToolbarItems(this, item.id)


  drawFeature: (vectorLayer, handler, callback = -> alert "no callback") => 
    new OpenLayers.Control.DrawFeature(vectorLayer,
      handler,
      {'featureAdded': callback}
    )

    
  registerEventListenersForToolbarItems: (obj, id) ->
    el = document.getElementById(id)
    el.addEventListener "click", (->
      obj.toggleControl(el)
    ), false

  toggleControl: (element) ->
    for item of @toolbarItems
      control = @toolbarItems[item].control
      if control and ((element.value is item) or (element.title is item))
        control.activate()
      else
        control.deactivate()


  
class WorldView.VectorLayer

  constructor: (@map, name = "Vector Layer", options = {styleMap: WorldView.Config.styleMap}) ->
   
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
  size: (w = 25, h = 25) -> new OpenLayers.Size(w, h)
  

WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w/2), -WorldView.Config.size.h)

WorldView.Config.vectorMarkerStyle =
  externalGraphic: "http://openlayers.org/dev/img/marker.png",
  graphicHeight: 21,
  graphicWidth: 16,
  graphicOpacity: 1


WorldView.Config.styleMap = new OpenLayers.StyleMap(
  "default": new OpenLayers.Style(
    strokeColor: "#ff0000"
    strokeOpacity: .7
    strokeWidth: 1
    fillColor: "#ff0000"
    fillOpacity: 0
    cursor: "pointer"
  ),
  "select": new OpenLayers.Style(
    strokeColor: "#0033ff",
    strokeOpacity: .7,
    strokeWidth: 2,
    fillColor: "#0033ff",
    fillOpacity: 0,
    graphicZIndex: 2,
    cursor: "pointer"
  )
)


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
