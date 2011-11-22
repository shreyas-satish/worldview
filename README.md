# WorldView

WorldView is a little library on top of Openlayers that makes working with maps (through Openlayers of course) easy and consistent.

### Usage
###Initializing a worldview

```html
<!--Include the Oepnlayers js, worldview js and css. See index.html for example-->
<div id = 'worldview'></div>
```


```javascript

var myWorldView = new WorldView({
  mapid: 'worldview',
	lon: 77.6, lat: 12.655, 
	zoom: 10, 
	layers: {'Google Streets': {},
	         'OSM': {}
	}

});

```

`mapid`: The id of the div element containing the map

`lon` & `lat` : Map to be centered initially at a coordinates

`zoom`: Map's initial zoom level

`layers`: An Object literal to specify the default layers in the particular order. For all the possible layers see the worldview_layer_definitions.coffee or js file. Please note that, as of now, there's a problem with displaying Yahoo and WMS map layers, I'm looking into this. All other layer definitons work right.

###Initializing a Vector Layer and adding markers

```javascript
myWorldView.addVectorMarkers({
  lonLats: [{lon: 77.6, lat: 12.655}, {lon: 77.688, lat: 12.655}],
  vectorLayer: w.initVectorLayer("My Vector Layer")
});
```