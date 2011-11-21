
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
