import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:track_attendance_app/screens/record_detail_screen.dart';

import '../controllers/admin_report_controller.dart';
import '../controllers/records_controller.dart';
import '../models/attendance_record.dart';
import '../models/auth/employee_model.dart';
import '../services/api_client.dart';
import '../theme/app_color.dart';
import '../utils/report_generator.dart';
import 'employee_detail_Screen.dart';
//
// class AdminReportScreen extends StatelessWidget {
//   const AdminReportScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AdminReportController>();
//
//     return Scaffold(
//       backgroundColor: AppColors.surfaceVariant,
//       appBar: AppBar(
//         title: const Text('Attendance Reports'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             tooltip: 'Download Report',
//             onPressed: () => _showDownloadDialog(context, controller),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         return Column(
//           children: [
//             // Search Bar
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: AppColors.surface,
//               child: TextField(
//                 controller: controller.searchController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: AppColors.surfaceVariant,
//                   prefixIcon: const Icon(Icons.search),
//                   hintText: 'Search name, ID, or date...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: AppColors.divider,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//                 onChanged: controller.setSearchQuery,
//               ),
//             ),
//
//             // Attendance Records
//             Expanded(
//               child: controller.filteredRecords.isEmpty
//                   ? const Center(
//                       child: Text('No attendance records found'),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: controller.filteredRecords.length,
//                       itemBuilder: (context, index) {
//                         final record = controller.filteredRecords[index];
//
//                         final status =
//                             record['status']?.toString() ?? 'Unknown';
//
//                         return Card(
//                           color: AppColors.surface,
//                           elevation: 1,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             side: BorderSide(
//                               color: AppColors.divider,
//                               width: 0.5,
//                             ),
//                           ),
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             title: Text(
//                               record['name']?.toString() ?? 'Unknown',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             subtitle: Padding(
//                               padding: const EdgeInsets.only(top: 6),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'ID: ${record['id'] ?? 'N/A'}',
//                                   ),
//                                   Text(
//                                     'Date: ${record['date'] ?? 'N/A'}',
//                                   ),
//                                   Text(
//                                     'IN: ${record['punchIn'] ?? '-'}'
//                                     ' | OUT: ${record['punchOut'] ?? '-'}',
//                                   ),
//                                   Text(
//                                     'Hours: ${record['workHours'] ?? '-'}',
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             trailing: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _statusColor(status).withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 status,
//                                 style: TextStyle(
//                                   color: _statusColor(status),
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             onTap: () {
//                               debugPrint(
//                                   '=== TILE TAPPED === employeeId: ${record['id']}');
//                               final emp = record['employee'] as Employee?;
//                               debugPrint('Employee object: $emp');
//                               if (emp != null) {
//                                 Get.to(() => EmployeeDetailScreen(
//                                     employee: emp, record: record));
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                       content: Text(
//                                           'No employee data for ${record['id']}')),
//                                 );
//                               }
//                             },
//                             // onTap: () => _showEmployeeDetailsDialog(
//                             //   context,
//                             //   record['id']?.toString() ?? '',
//                             //   record['name']?.toString() ?? 'Unknown',
//                             // ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
//
//   Future<void> _openAttendanceDetails(
//     Map<String, dynamic> record,
//   ) async {
//     if (record['hasRecords'] != true) {
//       Get.snackbar(
//         'No Attendance',
//         'This employee has no attendance record to display.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//
//     final employeeId = record['id']?.toString() ?? '';
//     final date = record['date']?.toString() ?? '';
//
//     if (employeeId.isEmpty || date.isEmpty || date == '--') {
//       Get.snackbar(
//         'Invalid Record',
//         'Employee ID or attendance date is missing.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//
//     final apiClient = Get.find<ApiClient>();
//
//     try {
//       final parsedDate = DateTime.tryParse(date);
//
//       if (parsedDate == null) {
//         Get.snackbar(
//           'Invalid Date',
//           'Could not identify the attendance date: $date',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }
//
//       final attendanceRecords = await apiClient.fetchAttendanceHistory(
//         employeeId: employeeId,
//         startDate: parsedDate,
//         endDate: parsedDate,
//       );
//
//       AttendanceRecord? inRecord;
//       AttendanceRecord? outRecord;
//
//       for (final attendance in attendanceRecords) {
//         if (attendance.employeeId != employeeId) continue;
//
//         if (attendance.type.toUpperCase() == 'IN') {
//           inRecord = attendance;
//         } else if (attendance.type.toUpperCase() == 'OUT') {
//           outRecord = attendance;
//         }
//       }
//
//       if (inRecord == null && outRecord == null) {
//         Get.snackbar(
//           'Record Not Found',
//           'No attendance details were returned for $date.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }
//
//       final pair = PunchPair(
//         inRecord: inRecord,
//         outRecord: outRecord,
//       );
//
//       Get.to(() => RecordDetailScreen(pair: pair));
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Could not load attendance details: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   Color _statusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'present':
//         return Colors.green;
//       case 'absent':
//         return Colors.red;
//       case 'half day':
//       case 'halfday':
//         return Colors.orange;
//       default:
//         return AppColors.onSurfaceVariant;
//     }
//   }
//
//   Future<void> _showEmployeeDetailsDialog(
//     BuildContext context,
//     String employeeId,
//     String employeeName,
//   ) async {
//     if (employeeId.isEmpty) return;
//
//     final apiClient = Get.find<ApiClient>();
//
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return FutureBuilder<Map<String, dynamic>?>(
//           future: apiClient.fetchEmployeeDetails(
//             employeeId: employeeId,
//           ),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const AlertDialog(
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Text('Loading employee details...'),
//                   ],
//                 ),
//               );
//             }
//
//             if (snapshot.hasError ||
//                 !snapshot.hasData ||
//                 snapshot.data == null) {
//               return AlertDialog(
//                 title: const Text('Error'),
//                 content: const Text(
//                   'Failed to load employee details.',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(dialogContext).pop(),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               );
//             }
//
//             final data = snapshot.data!;
//
//             return AlertDialog(
//               title: Text(
//                 data['employee_name']?.toString() ?? employeeName,
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildDetailRow(
//                       'ID',
//                       data['id']?.toString() ?? 'N/A',
//                     ),
//                     _buildDetailRow(
//                       'Login ID',
//                       data['login_id']?.toString() ?? 'N/A',
//                     ),
//                     _buildDetailRow(
//                       'Department',
//                       data['department']?.toString() ?? 'General',
//                     ),
//                     _buildDetailRow(
//                       'Designation',
//                       data['designation']?.toString() ?? 'N/A',
//                     ),
//                     _buildDetailRow(
//                       'Role',
//                       data['role_name']?.toString() ??
//                           data['role']?.toString() ??
//                           'Employee',
//                     ),
//                     _buildDetailRow(
//                       'Status',
//                       _isEmployeeActive(data['is_active'])
//                           ? 'Active'
//                           : 'Inactive',
//                     ),
//                     _buildDetailRow(
//                       'Created By',
//                       data['created_by']?.toString() ?? 'N/A',
//                     ),
//                     _buildDetailRow(
//                       'Created Date',
//                       data['created_date']?.toString() ?? 'N/A',
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                   child: const Text('Close'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   bool _isEmployeeActive(dynamic value) {
//     if (value == true || value == 1) {
//       return true;
//     }
//
//     final normalized = value?.toString().toLowerCase().trim();
//
//     return normalized == '1' || normalized == 'true' || normalized == 't';
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 13,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 13),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDownloadDialog(
//       BuildContext context, AdminReportController controller) {
//     final records = controller.allRecords.toList();
//     if (records.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No records to download')),
//       );
//       return;
//     }
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Download Report'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
//                 title: const Text('PDF'),
//                 subtitle: const Text('All employees - table format'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateAdminReport(context, records, ReportFormat.pdf);
//                 },
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.table_chart, color: Colors.green),
//                 title: const Text('Excel'),
//                 subtitle: const Text('All employees - table format'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateAdminReport(context, records, ReportFormat.excel);
//                 },
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.table_chart, color: Colors.orange),
//                 title: const Text('CSV'),
//                 subtitle: const Text('All employees - spreadsheet format'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateAdminReport(context, records, ReportFormat.csv);
//                 },
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _generateAdminReport(
//     BuildContext context,
//     List<Map<String, dynamic>> records,
//     ReportFormat format,
//   ) async {
//     final messenger = ScaffoldMessenger.of(context);
//     Get.dialog<void>(
//       Dialog(
//         child: const Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Generating report...'),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     File file;
//     try {
//       file = format == ReportFormat.pdf
//           ? await ReportGenerator.generateAdminReportPdf(records)
//           : await ReportGenerator.generateAdminReportExcel(records);
//     } catch (e) {
//       if (Get.isDialogOpen == true) Get.back<void>();
//       messenger.showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red.shade700,
//           content: Text('Export failed: $e'),
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       return;
//     }
//
//     if (Get.isDialogOpen == true) Get.back<void>();
//     _showSavedDialog(context, file);
//   }
//
//   void _showSavedDialog(BuildContext context, File file) {
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.green),
//               SizedBox(width: 8),
//               Text('Report Saved'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(file.uri.pathSegments.last,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 13)),
//               const SizedBox(height: 8),
//               Text(file.path,
//                   style: const TextStyle(fontSize: 10, color: Colors.grey)),
//             ],
//           ),
//           actions: [
//             TextButton.icon(
//               icon: const Icon(Icons.ios_share, size: 18),
//               label: const Text('Share'),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 await Share.shareXFiles(
//                   [XFile(file.path)],
//                   text: 'Attendance Report',
//                 );
//               },
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.open_in_new, size: 18),
//               label: const Text('Open'),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 await OpenFilex.open(file.path);
//               },
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:track_attendance_app/screens/record_detail_screen.dart';

import '../controllers/admin_report_controller.dart';
import '../controllers/records_controller.dart';
import '../models/attendance_record.dart';
import '../models/auth/employee_model.dart';
import '../services/api_client.dart';
import '../theme/app_color.dart';
import '../utils/report_generator.dart';
import '../utils/responsive_helper.dart';
import 'employee_detail_Screen.dart';

class AdminReportScreen extends StatelessWidget {
  const AdminReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminReportController>();

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 8 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);
    final double appBarTitleFont = ResponsiveHelper.getMediumFontSize(context);
    final double searchPaddingV =
        ResponsiveHelper.getSmallSpacing(context) * 1.25;
    final double listPaddingH = ResponsiveHelper.getWidthPercentage(context, 4);
    final double listPaddingV = ResponsiveHelper.getSmallSpacing(context);
    final double cardMarginBottom =
        ResponsiveHelper.getSmallSpacing(context) * 0.75;
    final double tileContentPaddingH =
    ResponsiveHelper.getWidthPercentage(context, 4);
    final double tileContentPaddingV =
        ResponsiveHelper.getSmallSpacing(context) * 0.6;
    final double titleFont = ResponsiveHelper.getMediumFontSize(context);
    final double subtitleFont = ResponsiveHelper.getSmallFontSize(context);
    final double statusFont = ResponsiveHelper.getSmallFontSize(context) * 0.85;
    final double cardRadius = ResponsiveHelper.getSmallSpacing(context);
    final double statusPillRadius = ResponsiveHelper.getSmallSpacing(context);
    final double statusPillPaddingH =
    ResponsiveHelper.getWidthPercentage(context, 3);
    final double statusPillPaddingV =
        ResponsiveHelper.getSmallSpacing(context) * 0.5;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Attendance Reports',
          style: TextStyle(fontSize: titleFont * 1.5),

        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: ResponsiveHelper.getWidthPercentage(context, 5),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              size: ResponsiveHelper.getWidthPercentage(context, 5),
            ),
            tooltip: 'Download Report',
            onPressed: () => _showDownloadDialog(context, controller),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 700 : double.infinity,
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: searchPaddingV,
                  ),
                  color: AppColors.surface,
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      prefixIcon: Icon(
                        Icons.search,
                        size: ResponsiveHelper.getWidthPercentage(context, 5),
                      ),
                      hintText: 'Search name, ID, or date...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    onChanged: controller.setSearchQuery,
                    style: TextStyle(fontSize: subtitleFont),
                  ),
                ),

                // Attendance Records
                Expanded(
                  child: controller.filteredRecords.isEmpty
                      ? Center(
                    child: Text(
                      'No attendance records found',
                      style: TextStyle(
                        fontSize: subtitleFont,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: listPaddingH,
                      vertical: listPaddingV,
                    ),
                    itemCount: controller.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = controller.filteredRecords[index];

                      final status =
                          record['status']?.toString() ?? 'Unknown';

                      return Card(
                        color: AppColors.surface,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardRadius),
                          side: BorderSide(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        margin: EdgeInsets.only(bottom: cardMarginBottom),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: tileContentPaddingH,
                            vertical: tileContentPaddingV,
                          ),
                          title: Text(
                            record['name']?.toString() ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: titleFont,
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(
                              top: ResponsiveHelper
                                  .getSmallSpacing(context) * 0.75,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${record['id'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: subtitleFont),
                                ),
                                Text(
                                  'Date: ${record['date'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: subtitleFont),
                                ),
                                Text(
                                  'IN: ${record['punchIn'] ?? '-'}'
                                      ' | OUT: ${record['punchOut'] ?? '-'}',
                                  style: TextStyle(fontSize: subtitleFont),
                                ),
                                Text(
                                  'Hours: ${record['workHours'] ?? '-'}',
                                  style: TextStyle(fontSize: subtitleFont),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: statusPillPaddingH,
                              vertical: statusPillPaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  statusPillRadius),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontSize: statusFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () {
                            debugPrint(
                                '=== TILE TAPPED === employeeId: ${record['id']}');
                            final emp =
                            record['employee'] as Employee?;
                            debugPrint('Employee object: $emp');
                            if (emp != null) {
                              Get.to(() => EmployeeDetailScreen(
                                  employee: emp, record: record));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'No employee data for ${record['id']}')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _openAttendanceDetails(
      Map<String, dynamic> record,
      ) async {
    if (record['hasRecords'] != true) {
      Get.snackbar(
        'No Attendance',
        'This employee has no attendance record to display.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final employeeId = record['id']?.toString() ?? '';
    final date = record['date']?.toString() ?? '';

    if (employeeId.isEmpty || date.isEmpty || date == '--') {
      Get.snackbar(
        'Invalid Record',
        'Employee ID or attendance date is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final apiClient = Get.find<ApiClient>();

    try {
      final parsedDate = DateTime.tryParse(date);

      if (parsedDate == null) {
        Get.snackbar(
          'Invalid Date',
          'Could not identify the attendance date: $date',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final attendanceRecords = await apiClient.fetchAttendanceHistory(
        employeeId: employeeId,
        startDate: parsedDate,
        endDate: parsedDate,
      );

      AttendanceRecord? inRecord;
      AttendanceRecord? outRecord;

      for (final attendance in attendanceRecords) {
        if (attendance.employeeId != employeeId) continue;

        if (attendance.type.toUpperCase() == 'IN') {
          inRecord = attendance;
        } else if (attendance.type.toUpperCase() == 'OUT') {
          outRecord = attendance;
        }
      }

      if (inRecord == null && outRecord == null) {
        Get.snackbar(
          'Record Not Found',
          'No attendance details were returned for $date.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final pair = PunchPair(
        inRecord: inRecord,
        outRecord: outRecord,
      );

      Get.to(() => RecordDetailScreen(pair: pair));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load attendance details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'half day':
      case 'halfday':
        return Colors.orange;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Future<void> _showEmployeeDetailsDialog(
      BuildContext context,
      String employeeId,
      String employeeName,
      ) async {
    if (employeeId.isEmpty) return;

    final apiClient = Get.find<ApiClient>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: apiClient.fetchEmployeeDetails(
            employeeId: employeeId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: ResponsiveHelper.getWidthPercentage(context, 6),
                      width: ResponsiveHelper.getWidthPercentage(context, 6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getSmallSpacing(context)),
                    Text(
                      'Loading employee details...',
                      style: TextStyle(
                          fontSize: ResponsiveHelper.getSmallFontSize(context)),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(
                      fontSize: ResponsiveHelper.getMediumFontSize(context)),
                ),
                content: const Text(
                  'Failed to load employee details.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            }

            final data = snapshot.data!;

            return AlertDialog(
              title: Text(
                data['employee_name']?.toString() ?? employeeName,
                style: TextStyle(
                    fontSize: ResponsiveHelper.getMediumFontSize(context)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow(
                      context,
                      'ID',
                      data['id']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      context,
                      'Login ID',
                      data['login_id']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      context,
                      'Department',
                      data['department']?.toString() ?? 'General',
                    ),
                    _buildDetailRow(
                      context,
                      'Designation',
                      data['designation']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      context,
                      'Role',
                      data['role_name']?.toString() ??
                          data['role']?.toString() ??
                          'Employee',
                    ),
                    _buildDetailRow(
                      context,
                      'Status',
                      _isEmployeeActive(data['is_active'])
                          ? 'Active'
                          : 'Inactive',
                    ),
                    _buildDetailRow(
                      context,
                      'Created By',
                      data['created_by']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      context,
                      'Created Date',
                      data['created_date']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isEmployeeActive(dynamic value) {
    if (value == true || value == 1) {
      return true;
    }

    final normalized = value?.toString().toLowerCase().trim();

    return normalized == '1' || normalized == 'true' || normalized == 't';
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final labelFont = ResponsiveHelper.getSmallFontSize(context);
    final valueFont = ResponsiveHelper.getSmallFontSize(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getSmallSpacing(context) * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: labelFont,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: valueFont),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(
      BuildContext context, AdminReportController controller) {
    final records = controller.allRecords.toList();
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records to download')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Download Report',
            style: TextStyle(
                fontSize: ResponsiveHelper.getMediumFontSize(context)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: ResponsiveHelper.getWidthPercentage(context, 5),
                ),
                title: const Text('PDF'),
                subtitle: const Text('All employees - table format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateAdminReport(context, records, ReportFormat.pdf);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.table_chart,
                  color: Colors.green,
                  size: ResponsiveHelper.getWidthPercentage(context, 5),
                ),
                title: const Text('Excel'),
                subtitle: const Text('All employees - table format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateAdminReport(context, records, ReportFormat.excel);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.table_chart,
                  color: Colors.orange,
                  size: ResponsiveHelper.getWidthPercentage(context, 5),
                ),
                title: const Text('CSV'),
                subtitle: const Text('All employees - spreadsheet format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateAdminReport(context, records, ReportFormat.csv);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAdminReport(
      BuildContext context,
      List<Map<String, dynamic>> records,
      ReportFormat format,
      ) async {
    final messenger = ScaffoldMessenger.of(context);
    Get.dialog<void>(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSmallSpacing(context) * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
              Text(
                'Generating report...',
                style: TextStyle(
                    fontSize: ResponsiveHelper.getSmallFontSize(context)),
              ),
            ],
          ),
        ),
      ),
    );

    File file;
    try {
      file = format == ReportFormat.pdf
          ? await ReportGenerator.generateAdminReportPdf(records)
          : await ReportGenerator.generateAdminReportExcel(records);
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back<void>();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Export failed: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (Get.isDialogOpen == true) Get.back<void>();
    _showSavedDialog(context, file);
  }

  void _showSavedDialog(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: ResponsiveHelper.getWidthPercentage(context, 2)),
              Text(
                'Report Saved',
                style: TextStyle(
                    fontSize: ResponsiveHelper.getMediumFontSize(context)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.uri.pathSegments.last,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getSmallFontSize(context)),
              ),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
              Text(
                file.path,
                style: TextStyle(
                    fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.85,
                    color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.ios_share,
                  size: ResponsiveHelper.getSmallFontSize(context)),
              label: const Text('Share'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Attendance Report',
                );
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.open_in_new,
                  size: ResponsiveHelper.getSmallFontSize(context)),
              label: const Text('Open'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await OpenFilex.open(file.path);
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}