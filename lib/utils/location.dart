import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  Position? position;
  String? _currentAddress;

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      this.position = position;
    }).catchError((e) {
      debugPrint(e);
    });

    return position;
  }

  Future<String?> getAddressFromLatLng(Position position) async {
  await placemarkFromCoordinates(
          position.latitude, position.longitude)
      .then((List<Placemark> placemarks) {
        for (Placemark place in placemarks) {
          log('place: $place');
        }
    Placemark place = placemarks[0];
      _currentAddress =
         '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
  }).catchError((e) {
    debugPrint("Error here $e");
  });

  return _currentAddress;
 }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
        msg: 'Location services are disabled. Please enable the services',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
        msg: 'Location permissions are denied',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: 'Location permissions are permanently denied, we cannot request permissions.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }
}
