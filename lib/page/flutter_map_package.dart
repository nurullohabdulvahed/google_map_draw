import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class FlutterMapPackagePage extends StatefulWidget {
  const FlutterMapPackagePage({Key? key}) : super(key: key);

  @override
  State<FlutterMapPackagePage> createState() => _FlutterMapPackagePageState();
}

class _FlutterMapPackagePageState extends State<FlutterMapPackagePage> {
  late MapController _controller;

  List<LatLng> polylineLatLngList = [];
  List<LatLng> polygonLatLngList = [];
  List<Map<String, dynamic>> latitudeLongitudeList = [];
  bool startDrawing = false;
  MapController mapController = MapController();
  List<Marker>? markersList;

  @override
  void initState() {
    _controller = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        //mapController: _controller,
        options: MapOptions(
          center: const LatLng(41.311081, 69.240562),
          zoom: 9.2,
          onTap: (tapPosition, latLng) {
            setState(() {
              startDrawing = !startDrawing;
            });
          },
          enableScrollWheel: false,
          keepAlive: false,
          enableMultiFingerGestureRace: false,
          onMapEvent: (event){
            Logger().wtf('event  ${event.center.longitude}');
          },
          onPointerHover: (pointerHoverEvent, latLng) {
            if (startDrawing) {
              setState(() {
                polylineLatLngList.add(LatLng(latLng.latitude, latLng.longitude));
                polygonLatLngList.add(LatLng(latLng.latitude, latLng.longitude));
                latitudeLongitudeList.add({"latitude": latLng.latitude, "longitude": latLng.longitude});
              });

              // widget.drawnRouteLatLngList(latitudeLongitudeList);
            }
          },
        ),
        // nonRotatedChildren: [
        //   RichAttributionWidget(
        //     attributions: [
        //       TextSourceAttribution(
        //         'OpenStreetMap contributors',
        //         onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
        //       ),
        //     ],
        //   ),
        // ],
        children: [
          TileLayer(
            minZoom: 1,
            maxZoom: 18,
            backgroundColor: Colors.white,
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markersList ?? []),
          PolylineLayer(
            polylines: [
              Polyline(
                color: Colors.blue,
                strokeWidth: 5,
                points: polylineLatLngList,
              )
            ],
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: polygonLatLngList,
              )
            ],
          )
        ],
      ),
    );
  }
}


