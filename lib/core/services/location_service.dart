import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Checks if the device is within a certain [radius] (in meters) of [siteLat] and [siteLng].
  /// Returns null if location cannot be determined.
  Future<bool?> isWithinSiteRadius({
    required double siteLat,
    required double siteLng,
    required double radius,
  }) async {
    // Development Bypass
    if (kDebugMode) {
      debugPrint('LocationService: [DEBUG] Bypassing geofence check for testing.');
      return true;
    }

    try {
      final position = await _getCurrentPosition();
      if (position == null) return null;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        siteLat,
        siteLng,
      );

      debugPrint('LocationService: Distance to site: ${distance.toStringAsFixed(2)}m (Radius: ${radius}m)');
      return distance <= radius;
    } catch (e) {
      debugPrint('LocationService: Error checking geofence: $e');
      return null;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationService: Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('LocationService: Location permissions are denied');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('LocationService: Location permissions are permanently denied.');
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }
}
