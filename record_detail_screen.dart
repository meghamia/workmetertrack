
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_client.dart';
import '../utils/report_generator.dart';
import '../controllers/records_controller.dart';
import '../theme/app_color.dart';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

//
// class RecordDetailScreen extends StatelessWidget {
//   final PunchPair pair;
//
//   const RecordDetailScreen({super.key, required this.pair});
//
//   // DOWNLOAD DIALOG
//
//
//   void _showDownloadDialog(BuildContext screenContext) {
//     showDialog<void>(
//       context: screenContext,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Download Report'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(
//                   Icons.picture_as_pdf,
//                   color: Colors.red,
//                 ),
//                 title: const Text('PDF'),
//                 subtitle: const Text('Table format (.pdf)'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateReport(screenContext, ReportFormat.pdf);
//                 },
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(
//                   Icons.table_chart,
//                   color: Colors.green,
//                 ),
//                 title: const Text('Excel'),
//                 subtitle: const Text('Table format (.xlsx)'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateReport(screenContext, ReportFormat.excel);
//                 },
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: const Icon(Icons.table_chart, color: Colors.orange),
//                 title: const Text('CSV'),
//                 subtitle: const Text('Single record - spreadsheet format'),
//                 onTap: () {
//                   Navigator.of(dialogContext).pop();
//                   _generateReport(screenContext, ReportFormat.csv);
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
//   // GENERATE
//
//   Future<void> _generateReport(
//       BuildContext context,
//       ReportFormat format,
//       ) async {
//     final messenger = ScaffoldMessenger.of(context);
//
//     _showLoading(format);
//
//     File file;
//     try {
//       // file = format == ReportFormat.pdf
//       //     ? await ReportGenerator.generateSingleRecordPdf(pair)
//       //     : await ReportGenerator.generateSingleRecordExcel(pair);
//       file = format == ReportFormat.pdf
//           ? await ReportGenerator.generateSingleRecordPdf(pair)
//           : format == ReportFormat.excel
//           ? await ReportGenerator.generateSingleRecordExcel(pair)
//           : await ReportGenerator.generateSingleRecordCsv(pair);
//     } catch (e) {
//       _closeLoading();
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
//     _closeLoading();
//
//     if (!context.mounted) return;
//     _showSavedDialog(context, file);
//   }
//
//   void _showLoading(ReportFormat format) {
//     Get.dialog<void>(
//       Dialog(
//         //barrierDismissible: false,
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text(
//                 format == ReportFormat.pdf
//                     ? 'Generating PDF...'
//                     : format == ReportFormat.excel
//                     ? 'Generating Excel...'
//                     : 'Generating CSV...',
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _closeLoading() {
//     if (Get.isDialogOpen == true) {
//       Get.back<void>();
//     }
//   }
//
//   // SAVED DIALOG  → Share / Open
//
//   void _showSavedDialog(BuildContext context, File file) {
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Row(
//             children: <Widget>[
//               Icon(Icons.check_circle, color: Colors.green),
//               SizedBox(width: 8),
//               Text('Report Saved'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 file.uri.pathSegments.last,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 file.path,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton.icon(
//               icon: const Icon(Icons.ios_share, size: 18),
//               label: const Text('Share'),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 await Share.shareXFiles(
//                   <XFile>[XFile(file.path)],
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
//
//   // UI
//
//   @override
//   Widget build(BuildContext context) {
//     final hasInPhoto =
//         pair.inPhotoPath != null && pair.inPhotoPath!.isNotEmpty;
//     final hasOutPhoto =
//         pair.outPhotoPath != null && pair.outPhotoPath!.isNotEmpty;
//
//     return Scaffold(
//       backgroundColor: AppColors.surfaceVariant,
//       appBar: AppBar(
//         title: const Text('Punch Details'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.download),
//             tooltip: 'Download Report',
//             onPressed: () => _showDownloadDialog(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // ── User Info ──
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.divider),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   _infoRow(
//                     Icons.email_outlined,
//                     'Email',
//                     pair.loginId,
//                   ),
//                   _divider(),
//                   _infoRow(
//                     Icons.calendar_today_outlined,
//                     'Date',
//                     pair.formattedDate,
//                   ),
//                   _divider(),
//                   _infoRow(
//                     Icons.location_on_outlined,
//                     'Location',
//                     pair.location,
//                   ),
//                   _divider(),
//                   _infoRow(
//                     Icons.my_location_rounded,
//                     'Coordinates',
//                     'Lat: ${pair.latitude.toStringAsFixed(6)}, '
//                         'Lng: ${pair.longitude.toStringAsFixed(6)}',
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // ── Punch IN ──
//             Text(
//               'Punch IN',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.info,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _punchSection(
//               time: pair.inTime,
//               photoPath: pair.inPhotoPath,
//               hasPhoto: hasInPhoto,
//             ),
//
//             const SizedBox(height: 16),
//
//             // ── Punch OUT ──
//             Text(
//               'Punch OUT',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: pair.outRecord != null
//                     ? AppColors.warning
//                     : AppColors.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _punchSection(
//               time: pair.outRecord != null ? pair.outTime : '-',
//               photoPath: pair.outPhotoPath,
//               hasPhoto: hasOutPhoto,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _punchSection({
//   //   required String time,
//   //   String? photoPath,
//   //   required bool hasPhoto,
//   // }) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: <Widget>[
//   //       Container(
//   //         width: double.infinity,
//   //         padding: const EdgeInsets.all(16),
//   //         decoration: BoxDecoration(
//   //           color: AppColors.surface,
//   //           borderRadius: BorderRadius.circular(16),
//   //           border: Border.all(color: AppColors.divider),
//   //         ),
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: <Widget>[
//   //             _infoRow(Icons.access_time_rounded, 'Time', time),
//   //           ],
//   //         ),
//   //       ),
//   //       if (hasPhoto) ...<Widget>[
//   //         const SizedBox(height: 8),
//   //         ClipRRect(
//   //           borderRadius: BorderRadius.circular(12),
//   //           child: Image.file(
//   //             File(photoPath!),
//   //             width: double.infinity,
//   //             height: 200,
//   //             fit: BoxFit.cover,
//   //             errorBuilder: (_, __, ___) => _noPhoto(),
//   //           ),
//   //         ),
//   //       ],
//   //     ],
//   //   );
//   // }
//
//
//   Widget _punchSection({
//     required String time,
//     String? photoPath,
//     required bool hasPhoto,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppColors.divider),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               _infoRow(Icons.access_time_rounded, 'Time', time),
//             ],
//           ),
//         ),
//         if (hasPhoto) ...<Widget>[
//           const SizedBox(height: 8),
//           FutureBuilder<String?>(
//             future: Get.find<ApiClient>().fetchAttendanceImage(photoPath!),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Container(
//                   height: 200,
//                   color: Colors.grey[200],
//                   child: const Center(child: CircularProgressIndicator()),
//                 );
//               }
//               if (snapshot.hasData && snapshot.data != null) {
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(
//                     File(snapshot.data!),
//                     width: double.infinity,
//                     height: 200,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => _noPhoto(),
//                   ),
//                 );
//               }
//               return _noPhoto();
//             },
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _noPhoto() {
//     return Container(
//       width: double.infinity,
//       height: 200,
//       color: Colors.grey[200],
//       child: const Center(
//         child: Icon(
//           Icons.image_not_supported_outlined,
//           size: 48,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }
//
//   Widget _divider() => const Padding(
//     padding: EdgeInsets.symmetric(vertical: 10),
//     child: Divider(height: 1),
//   );
//
//   Widget _infoRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: AppColors.onSurfaceVariant,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value.isEmpty ? '-' : value,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_client.dart';
import '../utils/report_generator.dart';
import '../controllers/records_controller.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class RecordDetailScreen extends StatelessWidget {
  final PunchPair pair;

  const RecordDetailScreen({super.key, required this.pair});

  // DOWNLOAD DIALOG

  void _showDownloadDialog(BuildContext screenContext) {
    final isWide = ResponsiveHelper.screenWidth(screenContext) >= 600;
    showDialog<void>(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Download Report',
            style: TextStyle(fontSize: ResponsiveHelper.getMediumFontSize(screenContext)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),
                title: const Text('PDF'),
                subtitle: const Text('Table format (.pdf)'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateReport(screenContext, ReportFormat.pdf);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.table_chart,
                  color: Colors.green,
                ),
                title: const Text('Excel'),
                subtitle: const Text('Table format (.xlsx)'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateReport(screenContext, ReportFormat.excel);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_chart, color: Colors.orange),
                title: const Text('CSV'),
                subtitle: const Text('Single record - spreadsheet format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generateReport(screenContext, ReportFormat.csv);
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

  // GENERATE

  Future<void> _generateReport(
      BuildContext context,
      ReportFormat format,
      ) async {
    final messenger = ScaffoldMessenger.of(context);

    _showLoading(context, format);

    File file;
    try {
      file = format == ReportFormat.pdf
          ? await ReportGenerator.generateSingleRecordPdf(pair)
          : format == ReportFormat.excel
          ? await ReportGenerator.generateSingleRecordExcel(pair)
          : await ReportGenerator.generateSingleRecordCsv(pair);
    } catch (e) {
      _closeLoading();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Export failed: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    _closeLoading();

    if (!context.mounted) return;
    _showSavedDialog(context, file);
  }

  void _showLoading(BuildContext context , ReportFormat format) {
    Get.dialog<void>(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSmallSpacing(context) * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
              Text(
                format == ReportFormat.pdf
                    ? 'Generating PDF...'
                    : format == ReportFormat.excel
                    ? 'Generating Excel...'
                    : 'Generating CSV...',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: ResponsiveHelper.getSmallFontSize(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _closeLoading() {
    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
  }

  // SAVED DIALOG  → Share / Open

  void _showSavedDialog(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: ResponsiveHelper.getSmallSpacing(context)),
              Text(
                'Report Saved',
                style: TextStyle(fontSize: ResponsiveHelper.getMediumFontSize(context)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                file.uri.pathSegments.last,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.getSmallFontSize(context),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
              Text(
                file.path,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.85,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.ios_share, size: ResponsiveHelper.getSmallFontSize(context)),
              label: const Text('Share'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Share.shareXFiles(
                  <XFile>[XFile(file.path)],
                  text: 'Attendance Report',
                );
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.open_in_new, size: ResponsiveHelper.getSmallFontSize(context)),
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

  // UI

  @override
  Widget build(BuildContext context) {
    final hasInPhoto =
        pair.inPhotoPath != null && pair.inPhotoPath!.isNotEmpty;
    final hasOutPhoto =
        pair.outPhotoPath != null && pair.outPhotoPath!.isNotEmpty;

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 10 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);
    final double sectionTitleFont =
    ResponsiveHelper.getMediumFontSize(context);
    final double bodyFont = ResponsiveHelper.getSmallFontSize(context);
    final double imageHeight =
    ResponsiveHelper.getHeightPercentage(context, 22).clamp(150.0, 220.0);
    final double iconSize = ResponsiveHelper.getWidthPercentage(context, 5);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Punch Details',
          style: TextStyle(fontSize: sectionTitleFont* 1.5),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Report',
            onPressed: () => _showDownloadDialog(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 700 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── User Info ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(verticalPadding * 1.25),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _infoRow(
                        context,
                        Icons.email_outlined,
                        'Email',
                        pair.loginId,
                      ),
                      _divider(context),
                      _infoRow(
                        context,
                        Icons.calendar_today_outlined,
                        'Date',
                        pair.formattedDate,
                      ),
                      _divider(context),
                      _infoRow(
                        context,
                        Icons.location_on_outlined,
                        'Location',
                        pair.location,
                      ),
                      _divider(context),
                      _infoRow(
                        context,
                        Icons.my_location_rounded,
                        'Coordinates',
                        'Lat: ${pair.latitude.toStringAsFixed(6)}, '
                            'Lng: ${pair.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalPadding * 1.25),

                // ── Punch IN ──
                Text(
                  'Punch IN',
                  style: TextStyle(
                    fontSize: sectionTitleFont,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: verticalPadding * 0.75),
                _punchSection(
                  context: context,
                  time: pair.inTime,
                  photoPath: pair.inPhotoPath,
                  hasPhoto: hasInPhoto,
                  imageHeight: imageHeight,
                  iconSize: iconSize,
                ),

                SizedBox(height: verticalPadding * 1.25),

                // ── Punch OUT ──
                Text(
                  'Punch OUT',
                  style: TextStyle(
                    fontSize: sectionTitleFont,
                    fontWeight: FontWeight.bold,
                    color: pair.outRecord != null
                        ? AppColors.warning
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: verticalPadding * 0.75),
                _punchSection(
                  context: context,
                  time: pair.outRecord != null ? pair.outTime : '-',
                  photoPath: pair.outPhotoPath,
                  hasPhoto: hasOutPhoto,
                  imageHeight: imageHeight,
                  iconSize: iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _punchSection({
    required BuildContext context,
    required String time,
    String? photoPath,
    required bool hasPhoto,
    required double imageHeight,
    required double iconSize,
  }) {
    final bodyFont = ResponsiveHelper.getSmallFontSize(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveHelper.getSmallSpacing(context) * 1.25),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _infoRow(context, Icons.access_time_rounded, 'Time', time),
            ],
          ),
        ),
        if (hasPhoto) ...<Widget>[
          SizedBox(height: verticalPadding(context) * 0.75),
          FutureBuilder<String?>(
            future: Get.find<ApiClient>().fetchAttendanceImage(photoPath!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: imageHeight,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(snapshot.data!),
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _noPhoto(context, imageHeight),
                  ),
                );
              }
              return _noPhoto(context, imageHeight);
            },
          ),
        ],
      ],
    );
  }

  Widget _noPhoto(BuildContext context, double imageHeight) {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      vertical: ResponsiveHelper.getSmallSpacing(context) * 0.8,
    ),
    child: const Divider(height: 1),
  );

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final bodyFont = ResponsiveHelper.getSmallFontSize(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: ResponsiveHelper.getWidthPercentage(context, 5), color: AppColors.onSurfaceVariant),
        SizedBox(width: ResponsiveHelper.getWidthPercentage(context, 3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: bodyFont * 0.9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSmallSpacing(context) * 0.3),
              Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  fontSize: bodyFont,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double verticalPadding(BuildContext context) =>
      ResponsiveHelper.getSmallSpacing(context);
}