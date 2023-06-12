import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class DrawHandPage extends StatefulWidget {
  const DrawHandPage({Key? key}) : super(key: key);

  @override
  State<DrawHandPage> createState() => _DrawHandPageState();
}

class _DrawHandPageState extends State<DrawHandPage> {
  static final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polyLines = HashSet<Polyline>();

  bool _drawPolygonEnabled = false;
  final List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  int? _lastXCoordinate;
  int? _lastYCoordinate;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
        onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          polygons: _polygons,
          polylines: _polyLines,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
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
    // To start draw new polygon every time.
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnabled) {
      double? x;
      double? y;
      if (Platform.isAndroid) {
        // It times in 3 without any meaning,
        // We think it's an issue with GoogleMaps package.
        x = details.globalPosition.dx * 2;
        y = details.globalPosition.dy * 2;
        Logger().wtf('x  $x');
        Logger().wtf('y  $y');
      } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      }

      // Round the x and y.
      int? xCoordinate = x?.round();
      int? yCoordinate = y?.round();


      // Check if the distance between last point is not too far. //
      // to prevent two fingers drawing.
      if (_lastXCoordinate != null && _lastYCoordinate != null) { //sqrt(pow(xCoordinate! - _lastXCoordinate!, 2) + pow(yCoordinate! - _lastYCoordinate!, 2))
        var distance = sqrt(pow(xCoordinate! - _lastXCoordinate!, 2) + pow(yCoordinate! - _lastYCoordinate!, 2));
        dev.log('distance  $distance');
        // Check if the distance of point and point is large.
        if (distance > 80.0) return;
      }
      //xCoordinate  209
      //yCoordinate  774

      //x  209.03225708007812
      //y  773.6585083007812

      // Cached the coordinate.
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      ScreenCoordinate screenCoordinate = ScreenCoordinate(x: xCoordinate!, y: yCoordinate!);

      final GoogleMapController controller = await _controller.future;
      Logger().wtf('screenCoordinate  ${screenCoordinate.x}');
      Logger().wtf('screenCoordinate  ${screenCoordinate.y}');
      LatLng latLng = await controller.getLatLng(screenCoordinate);

      try {
        // Add new point to list.
        _userPolyLinesLatLngList.add(latLng);

        _polyLines.removeWhere((polyline) => polyline.polylineId.value == 'user_polyline');
        _polyLines.add(
          Polyline(
            polylineId: const PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.blue,
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print(" error painting $e");
        }
      }
      setState(() {});
    }
  }

  _onPanEnd(DragEndDetails details) async {
    // Reset last cached coordinate
    _lastXCoordinate = null;
    _lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      _polygons.removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
      _polygons.add(
        Polygon(

          polygonId: const PolygonId('user_polygon'),
          points: _userPolyLinesLatLngList,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.4),
        ),
      );
      setState(() {
        _clearDrawing = true;
      });
    }
  }

  _clearPolygons() {
    setState(() {
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
}
