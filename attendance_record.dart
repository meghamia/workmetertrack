import 'package:track_attendance_app/models/user_role.dart';

class AttendanceRecord {
  final String id;
  final String loginId;
  final String employeeId;
  final DateTime timestamp;
  final String type;
  final String location;
  final String? photoPath;
  final double latitude;
  final double longitude;

  AttendanceRecord({
    required this.id,
    required this.loginId,
    required this.employeeId,
    required this.timestamp,
    required this.type,
    required this.location,
    this.photoPath,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loginId': loginId,
      'employeeId': employeeId,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'location': location,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      loginId: json['loginId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      photoPath: json['photoPath'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final twelveHour = hour % 12;
    final displayHour =
    (twelveHour == 0 ? 12 : twelveHour).toString().padLeft(2, '0');
    return '$displayHour:$minute $period';
  }

  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return day + '/' + month + '/' + year.toString();
  }
}

class AttendanceLocation {
  final double latitude;
  final double longitude;
  final String address;

  AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
