import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapController controller = MapController();
  bool _drawPolygonEnabled = false;
  final List<LatLng> _userPolyLinesLatLngList = [];
  late LatLng? firstLatLng;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map Nurulloh'),
      ),
      body: FlutterMap(
        mapController: controller,
        nonRotatedChildren: [
          GestureDetector(
            onPanUpdate: (details) {
              var p = details.localPosition;
              int xCoordinate = p.dx.round();
              int yCoordinate = p.dy.round();
              final lat = controller.pointToLatLng(CustomPoint(xCoordinate, yCoordinate));
              Logger().wtf('lat.longitude  --- ${lat.longitude}');
              Logger().wtf('lat.latitude  --- ${lat.latitude}');
              _userPolyLinesLatLngList.add(
                controller.pointToLatLng(CustomPoint(xCoordinate, yCoordinate)),
              );
              setState(() {});
            },
          ),
        ],
        options: MapOptions(
          center: const LatLng(37.42796133580664, -122.085749655962),
          onPointerDown: (event, point) {

            _userPolyLinesLatLngList.clear();
            _userPolyLinesLatLngList.add(point);
            firstLatLng = point;
            setState(() {});
          },
          onPointerUp: (event, point) {
            _userPolyLinesLatLngList.add(point);
            if (firstLatLng != null) {
              _userPolyLinesLatLngList.add(firstLatLng!);
            }
            firstLatLng = null;
            setState(() {});
          },
          interactiveFlags:
          _drawPolygonEnabled ? InteractiveFlag.none : InteractiveFlag.all,
          zoom: 14.4746,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            backgroundColor: Colors.transparent,
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                color: Colors.blue,
                borderStrokeWidth: 3,
                strokeWidth: 3,
                borderColor: Colors.white,
                points: _userPolyLinesLatLngList,
              )
            ],
          ),
          // PolygonLayer(
          //   polygons: [
          //     Polygon(
          //       points: _userPolyLinesLatLngList,
          //       color: Colors.blue,
          //       //isFilled: true
          //     )
          //   ],
          // )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDrawing,
        tooltip: 'Drawing',
        child: Icon((_drawPolygonEnabled) ? Icons.cancel : Icons.edit),
      ),
    );
  }


  _toggleDrawing() {
    _clearPolygons();
    setState(() => _drawPolygonEnabled = !_drawPolygonEnabled);
  }

  _clearPolygons() {
    setState(() {
      _userPolyLinesLatLngList.clear();
    });
  }
}