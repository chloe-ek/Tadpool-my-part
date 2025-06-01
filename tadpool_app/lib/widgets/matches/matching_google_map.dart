import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tadpool_app/services/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map_screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late Marker _destinationMarker;
  late Marker _currentPositionMarker;
  Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _positionStreamSubscription;

  final DatabaseReference _selectedLocationRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
  ).ref().child('location');

  @override
  void initState() {
    super.initState();
    print("Inside initState method");
    _destinationMarker = _createMarker(0, 0, 'Destination');
    _currentPositionMarker = _createMarker(0, 0, 'Current');

    // print("selectedLocationRef: ${_selectedLocationRef.onValue}");

    _selectedLocationRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      double latitude = (data['latitude'] as num).toDouble();
      double longitude = (data['longitude'] as num).toDouble();
      String name = data['name'].toString();

      setState(() {
        _destinationMarker = _createMarker(latitude, longitude, name);
      });

      _updateRoute();
    });

    _positionStreamSubscription =
        _positionUpdates().listen((Position position) {
      setState(() {
        _currentPositionMarker = _createMarker(
          position.latitude,
          position.longitude,
          'Current Position',
        );
      });
    });
  }

  Stream<Position> _positionUpdates() async* {
    await for (var _ in Stream.periodic(const Duration(seconds: 5))) {
      yield await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
  }

  Marker _createMarker(double lat, double lng, String name) {
    return Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: name),
      icon: BitmapDescriptor.defaultMarker,
    );
  }

  Future<List<PointLatLng>> _getRoute(LatLng origin, LatLng destination) async {
    String originString = '${origin.latitude},${origin.longitude}';
    String destinationString =
        '${destination.latitude},${destination.longitude}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final url = URL.baseUrl +
        ("/google-directions/?origin=${originString}&destination=${destinationString}");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);

    // print("data: $data");

    // print('Response data: $data');

    if (data['status'] != "OK") {
      throw Exception("No routes found");
    }

    String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
    // print('Encoded polyline: $encodedPolyline');
    return _decodePoly(encodedPolyline);
  }

  List<PointLatLng> _decodePoly(String encoded) {
    // encoded = 'uvwkHjvknVK[CSEU?@AGAOAQASAS?Q@S@Q@WBSLq@F?BQBM|@wBH]@CFYFSDa@@IE_@BIl@wHFe@@ORaAF]F[J]@CRCRk@@ELUHMBCLSBCDIDEHK\\YFGZUBAE?BCb@U';

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encoded);
    return result;
  }

  Future<void> _updateRoute() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final origin = LatLng(position.latitude, position.longitude);
      final destination = _destinationMarker.position;

      List<LatLng> polylineCoords = [];
      final temp = await _getRoute(origin, destination);
      temp.forEach((element) {
        polylineCoords.add(LatLng(element.latitude, element.longitude));
      });
      // print('Polyline coordinates: $polylineCoords');

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 4,
        points: polylineCoords,
      );

      setState(() {
        _polylines.clear();
        _polylines.add(polyline);
      });

      if (polylineCoords.isNotEmpty) {
        final bounds = _calculateBounds(polylineCoords);
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      print('Route update error: $e');
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Inside build method");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff008000),
        title: const Text('Live Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(49.283517, -123.1153498),
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;

          _selectedLocationRef.once().then((snapshot) {
            final data = snapshot.snapshot.value;
            if (data == null || data is! Map) return;

            final locationData = Map<Object?, Object?>.from(data);
            double latitude = (locationData['latitude'] as num).toDouble();
            double longitude = (locationData['longitude'] as num).toDouble();

            print('Latitude: $latitude, Longitude: $longitude');

            _mapController.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15),
            );
          });

          _updateRoute();
        },
        markers: {_destinationMarker, _currentPositionMarker},
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onCameraIdle: () {
          try {
            LatLngBounds bounds = _calculateBounds(_polylines.first.points);

            _mapController.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100),
            );
          } catch (e) {
            print('Failed to calculate bounds: $e');
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
