import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) {
      print('Location permission denied');
      return null;
    }

    try {
      print('Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      print('Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting position: $e');
      // Try to get last known position as fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print(
            'Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}',
          );
          return lastPosition;
        }
      } catch (e) {
        print('Error getting last position: $e');
      }
      return null;
    }
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build address string
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address = place.street!;
        }

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }

        return address.isNotEmpty ? address : 'Lokasi tidak diketahui';
      }
    } catch (e) {
      return 'Lokasi tidak diketahui';
    }
    return 'Lokasi tidak diketahui';
  }

  /// Get city name from coordinates
  Future<String> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? 'Kota';
      }
    } catch (e) {
      return 'Kota';
    }
    return 'Kota';
  }

  /// Get current location details (city and address)
  Future<Map<String, String>> getCurrentLocationDetails() async {
    try {
      print('Starting to get location details...');
      final position = await getCurrentPosition();

      if (position == null) {
        print('Position is null');
        return {
          'city': 'Lokasi tidak tersedia',
          'address': 'Aktifkan lokasi untuk melihat alamat',
        };
      }

      print('Getting city and address from coordinates...');
      final results = await Future.wait([
        getCityFromCoordinates(position.latitude, position.longitude),
        getAddressFromCoordinates(position.latitude, position.longitude),
      ]);

      final city = results[0];
      final address = results[1];
      print('Location details obtained: $city - $address');

      return {'city': city, 'address': address};
    } catch (e) {
      print('Error in getCurrentLocationDetails: $e');
      return {
        'city': 'Lokasi tidak tersedia',
        'address': 'Terjadi kesalahan saat memuat lokasi',
      };
    }
  }
}
