import 'package:geocoding/geocoding.dart';

class LocationHelper {
  /// Reverse geocode lat/lon menjadi alamat
  static Future<String> reverseGeocode(double lat, double lon) async {
    try {
      // Mengembalikan daftar placemark terdekat
      final placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Gabungkan bagian‐bagian alamat
        final address = <String>[
          if (p.street != null && p.street!.isNotEmpty) p.street ?? '',
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality ?? '',
          if (p.locality != null && p.locality!.isNotEmpty) p.locality ?? '',
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea ?? '',
          if (p.country != null && p.country!.isNotEmpty) p.country ?? '',
        ].join(', ');
        return address;
      } else {
        return 'Alamat tidak tersedia';
      }
    } catch (e) {
      // Tangani error (misal network, izin, dll)
      return 'Alamat tidak tersedia';
    }
  }
}
