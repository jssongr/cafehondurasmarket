import 'package:geolocator/geolocator.dart';

/// Requests location permission if needed. Returns false if the user denied
/// it or location services are off — callers should degrade gracefully.
Future<bool> ensureLocationPermission() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
}

Future<Position?> getCurrentPosition() async {
  if (!await ensureLocationPermission()) return null;
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    return null;
  }
}
