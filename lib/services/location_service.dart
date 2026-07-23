import 'package:geolocator/geolocator.dart';

class LocationService {

  // Check permission
  Future<bool> checkPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermission();

    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}