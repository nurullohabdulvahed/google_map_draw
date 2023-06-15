import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:logger/logger.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({Key? key}) : super(key: key);

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  late MapController controller;

  @override
  void initState() {
    controller = MapController(
      initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: OSMFlutter(
        controller: controller,
        onLocationChanged: (getPoint){
          Logger().wtf('getPoint ${getPoint.longitude}');
        },
        initZoom: 12,
        minZoomLevel: 8,
        maxZoomLevel: 14,
        stepZoom: 1.0,
      ),
    );
  }
}
