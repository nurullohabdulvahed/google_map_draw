library draw_on_map;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class LatitudeLongitude{
  final double latitude, longitude;
  LatitudeLongitude(this.latitude, this.longitude);
}

class MapMarker{
  final double height, width;
  final LatitudeLongitude point;
  final Widget Function(BuildContext) builder;
  MapMarker(this.height, this.width, this.point, this.builder);
}

class MapWidget extends StatefulWidget {
  final double? minZoom, maxZoom;
  final double zoom, strokeWidth, borderStrokeWidth;
  final Color polylineColor, borderColor;
  final LatitudeLongitude? center;
  final LatitudeLongitude currentUserLocation;
  final List<MapMarker>? markers;
  final ValueChanged drawnRouteLatLngList;
  final bool isDotted;
  const MapWidget({Key? key, this.minZoom, this.maxZoom, required this.zoom, this.center, this.markers, required this.drawnRouteLatLngList, required this.strokeWidth, required this.polylineColor, required this.borderStrokeWidth, required this.borderColor, required this.isDotted, required this.currentUserLocation}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<LatLng> polylineLatLngList = [];
  List<Map<String, dynamic>> latitudeLongitudeList = [];
  bool startDrawing = false;
  MapController mapController = MapController();
  List<Marker>? markersList;

  @override
  void initState() {
    widget.markers?.forEach((element) {
      markersList?.add(Marker(height: element.height, width: element.width, point: LatLng(element.point.latitude, element.point.longitude), builder: element.builder));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        mapController: mapController,
        options: MapOptions(
            zoom: widget.zoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            center: LatLng(widget.center?.latitude??0.0, widget.center?.longitude??0.0),
            onTap: (tapPosition, latLng){
              setState(() {
                startDrawing = !startDrawing;
              });
            },
            onPointerHover: (pointerHoverEvent, latLng){
              if(startDrawing){
                setState(() {
                  polylineLatLngList.add
                    (LatLng(latLng.latitude, latLng.longitude))
                  ;
                  latitudeLongitudeList.add
                    (
                      {
                        "latitude": latLng.latitude,
                        "longitude": latLng.longitude
                      }
                  );
                });
                widget.drawnRouteLatLngList(latitudeLongitudeList);
              }
            }
        ),
        children: [
          TileLayer(
            minZoom: 1,
            maxZoom: 18,
            backgroundColor: Colors.white,
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markersList??[]),
          PolylineLayer(polylines: [Polyline(
              strokeWidth: widget.strokeWidth,
              color: widget.polylineColor,
              borderStrokeWidth: widget.borderStrokeWidth,
              borderColor: widget.borderColor,
              isDotted: widget.isDotted,
              points: polylineLatLngList)])
        ]
    );
  }
}