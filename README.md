# WorldView

WorldView is an easier way to use <a href = "http://openlayers.org" target="_blank">OpenLayers</a>. It comes with a set of easy-to-use APIs and a configurable Drawing Toolbar. 

A few use cases supported out of the box :

1. Display a basic map. You can choose between Google, Bing, OSM & so on, basically whatever OpenLayers supports.
2. Show features such as markers, lines, polygons, circles on the map, with customizable callbacks and popups.
3. Add interaction to a map with an drawing toolbar which allows you to dynamically add/move markers, lines and polygons. You also get to register a callback when a feature (marker, line or polygon) is added.

See a <a href = 'http://shreyas-satish.github.com/worldview/demo' target="_blank">demo</a>.

WorldView wraps OpenLayers objects where a wrapper makes sense, in that you would have access to the underlying OpenLayers object. Other times, it returns OpenLayers objects. The idea is, if you aren't able to perform a case that is not supported natively by WorldView, WorldView objects give you access to OpenLayers objects (by wrapping or returning them), using which you can perform cases that _are_ possible using OpenLayers.

## Installing WorldView

Download the OpenLayers.js file from vendor/ and the worldview.js from lib/ into your app's javascripts folder.

Ensure you include the OpenLayers.js _before_ the worldview.js file.

Eg: 

```html
  <script src="vendor/OpenLayers.js"></script>
  <script src="lib/worldview.js"></script>
```


Download the img/ folder. You're free to rename this folder if you want.

Download the map.css. Make sure you grep through this file and change the image paths appropriately (Not to worry, there aren't many).


## Creating a WorldView

``` javascript
var worldview = new WorldView({ 
  mapid: 'map',
  imagesPath: "/path/to/images/",
  cssPath: "/path/to/map.css",
  
  layers: {
      'OSM': {},
      'Google Streets': {},
  },
  initialCoordinates: {
      lon: 77.6,
      lat: 12.655
  },
  numZoomLevels: 16 // 15,
  initialZoom: 13,
});

```

The first layer in the layers object, in this case OpenStreetMap, will be shown by default.

The worldview object created, wraps the [OpenLayers.Map](http://dev.openlayers.org/docs/files/OpenLayers/Map-js.html) object and can be accessed :

```javascript
  var olMap = worldview.map;
```

## Vector Layer

The Vector Layer is overlayed on the base map and is primarily used to display vector features such as markers, lines, polygons and circles.

### Initialization

```javascript
// Custom callback for when a feature is selected
var onFeatureSelect = function(event) {
  console.log("Feature " + event.feature.geometry + " selected")
}

// Custom callback for when a feature is unselected
var onFeatureUnselect = function(event) {
  console.log("Feature " + event.feature.geometry + " unselected")
}

var myVectorLayer = new WorldView.VectorLayer(worldview.map, {
  events: true,
  featureSelected: onFeatureSelect,
  featureUnselected: onFeatureUnselect,
});
```

The vectorLayer object created here wraps the OpenLayers.Layer.Vector object and is accessible :

```javascript
  var olVectorLayer = myVectorLayer.vectorLayer;
```

The onFeatureSelect and onFeatureUnselect callbacks are optional. The callback receives the default OpenLayers event object as the parameter. Importantly, to access the feature that fired the callback ;

```javascript
  var feature = event.feature;
```

feature here is a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.


### Drawing a Marker with a latitude/longitude pair

The default values are indicated in the comments.

```javacript
var lon = 77.6, lat = 12.655;

var marker = vectorLayer.addMarker({
  lon: lon,
  lat: lat,
  style: {
     externalGraphic: "img/marker.png", // "img/marker.png"
     graphicHeight: 25,  // 25
     graphicWidth: 15,   // 15
     graphicOpacity: 1.0 // 1.0
  },
  attributes : {  // an optional attributes object accessible by the respective feature
    locationName: "CERN"
  }
});

```

This method returns a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.

The attributes object is an optional object which you could pass into the addMarker method to store some information that you would need access to later, for instance, to show the name of the location when a marker is selected.

### Drawing a Line with a list of latitude/longitude pairs

```javascript
var points = [
  {lon: 77.6, lat: 12.655},
  {lon: 77.688, lat: 12.655}
];

var line = vectorLayer.addLine({
  points: points,
  style: {
    strokeColor: "#ff0000", // "#ff0000"
    strokeOpacity: 1.0      // 0.7
  }
});

```

This method returns a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.

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

This method returns a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.

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

This method returns a [OpenLayers.Feature.Vector](http://dev.openlayers.org/docs/files/OpenLayers/Feature/Vector-js.html) object.

### Attaching a Popup to a feature

Popups can be either added in an adhoc fashion to vector features or be registered in the feature callbacks (For instance, shown when selected, hidden when un-selected). 

The popContent defined below can be any HTML content. Ensure you strip out any potentially dangerous tags from the HTML.

```javascript

var markerWithPopup = vectorLayer.addMarker({
  lon: lon,
  lat: lat,
)};

var popContent = "<div style='color:red;margin-top:20px;'>I'm a popup</div>";

var pop = vectorLayer.addPopup({
  feature: markerWithPopup,
  content: popContent,
  width: 300,
  height: 300
});
```

The addPopup method returns a [OpenLayers.Popup.FramedCloud](http://dev.openlayers.org/releases/OpenLayers-2.6/doc/apidocs/files/OpenLayers/Popup/FramedCloud-js.html) object.

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

To initialize the toolbar, you need to first create a vector layer (as illustrated earlier).

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

## A note on CoffeeScript

This library has been written using <a href="http://coffeescript.org" target="_blank">CoffeeScript (v 1.2.0)</a>. However, you DO NOT need to use CoffeeScript to use this library, I've included the worldview.js file. 

I chose to write WorldView in CoffeeScript, because I loved the fact that by writing in CoffeeScript, I was automatically writing <a href = "http://www.amazon.com/JavaScript-Good-Parts-Douglas-Crockford/dp/0596517742" target = "_blank">good JavaScript</a> whilst not having to worry about the usual WTFs and with a sweet syntax. Debugging wasn't a problem at all since the JavaScript generated by CoffeeScript is very human read-able. When Source Maps become available, debugging CoffeeScript will be even easier.

I understand the fact that some people have an aversion to CoffeeScript, hence I'd welcome contributions to this library in either CoffeeScript or JavaScript. If contributions _are_ in JavaScript, either someone kind or myself will port the changes to the CoffeeScript source. 

## Version

1.0.0