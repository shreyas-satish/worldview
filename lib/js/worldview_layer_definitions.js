
  WorldView.LayerDefinitions = {
    'OSM': function() {
      return new OpenLayers.Layer.OSM();
    },
    'Google Streets': function() {
      return new OpenLayers.Layer.Google("Google Streets", {
        numZoomLevels: 20
      });
    },
    'Google Physical': function() {
      return new OpenLayers.Layer.Google("Google Physical", {
        type: google.maps.MapTypeId.TERRAIN
      });
    },
    'Google Hybrid': function() {
      return new OpenLayers.Layer.Google("Google Hybrid", {
        type: google.maps.MapTypeId.HYBRID,
        numZoomLevels: 20
      });
    },
    'Google Satellite': function() {
      return new OpenLayers.Layer.Google("Google Satellite", {
        type: google.maps.MapTypeId.SATELLITE,
        numZoomLevels: 22
      });
    },
    'Yahoo': function() {
      return new OpenLayers.Layer.Yahoo("Yahoo");
    },
    'Bing Road': function(options) {
      return new OpenLayers.Layer.Bing({
        name: "Road",
        key: options.apiKey,
        type: "Road"
      });
    },
    'Bing Hybrid': function(options) {
      return new OpenLayers.Layer.Bing({
        name: "Hybrid",
        key: options.apiKey,
        type: "AerialWithLabels"
      });
    },
    'Bing Aerial': function(options) {
      return new OpenLayers.Layer.Bing({
        name: "Aerial",
        key: options.apiKey,
        type: "Aerial"
      });
    },
    'WMS': function() {
      return new OpenLayers.Layer.WMS("OpenLayers WMS", "http://vmap0.tiles.osgeo.org/wms/vmap0", {
        layers: 'basic'
      });
    }
  };
