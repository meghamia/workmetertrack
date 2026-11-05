import 'package:flutter/material.dart';

class AttendanceStep {
  const AttendanceStep({
    required this.label,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final String title;
  final Color backgroundColor;
  final Color textColor;
}

class AttendanceCard {
  const AttendanceCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}
