import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MapController _controller;
  Completer<MapController> mapController = Completer();
  bool _drawPolygonEnabled = false;
  final List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  int? _lastXCoordinate;
  int? _lastYCoordinate;
  List<Polygon> polygons = const [];
  List<Polyline> polyLines = const [];


  @override
  void initState() {
    _controller = MapController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
        onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
        child: FlutterMap(
          //mapController: _controller,
          options: MapOptions(
            center: const LatLng(41.311081, 69.240562),
            zoom: 9.2,
          ),
          children: [
            TileLayer(
              minZoom: 1,
              maxZoom: 18,
              backgroundColor: Colors.white,
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            PolylineLayer(
              polylines:polyLines,
            ),
            PolygonLayer(
              polygons: polygons,
            ),
          ],
        )
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

  _onPanUpdate(DragUpdateDetails details) async {

    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnabled) {
      double? x;
      double? y;
      if (Platform.isAndroid) {
        x = details.globalPosition.dx * 2;
        y = details.globalPosition.dy * 2;
      } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      }

      int? xCoordinate = x?.round();
      int? yCoordinate = y?.round();

      if (_lastXCoordinate != null && _lastYCoordinate != null) {
        var distance = sqrt(pow(xCoordinate! - _lastXCoordinate!, 2) + pow(yCoordinate! - _lastYCoordinate!, 2));
        if (distance > 80.0) return;
      }
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      CustomPoint<int> screenCoordinate = CustomPoint(xCoordinate!,yCoordinate!);

      LatLng latLng = _controller.pointToLatLng(screenCoordinate);

      try {
        _userPolyLinesLatLngList.add(latLng);

        polyLines.add(
          Polyline(
            points: _userPolyLinesLatLngList,
            color: Colors.blue,
          ),
        );
      } catch (e) {
        Logger().e('error  ${e.toString()}');
      }
      setState(() {});
    }
  }

  _onPanEnd(DragEndDetails details) async {
    _lastXCoordinate = null;
    _lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      polygons.add(
        Polygon(
          color: Colors.blue,
          points: _userPolyLinesLatLngList,
        ),
      );
      setState(() {
        _clearDrawing = true;
      });
    }
  }


  //changed
  _clearPolygons() {
    setState(() {
      //polyLines.clear();
      //polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
}
