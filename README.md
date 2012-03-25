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
