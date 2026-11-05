class AttendanceLocation {
  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.accuracy = 0,
    this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final DateTime? capturedAt;

  String get coordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
