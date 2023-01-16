import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _googleMapController = Completer();

  final List<Marker> _markers = <Marker>[];

  double? latitude;

  double? longitude;

  CameraPosition _cameraPosition =
      const CameraPosition(target: LatLng(-29.69, -53.80), zoom: 15.0);

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController.complete(controller);
  }

  @override
  void initState() {
    super.initState();

    _setCurrentPosition();
  }

  Future<void> _setCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude.toDouble();
      longitude = position.longitude.toDouble();

      print('PEGANDO POSICAO ATUAL...');

      print('LATITUDE:' + latitude.toString());
      print('LONGITUDE:' + longitude.toString());

      _cameraPosition = CameraPosition(
        target: LatLng(latitude!, longitude!),
        zoom: 11.0,
      );
    });
  }

  void _incrementCounter() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude.toDouble();
      longitude = position.longitude.toDouble();

      print('ADD MARCADOR NA LOCALIZAÇÃO ATUAL');

      print('LATITUDE:' + latitude.toString());
      print('LONGITUDE:' + longitude.toString());

      _markers.add(Marker(
          markerId: const MarkerId('1'),
          position: LatLng(latitude!, longitude!)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: GoogleMap(
              myLocationEnabled: true,
              mapType: MapType.terrain,
              markers: Set<Marker>.of(_markers),
              onMapCreated: _onMapCreated,
              initialCameraPosition: _cameraPosition,
              onTap: (LatLng latLng) {
                _markers.add(
                    Marker(markerId: const MarkerId('mark'), position: latLng));
                setState(() {
                  latitude = latLng.latitude;
                  longitude = latLng.longitude;
                });
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
