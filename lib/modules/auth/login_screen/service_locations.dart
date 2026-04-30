import 'package:get/get.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
  class LocationService {
  static Future<Position?> getCurrentLocation() async {

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
  Get.snackbar(
  "Location Disabled",
  "Please enable location service",
  );

  if (!kIsWeb) {
  await Geolocator.openLocationSettings();
  }

  return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
  Get.snackbar(
  "Permission Denied",
  "Location permission is required",
  );
  return null;
  }
  }
  if (permission == LocationPermission.deniedForever) {

  if (kIsWeb) {

  Get.snackbar(
  "Location Blocked",
  "Please enable location permission in your browser settings",
  duration: const Duration(seconds: 5),
  );

  } else {

  Get.snackbar(
  "Permission Required",
  "Enable location permission in app settings",
  duration: const Duration(seconds: 5),
  );

  await Geolocator.openAppSettings();
  }
  return null;
  }
  return await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  );
  }

  static Future<String> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks.first;

      return '${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
    } catch (e) {
      return 'Unknown location';
    }
  }
  static Future<void> showCurrentLocation() async {
    final position = await getCurrentLocation();
    if (position != null) {
      final address =
      await getAddressFromLatLng(position.latitude, position.longitude);
      Get.snackbar('Location', 'Your location: $address');
    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }
}