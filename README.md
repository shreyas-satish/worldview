# WorldView

WorldView provides an abstraction over OpenLayers with a set of clear & consistent APIs that allows you to perform common usecases with maps. 

UseCases

1. Displaying a basic map. You can choose between Google, Bing, OSM & so on, basically whatever OpenLayers supports.
2. Showing markers, polygons, lines on the map, with customizable callbacks.
3. Adding interaction to a map with a toolbar which allows you to dynamically add/move markers, polygons, lines etc

worldview.js objects wrap openlayers objects. A corollary would mean, if you aren't able able to perform a case that is not supported natively by worldview.js, worldview.js objects give you access to OpenLayers objects using which you can perform operations that are possible using OpenLayers.

## Creating a WorldView

``` javascript
var worldview = new WorldView({ 
  mapid: 'map',
  imagesPath: "/path/to/images/",
  cssPath: "/path/to/map.css",

  layers: {
      'OSM': {},
      'Google Streets': {},
      'Bing Road': {apiKey = yourApiKey}
  },
  initialCoordinates: {
      lon: 77.6,
      lat: 12.655
  },
  initialZoom: 13
});

```
The worldview object created wraps the OpenLayers.Map.OpenLayers.Class.initialize object and can be accessed by 

```javascript
  worldview.map
```

The first layer in the layers object will be shown by default.


## Vector Layer

The Vector Layer is overlayed on the base map and is primarily used to display vector features such as markers, lines, polygons and circles.

### Initialization

```javascript
// Custom callback for when a feature is selected
var onFeatureSelect = function(event) {
  alert("Feature " + event.feature.geometry + " selected")
}

// Custom callback for when a feature is unselected
var onFeatureUnselect = function(event) {
  alert("Feature " + event.feature.geometry + " unselected")
}

var vectorLayer = new WorldView.VectorLayer(worldview.map, {
  events: true,
	featureSelected: onFeatureSelect,
	featureUnselected: onFeatureUnselect,
});
```

The vectorLayer object created here creates a OpenLayers.Layer.Vector object and is accessible by

```javascript
  ol_vectorLayer = vectorLayer.vectorLayer;
```

The onFeatureSelect and onFeatureUnselect callbacks are optional. The callback receives the defualt OpenLayers event object as the parameter. Importantly, to access the feature that fired the callback ;

```javascript
  feature = event.feature;
```

The feature is a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.


### Drawing a Marker with a latitude/longitude pair

The default values are indicated in the comments.

```javacript
var marker = vectorLayer.addMarker({
  lon: points[i].lon,
  lat: points[i].lat,
  style: {
     externalGraphic: "img/marker.png", // "img/marker.png"
     graphicHeight: 25,  // 25
     graphicWidth: 15,   // 15
     graphicOpacity: 1.0 // 1.0
  }
});

```

This function returns a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.

### Drawing a Line with a list of latitude/longitude pairs

```javascript
var points = [
  {lon: 77.6, lat: 12.655},
  {lon: 77.688, lat: 12.655}
];

var linef = vectorLayer.addLine({
  points: points,
  style: {
    strokeColor: "#ff0000", // "#ff0000"
    strokeOpacity: 1.0      // 0.7
  }
});

```

### Drawing a Polygon with a list of latitude/longitude pairs

```javascript
var points = [
  {lon: 77.6, lat: 12.655},
  {lon: 77.688, lat: 12.655},
  {lon:77.55, lat:12.55}
];

var polygon = vectorLayer.addPolygon({
  points: points,
  style: {
    strokeColor: "#ff0000", // "#ff0000"
    strokeOpacity: 1.0,     // 1.0
    fillColor: "#ff0000",   // "#ff0000"
    fillOpacity: 0.5        // 0.5
  }
});

```

### Drawing a Circle with a latitude/longitude pair and a radius

```javascript
var lon = 77.6, lat = 12.655, radius = 10000;

vectorLayer.addCircle({
  lon: lon,
  lat: lat,
  radius: radius,
  style: {
    strokeColor: "#ff0000", // "#ff0000"       
    strokeOpacity: 1.0,     // 1.0
    fillColor: "#0000ff",   // "#0000ff"
    fillOpacity: 0.5        // 0.5
  }
});

```

### Attaching a Popup to a feature

```javascript
var popContent = "<div style='color:red;margin-top:20px;'>I'm a popup</div>";

var pop = vectorLayer.addPopup({
  feature: fm,
  content: popContent,
  width: 300,
  height: 300
});
```

### Drawing a Line from a geometry and bounds

```javascript
var line_geom = "LINESTRING(8644765.421588 1420984.1257934,8638382.9297271 1418920.32603)";
var line_bounds = [8638382.9297271,1418920.32603,8644765.421588,1420984.1257934];
vectorLayer.addFeatureFromGeometry(lineGeom, lineBounds); // lineBounds is optional
```

### Drawing a Polygon from a geometry and bounds

```javascript
var polygonGeom = "POLYGON((8631656.4712389 1424118.0439527,8643007.3699377 1423124.3625851,8632917.6822054 1418633.687174,8631656.4712389 1424118.0439527))";
var polygonBounds = [8641249.3182874,1418499.9223745,8644746.3123309,1420085.9907112];
vectorLayer.addFeatureFromGeometry(polygonGeom, polygonBounds); // polygonBounds is optional

```

## The Toolbar

The Toolbar is native to WorldView, in that, it does not wrap any OpenLayers object. This Toolbar is configurable. You can decide which controls you need in the toolbar & the styling that needs to be applied. 

To initialize the toolbar, you need to first create a vector layer (as illustrated above).

```javascript
worldview.initToolbar({
  vectorLayer: vectorLayer,
  controls: {
    "navigate": {},
    "point": {},
    "line": {},
    "polygon": {}
  }
});

```

You can also register a callback that needs to be fired when a feature (point, line, polygon) is added to the map with toolbar.

```javascript
WorldView.Toolbar.featureAdded = function(feature) {
  console.log(feature.geometry);
}
```

