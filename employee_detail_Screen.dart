import 'package:flutter/material.dart';
import '../models/auth/employee_model.dart';
import '../theme/app_color.dart';
//
// class EmployeeDetailScreen extends StatelessWidget {
//   final Employee employee;
//   final Map<String, dynamic> record;
//
//   const EmployeeDetailScreen({super.key, required this.employee, required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     final status = record['status']?.toString() ?? 'Unknown';
//     final date = record['date']?.toString() ?? 'N/A';
//     final punchIn = record['punchIn']?.toString() ?? '-';
//     final punchOut = record['punchOut']?.toString() ?? '-';
//     final workHours = record['workHours']?.toString() ?? '-';
//
//     return Scaffold(
//       backgroundColor: AppColors.surfaceVariant,
//       appBar: AppBar(
//         title: Text(employee.displayName,
//             style: const TextStyle(fontSize: 18)),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           // Employee Info Card
//           Card(
//             color: AppColors.surface,
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: BorderSide(color: AppColors.divider, width: 0.5),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 _row(Icons.badge_outlined, 'Name', employee.displayName),
//                 _divider(),
//                 _row(Icons.email_outlined, 'Login ID', employee.loginId),
//                 _divider(),
//                 _row(Icons.perm_identity_outlined, 'Employee ID', employee.id),
//                 _divider(),
//                 _row(Icons.business_outlined, 'Department', employee.department ?? 'General'),
//                 _divider(),
//                 _row(Icons.work_outline, 'Designation', employee.designation ?? 'N/A'),
//                 _divider(),
//                 _row(Icons.group_outlined, 'Role', employee.roleName ?? 'Employee'),
//                 _divider(),
//                 _row(Icons.circle, 'Status',
//                     employee.isActiveFlag ? 'Active' : 'Inactive',
//                     valueColor: employee.isActiveFlag ? Colors.green : Colors.red),
//                 _divider(),
//                 _row(Icons.person_outline, 'Created By', employee.createdBy),
//                 _divider(),
//                 _row(Icons.calendar_today_outlined, 'Created Date', employee.createdDate),
//               ]),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Attendance Summary Card
//           Card(
//             color: AppColors.surface,
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: BorderSide(color: AppColors.divider, width: 0.5),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Today\'s Attendance',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.onSurface)),
//                 const SizedBox(height: 8),
//                 _divider(),
//                 _row(Icons.calendar_today_outlined, 'Date', date),
//                 _divider(),
//                 _row(Icons.access_time_outlined, 'Punch In', punchIn,
//                     valueColor: punchIn != '-' ? AppColors.info : AppColors.onSurfaceVariant),
//                 _divider(),
//                 _row(Icons.access_time_outlined, 'Punch Out', punchOut,
//                     valueColor: punchOut != '-' ? AppColors.warning : AppColors.onSurfaceVariant),
//                 _divider(),
//                 _row(Icons.timer_outlined, 'Work Hours', workHours,
//                 valueColor: workHours != '-' ? AppColors.warning : AppColors.onSurfaceVariant),
//                 _divider(),
//                 _row(Icons.circle, 'Status', status,
//                     valueColor: status == 'Present' ? Colors.green
//                         : status == 'Absent' ? Colors.red : AppColors.onSurfaceVariant),
//               ]),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(children: [
//         Icon(icon, size: 18, color: AppColors.primary),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
//             const SizedBox(height: 2),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: valueColor ?? AppColors.onSurface)),
//           ]),
//         ),
//       ]),
//     );
//   }
//
//   Widget _divider() => const Padding(
//     padding: EdgeInsets.symmetric(vertical: 4),
//     child: Divider(height: 1),
//   );
// }



import 'package:flutter/material.dart';
import '../models/auth/employee_model.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  final Map<String, dynamic> record;

  const EmployeeDetailScreen({super.key, required this.employee, required this.record});

  @override
  Widget build(BuildContext context) {
    final status = record['status']?.toString() ?? 'Unknown';
    final date = record['date']?.toString() ?? 'N/A';
    final punchIn = record['punchIn']?.toString() ?? '-';
    final punchOut = record['punchOut']?.toString() ?? '-';
    final workHours = record['workHours']?.toString() ?? '-';

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 8 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);
    final double appBarTitleFont = ResponsiveHelper.getMediumFontSize(context);
    final double cardPaddingV = ResponsiveHelper.getSmallSpacing(context) * 1.25;
    final double cardPaddingH = ResponsiveHelper.getWidthPercentage(context, 4);
    final double rowVerticalPadding = ResponsiveHelper.getSmallSpacing(context) * 0.75;
    final double iconSize = ResponsiveHelper.getWidthPercentage(context, 5);
    final double labelFont = ResponsiveHelper.getSmallFontSize(context) * 0.9;
    final double valueFont = ResponsiveHelper.getSmallFontSize(context);
    final double sectionTitleFont = ResponsiveHelper.getMediumFontSize(context);
    final double cardRadius = ResponsiveHelper.getSmallSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          employee.displayName,
          style: TextStyle(fontSize: appBarTitleFont),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 650 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employee Info Card
                Card(
                  color: AppColors.surface,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                    side: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPaddingH,
                      vertical: cardPaddingV,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row(context, Icons.badge_outlined, 'Name', employee.displayName),
                        _divider(context),
                        _row(context, Icons.email_outlined, 'Login ID', employee.loginId),
                        _divider(context),
                        _row(context, Icons.perm_identity_outlined, 'Employee ID', employee.id),
                        _divider(context),
                        _row(context, Icons.business_outlined, 'Department', employee.department ?? 'General'),
                        _divider(context),
                        _row(context, Icons.work_outline, 'Designation', employee.designation ?? 'N/A'),
                        _divider(context),
                        _row(context, Icons.group_outlined, 'Role', employee.roleName ?? 'Employee'),
                        _divider(context),
                        _row(context, Icons.circle, 'Status',
                            employee.isActiveFlag ? 'Active' : 'Inactive',
                            valueColor: employee.isActiveFlag ? Colors.green : Colors.red),
                        _divider(context),
                        _row(context, Icons.person_outline, 'Created By', employee.createdBy),
                        _divider(context),
                        _row(context, Icons.calendar_today_outlined, 'Created Date', employee.createdDate),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: verticalPadding * 1.25),

                // Attendance Summary Card
                Card(
                  color: AppColors.surface,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                    side: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPaddingH,
                      vertical: cardPaddingV,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Attendance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            fontSize: sectionTitleFont,
                          ),
                        ),
                        SizedBox(height: verticalPadding * 0.75),
                        _divider(context),
                        _row(context, Icons.calendar_today_outlined, 'Date', date),
                        _divider(context),
                        _row(context, Icons.access_time_outlined, 'Punch In', punchIn,
                            valueColor: punchIn != '-' ? AppColors.info : AppColors.onSurfaceVariant),
                        _divider(context),
                        _row(context, Icons.access_time_outlined, 'Punch Out', punchOut,
                            valueColor: punchOut != '-' ? AppColors.warning : AppColors.onSurfaceVariant),
                        _divider(context),
                        _row(context, Icons.timer_outlined, 'Work Hours', workHours,
                            valueColor: workHours != '-' ? AppColors.warning : AppColors.onSurfaceVariant),
                        _divider(context),
                        _row(context, Icons.circle, 'Status', status,
                            valueColor: status == 'Present' ? Colors.green
                                : status == 'Absent' ? Colors.red : AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    final labelFont = ResponsiveHelper.getSmallFontSize(context) * 0.9;
    final valueFont = ResponsiveHelper.getSmallFontSize(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSmallSpacing(context) * 0.75),
      child: Row(children: [
        Icon(icon, size: ResponsiveHelper.getWidthPercentage(context, 5), color: AppColors.primary),
        SizedBox(width: ResponsiveHelper.getWidthPercentage(context, 3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: labelFont, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context) * 0.3),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFont,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _divider(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSmallSpacing(context) * 0.8),
    child: const Divider(height: 1),
  );
}