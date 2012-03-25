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
      'Google Streets': {}
  },
  initialCoordinates: {
      lon: 77.6,
      lat: 12.655
  },
  initialZoom: 13
});

```

## Vector Layer

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

var vectorLayer = new WorldView.VectorLayer(w.map, {
    events: true,
	featureSelected: onFeatureSelect,
	featureUnselected: onFeatureUnselect,
});
```

### Drawing a Marker with a latitude/longitude pair

```javacript
vectorLayer.addMarker({
  lon: 77.55,
  lat: 12.55
});

```

### Drawing a Line with a list of latitude/longitude pairs

```javascript
var points = [
  {lon: 77.6, lat: 12.655},
  {lon: 77.688, lat: 12.655}
];

vectorLayer.addLine(points);
```

### Drawing a Polygon with a list of latitude/longitude pairs

```javascript
var points = [
  {lon: 77.6, lat: 12.655},
  {lon: 77.688, lat: 12.655},
  {lon:77.55, lat:12.55}
];

vectorLayer.addPolygon(points);
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

```javascript
worldview.initToolbar({
  vectorLayer: vectorLayer.vectorLayer,
  controls: {
    "navigate": {},
    "point": {},
    "line": {},
    "polygon": {}
  }
});

```
