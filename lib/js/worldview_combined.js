(function() {
  var WorldView, root;

  root = this;

  WorldView = (function() {

    function WorldView(mapconfig) {
      var layer, options;
      this.mapconfig = mapconfig;
      this.map = new OpenLayers.Map(this.mapconfig.mapid);
      this.map.addControl(new OpenLayers.Control.LayerSwitcher());
      this.map.addLayers((function() {
        var _ref, _results;
        _ref = this.mapconfig.layers;
        _results = [];
        for (layer in _ref) {
          options = _ref[layer];
          _results.push(WorldView.LayerDefinitions[layer].call(layer, options));
        }
        return _results;
      }).call(this));
      this.map.setCenter(WorldView.transformToMercator(this.map, this.mapconfig.lon, this.mapconfig.lat), this.mapconfig.zoom);
    }

    WorldView.prototype.setMapCenter = function(lon, lat, zoom) {
      return this.map.setCenter(WorldView.transformToMercator(this.map, lon, lat), zoom);
    };

    WorldView.transformToMercator = function(map, lon, lat) {
      return new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    };

    WorldView.prototype.initVectorMarker = function(lon, lat, attributes, style) {
      var feature, lonLat;
      if (attributes == null) attributes = {};
      if (style == null) style = WorldView.Config.vectorMarkerStyle;
      lonLat = WorldView.transformToMercator(this.map, lon, lat);
      feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style);
      return feature;
    };

    WorldView.prototype.addVectorMarker = function(vectorMarkerOptions) {
      var feature;
      feature = this.initVectorMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat, vectorMarkerOptions.attributes, vectorMarkerOptions.style);
      vectorMarkerOptions.vectorLayer.addFeatures([feature]);
      return feature;
    };

    WorldView.prototype.addVectorMarkers = function(markersOptions) {
      var lonLat, _i, _len, _ref, _results;
      _ref = markersOptions.lonLats;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lonLat = _ref[_i];
        _results.push(this.addVectorMarker({
          lon: lonLat.lon,
          lat: lonLat.lat,
          vectorLayer: markersOptions.vectorLayer,
          style: markersOptions.style
        }));
      }
      return _results;
    };

    WorldView.prototype.initVectorLayer = function(name, options) {
      var vectorLayer;
      if (name == null) name = "Vector Layer";
      if (options == null) {
        options = {
          style: WorldView.Config.vectorMarkerStyle
        };
      }
      vectorLayer = new OpenLayers.Layer.Vector(name, options);
      this.map.addLayer(vectorLayer);
      return vectorLayer;
    };

    return WorldView;

  })();

  root.WorldView = WorldView;

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

  WorldView.Config = {
    lat: 0.0,
    lon: 0.0,
    size: new OpenLayers.Size(25, 25),
    icon_path: 'img/'
  };

  WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w / 2), -WorldView.Config.size.h);

  WorldView.Config.vectorMarkerStyle = {
    externalGraphic: "img/marker.png",
    graphicHeight: 21,
    graphicWidth: 16,
    graphicOpacity: 1
  };

}).call(this);
