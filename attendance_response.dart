class AttendanceResponse {
  final String status;
  final String message;
  final String attendanceId;
  final String employeeId;
  final String attendanceDate;

  final String? checkIn;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? checkInImage;

  // Present in the check-OUT response
  final String? checkOut;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutImage;

  final String? remarks;
  final String? location;



  const AttendanceResponse({

    required this.status,
    required this.message,
    required this.attendanceId,
    required this.employeeId,
    required this.attendanceDate,
    this.checkIn,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInImage,
    this.checkOut,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutImage,
    this.remarks,
    this.location,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      attendanceId: json['attendance_id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      attendanceDate: json['attendance_date']?.toString() ?? '',
      checkIn: json['check_in']?.toString(),
      checkInLatitude: _toDouble(json['check_in_latitude']),
      checkInLongitude: _toDouble(json['check_in_longitude']),
      checkInImage: json['check_in_image']?.toString(),
      checkOut: json['check_out']?.toString(),
      checkOutLatitude: _toDouble(json['check_out_latitude']),
      checkOutLongitude: _toDouble(json['check_out_longitude']),
      checkOutImage: json['check_out_image']?.toString(),
      remarks: json['remarks']?.toString(),
      location: json['location']?.toString() ?? json['remarks']?.toString(),
    );
  }

  /// The backend sends "Present" as a plain string,
  /// not a JSON boolean.
  bool get isSuccessful => status.toLowerCase() == 'present';

  DateTime? get checkInTime => _parseTime(checkIn);
  DateTime? get checkOutTime => _parseTime(checkOut);

  static DateTime? _parseTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Handle multiple datetime formats:
    // - ISO 8601 with T: "2026-10-07T10:47:44"
    // - Space-separated: "2026-10-07 10:47:44"
    // - Date only: "2026-10-07"
    try {
      // First try standard parse (handles ISO 8601 with T)
      return DateTime.parse(value);
    } catch (_) {
      try {
        // Handle space-separated format by replacing space with T
        return DateTime.parse(value.replaceAll(' ', 'T'));
      } catch (_) {
        // Try just the date portion if all else fails
        try {
          final datePart = value.split(' ')[0];
          return DateTime.parse(datePart);
        } catch (_) {
          return null;
        }
      }
    }
  }
  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    // Lat/lng arrive as strings, e.g. "30.9009650"
    return double.tryParse(value.toString());
  }
}