import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_map_training/model/features.dart';
import 'package:logger/logger.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapBoxPage extends StatefulWidget {
  const MapBoxPage({Key? key}) : super(key: key);

  @override
  State<MapBoxPage> createState() => _MapBoxPageState();
}

class _MapBoxPageState extends State<MapBoxPage> {
  static final Completer<MapboxMapController> _controller = Completer();

  bool _drawPolygonEnabled = false;
  final List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  double? _lastXCoordinate;
  double? _lastYCoordinate;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
        onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
        child: MapboxMap(
          accessToken: 'sk.eyJ1IjoiaW1udXJ1bGxvaCIsImEiOiJjbGoydGplcXUweTNrM2VsZG5vdmx2aW9iIn0.oszBSB60XTPQdlnCKfQCYA',
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(41.311081, 69.240562),
          ),
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
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnabled) {
      double? x;
      double? y;
      if (Platform.isAndroid) {
        x = details.globalPosition.dx * 3;
        y = details.globalPosition.dy * 3;
      } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      }

      double? xCoordinate = x;
      double? yCoordinate = y;

      if (_lastXCoordinate != null && _lastYCoordinate != null) {
        var distance = sqrt(pow(xCoordinate! - _lastXCoordinate!, 2) + pow(yCoordinate! - _lastYCoordinate!, 2));
        if (distance > 80.0) return;
      }
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      Point<num> screenLocation = Point(xCoordinate!, yCoordinate!);
      final MapboxMapController controller = await _controller.future;
      LatLng latLng = await controller.toLatLng(screenLocation);
      try {
        _userPolyLinesLatLngList.add(latLng);
        controller.addLines([
          LineOptions(geometry: _userPolyLinesLatLngList,),
        ],);
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
      final MapboxMapController controller = await _controller.future;


     // Feature feature = Feature(geometry: Geometry(coordinates: [_userPolyLinesLatLngList]));
      controller.addFills(
        [
          FillOptions(geometry: [_userPolyLinesLatLngList], fillColor: '0xFF2196F3', fillOutlineColor: '0xFF2196F3')
        ],
      );
      //controller.addGeoJsonSource(sourceId, {});
      setState(() {
        _clearDrawing = true;
      });
    }
  }

  _clearPolygons() {
    setState(() {
      // _polyLines.clear();
      // _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
}
