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
    @initStyles()

  setMapCenter: (lon, lat, zoom) ->
    @map.setCenter(WorldView.transformToMercator(@map, lon, lat), zoom)    

  @transformToMercator: (map, lon, lat) ->
    new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject())
  
  @createOlPoint: (lon, lat) ->
    new OpenLayers.Geometry.Point(lon, lat)

  @transformPoint: (map, point) ->
    point.transform new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject()

  @createLonLat: (x, y) ->
    new OpenLayers.LonLat(x, y)

  # initVectorLayer: ()->
  #   new WorldView.VectorLayer(@map, options)

  initToolbar: (options) ->
    new WorldView.Toolbar(options, @map, @mapID)

  initStyles: () ->
    WorldView.Config.styleMap = new OpenLayers.StyleMap(
      "default": new OpenLayers.Style(
        strokeColor: "#ff0000"
        strokeOpacity: .7
        strokeWidth: 1
        fillColor: "#ff0000"
        fillOpacity: 0.5
        cursor: "pointer"
        externalGraphic: OpenLayers.ImgPath + "gv_marker.png"
        graphicHeight: 25,
        graphicWidth: 15,
        graphicOpacity: 1

      ),
      # "temporary": new OpenLayers.Style(
      #   strokeColor: "#ff0000"
      #   strokeOpacity: .7
      #   strokeWidth: 1
      #   fillColor: "#ff0000"
      #   fillOpacity: 0
      #   cursor: "pointer"
      #   # externalGraphic: OpenLayers.ImgPath + "marker.png"
      #   graphicHeight: 21,
      #   graphicWidth: 16,
      #   graphicOpacity: 1

      # ),
      "select": new OpenLayers.Style(
        strokeColor: "#0033ff",
        strokeOpacity: .7,
        strokeWidth: 2,
        fillColor: "#0033ff",
        fillOpacity: 0,
        graphicZIndex: 2,
        cursor: "move"
      )
    )

class WorldView.Toolbar

  constructor: (options, map, mapID) ->
    @map = map
    @mapID = mapID
    @toolbarID = @mapID + "-toolbar"
    @initToolbarDOM()
    @initToolbarControls(options, @map)

  initToolbarDOM: () ->
    div = OpenLayers.Util.createDiv(@toolbarID,null,null,null,"absolute",null,null,null)
    div.setAttribute("class","wv-toolbar")
    ul = document.createElement("ul")
    ul.setAttribute("id", @toolbarID + '-controlToggle')
    div.appendChild(ul)
    mapDom = document.getElementById(@mapID)
    mapDom.insertBefore(div, mapDom.firstChild)

  initToolbarControls: (options) ->
    vectorLayer = options.vectorLayer.vectorLayer

    @allToolbarItems =
      "navigate":
        id: @toolbarID + "-navigate"
        title: "navigate"
        img: "navigate.png"

      "point":
        id: @toolbarID + "-point"
        title: "point"
        img: "gv_marker.png"
        control: @drawFeature(vectorLayer, OpenLayers.Handler.Point)
      
      "line":
        id: @toolbarID + "-line"
        title: "line"
        img: "gv_drawline.png"
        control: @drawFeature(vectorLayer, OpenLayers.Handler.Path)

      "polygon":
        id: @toolbarID + "-polygon"
        title: "polygon"
        img: "gv_square.png"
        control: @drawFeature(vectorLayer, OpenLayers.Handler.Polygon)
      "drag":
        id: @toolbarID + "-drag"
        title: "drag"
        img: "gv_drag.png"
        control: new OpenLayers.Control.DragFeature(options.vectorLayer)

    @toolbarItems = {}
    if options.controls
      for control of options.controls
        @toolbarItems[control] = @allToolbarItems[control]
    else
      @toolbarItems = @allToolbarItems

    for item of @toolbarItems
      @createToolbarItem(item)
      @map.addControl(@toolbarItems[item].control) if @toolbarItems[item].control

  createToolbarItem: (item) ->
    item = @toolbarItems[item]
    li = document.createElement("li")
    im = document.createElement("img")
    im.setAttribute("src", OpenLayers.ImgPath + item.img)
    im.setAttribute("title", item.title)
    im.setAttribute("id", item.id)
    li.appendChild(im)
    document.getElementById(@toolbarID + '-controlToggle').appendChild(li)
    @registerEventListenersForToolbarItems(this, item.id) unless item.tc


  drawFeature: (vectorLayer, handler) => 
    new OpenLayers.Control.DrawFeature(vectorLayer,
      handler, {
        'featureAdded': @afterFeatureAdd
      }
    )

  afterFeatureAdd: (feature) =>
    @toggleControl({title: "navigate"})
    WorldView.Toolbar.featureAdded(feature) if WorldView.Toolbar.featureAdded

    
  registerEventListenersForToolbarItems: (obj, id) ->
    el = document.getElementById(id)
    el.addEventListener "click", (->
      obj.toggleControl(el)
    ), false

  toggleControl: (element) =>
    for item of @toolbarItems
      control = @toolbarItems[item].control
      if control and ((element.value is item) or (element.title is item))
        control.activate()
      else if control
        control.deactivate()

class WorldView.VectorLayer

  constructor: (@map, options = {events: false}, olOptions = {styleMap: WorldView.Config.styleMap}) ->
   
    @vectorLayer = new OpenLayers.Layer.Vector(name || "Vector Layer", olOptions)
    @registerEventsOnVectorLayer(options) if options.events
    @map.addLayer(@vectorLayer)

  registerEventsOnVectorLayer: (options) ->
    featureControl = new OpenLayers.Control.SelectFeature(@vectorLayer)

    @vectorLayer.events.on({
      'featureselected':   options.featureSelected,
      'featureunselected': options.featureUnselected
    })

    @map.addControl(featureControl)        
    featureControl.activate()

  # POPUPS

  @initPopup: (feature, content, width, height) => 
    OpenLayers.Popup.FramedCloud::autoSize = false
    
    new OpenLayers.Popup.FramedCloud("popup-" + feature.id, 
      feature.geometry.getBounds().getCenterLonLat(),
      new OpenLayers.Size(width,height),
      content,
      null, true, this.onPopupClose
    )

  addPopup: (options) ->
    popup = WorldView.VectorLayer.initPopup(options.feature, options.content || "", options.width || 200, options.height || 200)
    options.feature.popup = popup
    @map.addPopup(popup)
    popup

  removePopup: (feature) ->
    if feature.popup
      @map.removePopup(feature.popup)
      feature.popup.destroy()
      delete feature.popup


  onPopupClose: (evt) => @featureControl.unselectAll()
  
  # FEATURES

  initMarker: (lon, lat, attributes = {}, style = WorldView.Config.vectorMarkerStyle, transform = true) -> 
    if transform == true
      lonLat = WorldView.transformToMercator(@map, lon, lat)
    else
      lonLat = WorldView.createLonLat(lon, lat)
   
    feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style)
    feature

  
  addMarker: (vectorMarkerOptions) ->
    feature = @initMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat,
      vectorMarkerOptions.attributes, vectorMarkerOptions.style, vectorMarkerOptions.transform)
    @addFeature(feature)
    feature
  
  generatePoints: (pointsOptions) ->
    points = []
    for i of pointsOptions
      points.push WorldView.transformPoint(@map, WorldView.createOlPoint(pointsOptions[i].lon, pointsOptions[i].lat))
    points

  addPolygon: (options) ->
    points = @generatePoints(options.points)
    linear_ring = new OpenLayers.Geometry.LinearRing(points);
    feature = new OpenLayers.Feature.Vector(
      new OpenLayers.Geometry.Polygon([linear_ring]),
      null,
      options.style || {}
    )
    @addFeature(feature)
    feature

  
  addFeatureFromGeometry: (geometry, bounds) ->
    options =
      internalProjection: new OpenLayers.Projection("EPSG:4326")
      externalProjection: new OpenLayers.Projection("EPSG:4326")

    @addFeature new OpenLayers.Format.WKT(options).read(geometry)
    @map.zoomToExtent(bounds) if bounds

  addLine: (options) ->
    points = @generatePoints(options.points)
    feature = new OpenLayers.Feature.Vector(
      new OpenLayers.Geometry.LineString(points),
      null,
      options.style || {}
    )
    @addFeature(feature)
    feature

  addCircle: (circleOptions) -> 
    point = WorldView.transformPoint(@map, WorldView.createOlPoint(circleOptions.lon, circleOptions.lat))
    circle = OpenLayers.Geometry.Polygon.createRegularPolygon(
      point,
      circleOptions.radius,
      20
    )
    feature = new OpenLayers.Feature.Vector(
      circle,
      null,
      circleOptions.style || {}
    )
    @addFeature(feature)
    feature

  addFeature: (feature) ->
    @vectorLayer.addFeatures([feature])

# WorldView Configuration 

WorldView.Config =
  lat: 0.0
  lon: 0.0
  size: (w = 25, h = 25) -> new OpenLayers.Size(w, h)
  

WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w/2), -WorldView.Config.size.h)

WorldView.Config.vectorMarkerStyle =
  externalGraphic: "gv_marker.png",
  graphicHeight: 21,
  graphicWidth: 16,
  graphicOpacity: 1


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
