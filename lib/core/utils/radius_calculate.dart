import 'dart:math' show cos, sqrt, asin, sin, atan2, pi;

class RadiusCalculate {
  static double calculateDistanceInMeter(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const earthRadius = 6371000; // dalam meter
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_degToRad(lat1)) *
                cos(_degToRad(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // hasil akhir dalam meter
  }

  /// Mengubah derajat ke radian
  static double _degToRad(double degree) {
    return degree * pi / 180;
  }
}
