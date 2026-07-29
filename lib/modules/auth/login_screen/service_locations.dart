import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';

class LocationService {
  /// Same as [getCurrentLocation], but on web — where browsers block a site
  /// from reopening its own permission prompt once blocked, and the
  /// geolocator web plugin often reports plain `denied` rather than
  /// `deniedForever` even after a permanent block — shows a dialog with
  /// instructions and a "Try Again" button instead of just a snackbar,
  /// for ANY non-granted permission state, not just deniedForever.
  static Future<Position?> getCurrentLocationWithPrompt(BuildContext context) async {
    if (!kIsWeb) return getCurrentLocation();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!context.mounted) return null;
        final retry = await showEnableLocationDialog(context);
        return (retry && context.mounted)
            ? getCurrentLocationWithPrompt(context)
            : null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!context.mounted) return null;
        final retry = await showEnableLocationDialog(context);
        return (retry && context.mounted)
            ? getCurrentLocationWithPrompt(context)
            : null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      Get.snackbar("Location Found", "Your current location has been captured.");
      return position;
    } catch (e) {
      Get.snackbar(
        "Location Error",
        "Couldn't get your location: $e",
        duration: const Duration(seconds: 5),
      );
      return null;
    }
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Get.snackbar("Location Disabled", "Please enable location service");

      if (!kIsWeb) {
        await Geolocator.openLocationSettings();
      }

      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required");
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
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      Placemark place = placemarks.first;
      print('longitude${longitude}latitude$latitude');
      return '${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
    } catch (e) {
      return 'Unknown location';
    }
  }

  static Future<void> showCurrentLocation() async {
    final position = await getCurrentLocation();
    if (position != null) {
      final address = await getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      Get.snackbar('Location', 'Your location: $address');
    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
  }
}
