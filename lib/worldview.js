(function() {
  var WorldView;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  WorldView = (function() {
    function WorldView(mapconfig) {
      var layer, options;
      this.mapconfig = mapconfig;
      this.map = new OpenLayers.Map(document.getElementById(this.mapconfig.mapid), {
        theme: this.mapconfig.cssPath,
        projection: this.mapconfig.projection || "EPSG:900913",
        numZoomLevels: this.mapconfig.numZoomLevels || 15,
        controls: []
      });
      OpenLayers.ImgPath = this.mapconfig.imagesPath || 'http://openlayers.org/dev/img/';
      this.mapID = this.mapconfig.mapid;
      this.map.addControls([new OpenLayers.Control.Navigation(), new OpenLayers.Control.Attribution(), new OpenLayers.Control.PanZoomBar(), new OpenLayers.Control.LayerSwitcher()]);
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
      this.map.setCenter(WorldView.transformToMercator(this.map, this.mapconfig.initialCoordinates.lon, this.mapconfig.initialCoordinates.lat), this.mapconfig.initialZoom);
      this.initStyles();
    }
    WorldView.prototype.setMapCenter = function(lon, lat, zoom, transform) {
      if (transform == null) {
        transform = true;
      }
      if (transform === true) {
        return this.map.setCenter(WorldView.transformToMercator(this.map, lon, lat), zoom);
      } else {
        return this.map.setCenter(WorldView.createLonLat(lon, lat), zoom);
      }
    };
    WorldView.transformToMercator = function(map, lon, lat) {
      return new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    };
    WorldView.createOlPoint = function(lon, lat) {
      return new OpenLayers.Geometry.Point(lon, lat);
    };
    WorldView.transformPoint = function(map, point) {
      return point.transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    };
    WorldView.createLonLat = function(x, y) {
      return new OpenLayers.LonLat(x, y);
    };
    WorldView.prototype.initToolbar = function(options) {
      return new WorldView.Toolbar(options, this.map, this.mapID);
    };
    WorldView.prototype.initStyles = function() {
      return WorldView.Config.styleMap = new OpenLayers.StyleMap({
        "default": new OpenLayers.Style({
          strokeColor: "#ff0000",
          strokeOpacity: .7,
          strokeWidth: 1,
          fillColor: "#ff0000",
          fillOpacity: 0.5,
          cursor: "pointer",
          externalGraphic: OpenLayers.ImgPath + "marker.png",
          graphicHeight: 25,
          graphicWidth: 15,
          graphicOpacity: 1
        }),
        "select": new OpenLayers.Style({
          strokeColor: "#0033ff",
          strokeOpacity: .7,
          strokeWidth: 2,
          fillColor: "#0033ff",
          fillOpacity: 0,
          graphicZIndex: 2,
          cursor: "move"
        })
      });
    };
    return WorldView;
  })();
  WorldView.Toolbar = (function() {
    function Toolbar(options, map, mapID) {
      this.toggleControl = __bind(this.toggleControl, this);
      this.afterFeatureAdd = __bind(this.afterFeatureAdd, this);
      this.drawFeature = __bind(this.drawFeature, this);      this.map = map;
      this.mapID = mapID;
      this.toolbarID = this.mapID + "-toolbar";
      this.initToolbarDOM();
      this.initToolbarControls(options, this.map);
    }
    Toolbar.prototype.initToolbarDOM = function() {
      var div, mapDom, ul;
      div = OpenLayers.Util.createDiv(this.toolbarID, null, null, null, "absolute", null, null, null);
      div.setAttribute("class", "wv-toolbar");
      ul = document.createElement("ul");
      ul.setAttribute("id", this.toolbarID + '-controlToggle');
      div.appendChild(ul);
      mapDom = document.getElementById(this.mapID);
      return mapDom.insertBefore(div, mapDom.firstChild);
    };
    Toolbar.prototype.initToolbarControls = function(options) {
      var control, item, vectorLayer, _results;
      vectorLayer = options.vectorLayer.vectorLayer;
      this.allToolbarItems = {
        "navigate": {
          id: this.toolbarID + "-navigate",
          title: "navigate",
          img: "navigate.png"
        },
        "point": {
          id: this.toolbarID + "-point",
          title: "point",
          img: "marker.png",
          control: this.drawFeature(vectorLayer, OpenLayers.Handler.Point)
        },
        "line": {
          id: this.toolbarID + "-line",
          title: "line",
          img: "line.png",
          control: this.drawFeature(vectorLayer, OpenLayers.Handler.Path)
        },
        "polygon": {
          id: this.toolbarID + "-polygon",
          title: "polygon",
          img: "square.png",
          control: this.drawFeature(vectorLayer, OpenLayers.Handler.Polygon)
        },
        "drag": {
          id: this.toolbarID + "-drag",
          title: "drag",
          img: "drag.png",
          control: new OpenLayers.Control.DragFeature(vectorLayer)
        }
      };
      this.toolbarItems = {};
      if (options.controls) {
        for (control in options.controls) {
          this.toolbarItems[control] = this.allToolbarItems[control];
        }
      } else {
        this.toolbarItems = this.allToolbarItems;
      }
      _results = [];
      for (item in this.toolbarItems) {
        this.createToolbarItem(item);
        _results.push(this.toolbarItems[item].control ? this.map.addControl(this.toolbarItems[item].control) : void 0);
      }
      return _results;
    };
    Toolbar.prototype.createToolbarItem = function(item) {
      var im, li;
      item = this.toolbarItems[item];
      li = document.createElement("li");
      im = document.createElement("img");
      im.setAttribute("src", OpenLayers.ImgPath + item.img);
      im.setAttribute("title", item.title);
      im.setAttribute("id", item.id);
      li.appendChild(im);
      document.getElementById(this.toolbarID + '-controlToggle').appendChild(li);
      if (!item.tc) {
        return this.registerEventListenersForToolbarItems(this, item.id);
      }
    };
    Toolbar.prototype.drawFeature = function(vectorLayer, handler) {
      return new OpenLayers.Control.DrawFeature(vectorLayer, handler, {
        'featureAdded': this.afterFeatureAdd
      });
    };
    Toolbar.prototype.afterFeatureAdd = function(feature) {
      this.toggleControl({
        title: "navigate"
      });
      if (WorldView.Toolbar.featureAdded) {
        return WorldView.Toolbar.featureAdded(feature);
      }
    };
    Toolbar.prototype.registerEventListenersForToolbarItems = function(obj, id) {
      var el;
      el = document.getElementById(id);
      return el.addEventListener("click", (function() {
        return obj.toggleControl(el);
      }), false);
    };
    Toolbar.prototype.toggleControl = function(element) {
      var control, item, _results;
      _results = [];
      for (item in this.toolbarItems) {
        control = this.toolbarItems[item].control;
        _results.push(control && ((element.value === item) || (element.title === item)) ? control.activate() : control ? control.deactivate() : void 0);
      }
      return _results;
    };
    return Toolbar;
  })();
  WorldView.VectorLayer = (function() {
    function VectorLayer(map, options, olOptions) {
      this.map = map;
      if (options == null) {
        options = {
          events: false
        };
      }
      if (olOptions == null) {
        olOptions = {
          styleMap: WorldView.Config.styleMap
        };
      }
      this.onPopupClose = __bind(this.onPopupClose, this);
      this.VectorLayer = __bind(this.VectorLayer, this);
      this.vectorLayer = new OpenLayers.Layer.Vector(name || "Vector Layer", olOptions);
      if (options.events) {
        this.registerEventsOnVectorLayer(options);
      }
      this.map.addLayer(this.vectorLayer);
    }
    VectorLayer.prototype.registerEventsOnVectorLayer = function(options) {
      var featureControl;
      featureControl = new OpenLayers.Control.SelectFeature(this.vectorLayer);
      this.vectorLayer.events.on({
        'featureselected': options.featureSelected,
        'featureunselected': options.featureUnselected
      });
      this.map.addControl(featureControl);
      return featureControl.activate();
    };
    VectorLayer.initPopup = function(feature, content, width, height) {
      OpenLayers.Popup.FramedCloud.prototype.autoSize = false;
      return new OpenLayers.Popup.FramedCloud("popup-" + feature.id, feature.geometry.getBounds().getCenterLonLat(), new OpenLayers.Size(width, height), content, null, true, this.onPopupClose);
    };
    VectorLayer.prototype.addPopup = function(options) {
      var popup;
      popup = WorldView.VectorLayer.initPopup(options.feature, options.content || "", options.width || 200, options.height || 200);
      options.feature.popup = popup;
      this.map.addPopup(popup);
      return popup;
    };
    VectorLayer.prototype.removePopup = function(feature) {
      if (feature.popup) {
        this.map.removePopup(feature.popup);
        feature.popup.destroy();
        return delete feature.popup;
      }
    };
    VectorLayer.prototype.onPopupClose = function(evt) {
      return this.featureControl.unselectAll();
    };
    VectorLayer.prototype.initMarker = function(lon, lat, attributes, style, transform) {
      var feature, lonLat;
      if (attributes == null) {
        attributes = {};
      }
      if (style == null) {
        style = WorldView.Config.vectorMarkerStyle;
      }
      if (transform == null) {
        transform = true;
      }
      if (transform === true) {
        lonLat = WorldView.transformToMercator(this.map, lon, lat);
      } else {
        lonLat = WorldView.createLonLat(lon, lat);
      }
      feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat), attributes, style);
      return feature;
    };
    VectorLayer.prototype.addMarker = function(vectorMarkerOptions) {
      var feature;
      feature = this.initMarker(vectorMarkerOptions.lon, vectorMarkerOptions.lat, vectorMarkerOptions.attributes, vectorMarkerOptions.style, vectorMarkerOptions.transform);
      this.addFeature(feature);
      return feature;
    };
    VectorLayer.prototype.generatePoints = function(pointsOptions) {
      var point, points;
      points = [];
      for (point in pointsOptions) {
        points.push(WorldView.transformPoint(this.map, WorldView.createOlPoint(point.lon, point.lat)));
      }
      return points;
    };
    VectorLayer.prototype.addPolygon = function(options) {
      var feature, linear_ring, points;
      points = this.generatePoints(options.points);
      linear_ring = new OpenLayers.Geometry.LinearRing(points);
      feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Polygon([linear_ring]), options.attributes || {}, options.style || {});
      this.addFeature(feature);
      return feature;
    };
    VectorLayer.prototype.addFeatureFromGeometry = function(geometry, bounds) {
      var options;
      options = {
        internalProjection: new OpenLayers.Projection("EPSG:4326"),
        externalProjection: new OpenLayers.Projection("EPSG:4326")
      };
      this.addFeature(new OpenLayers.Format.WKT(options).read(geometry));
      if (bounds) {
        return this.map.zoomToExtent(bounds);
      }
    };
    VectorLayer.prototype.addLine = function(options) {
      var feature, points;
      points = this.generatePoints(options.points);
      feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LineString(points), options.attributes || {}, options.style || {});
      this.addFeature(feature);
      return feature;
    };
    VectorLayer.prototype.addCircle = function(circleOptions) {
      var circle, feature, point;
      point = WorldView.transformPoint(this.map, WorldView.createOlPoint(circleOptions.lon, circleOptions.lat));
      circle = OpenLayers.Geometry.Polygon.createRegularPolygon(point, circleOptions.radius, 20);
      feature = new OpenLayers.Feature.Vector(circle, null, circleOptions.style || {});
      this.addFeature(feature);
      return feature;
    };
    VectorLayer.prototype.addFeature = function(feature) {
      return this.vectorLayer.addFeatures([feature]);
    };
    return VectorLayer;
  })();
  WorldView.Config = {
    lat: 0.0,
    lon: 0.0,
    size: function(w, h) {
      if (w == null) {
        w = 25;
      }
      if (h == null) {
        h = 25;
      }
      return new OpenLayers.Size(w, h);
    }
  };
  WorldView.Config.offset = new OpenLayers.Pixel(-(WorldView.Config.size.w / 2), -WorldView.Config.size.h);
  WorldView.Config.vectorMarkerStyle = {
    externalGraphic: "gv_marker.png",
    graphicHeight: 21,
    graphicWidth: 16,
    graphicOpacity: 1
  };
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
  window.WorldView = WorldView;
}).call(this);
