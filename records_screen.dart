

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track_attendance_app/screens/record_detail_screen.dart';

import '../controllers/records_controller.dart';
import '../theme/app_color.dart';
import '../utils/report_generator.dart';



import '../utils/responsive_helper.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  // DOWNLOAD DIALOG

  void _showDownloadDialog(
      BuildContext screenContext,
      RecordsController controller,
      ) {
    showDialog<void>(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Download Report'),
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
                subtitle: const Text('All records - table format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generate(
                    screenContext,
                    controller,
                    ReportFormat.pdf,
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.table_chart,
                  color: Colors.green,
                ),
                title: const Text('Excel'),
                subtitle: const Text('All records - table format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generate(
                    screenContext,
                    controller,
                    ReportFormat.excel,
                  );
                },
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_chart, color: Colors.orange),
                title: const Text('CSV'),
                subtitle: const Text('All records - spreadsheet format'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _generate(
                    screenContext,
                    controller,
                    ReportFormat.csv,
                  );
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


  Future<void> _generate(
      BuildContext context,
      RecordsController controller,
      ReportFormat format,
      ) async {
    final messenger = ScaffoldMessenger.of(context);
    final pairs = controller.groupedRecords;

    if (pairs.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('No records available to export.'),
        ),
      );
      return;
    }
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    File file;
    try {
      file = format == ReportFormat.pdf
          ? await ReportGenerator.generateAllRecordsPdf(pairs)
          : format == ReportFormat.excel
          ? await ReportGenerator.generateAllRecordsExcel(pairs)
          : await ReportGenerator.generateAllRecordsCsv(pairs);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back<void>();
      }
      debugPrint('=== EXPORT FAILED ===');
      debugPrint('$e');
      debugPrintStack(label: 'STACK', maxFrames: 30);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Export failed: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }

    if (!context.mounted) return;
    _showSavedDialog(context, file);
  }


  // SAVED DIALOG  -> Share / Open

  void _showSavedDialog(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Report Saved'),
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
                  fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.8,
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
                await SharePlus.instance.share(
                  ShareParams(
                    text: 'Attendance Records',
                    files: <XFile>[XFile(file.path)],
                  ),
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
    final controller = Get.find<RecordsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refresh();
    });

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 8 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);
    final double titleFont = ResponsiveHelper.getMediumFontSize(context);
    final double bodyFont = ResponsiveHelper.getSmallFontSize(context);
    final double chipGap = ResponsiveHelper.getSmallSpacing(context) * 0.75;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isAdmin.value ? 'Today Present' : 'My Attendance',
          style: TextStyle(fontSize: titleFont * 1.5),
        )),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Report',
            onPressed: () => _showDownloadDialog(context, controller),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 700 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Filter chips ──
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: bodyFont * 1.05,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: verticalPadding * 0.75),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _FilterChip(
                              label: 'Day',
                              filter: RecordFilter.day,
                              controller: controller,
                            ),
                            SizedBox(width: chipGap),
                            _FilterChip(
                              label: 'Week',
                              filter: RecordFilter.week,
                              controller: controller,
                            ),
                            SizedBox(width: chipGap),
                            _FilterChip(
                              label: 'Month',
                              filter: RecordFilter.month,
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      // ── Search Bar ──
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search email, date, time, location...',
                          prefixIcon:
                          Icon(Icons.search, color: AppColors.onSurfaceVariant),
                          suffixIcon:
                          Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear,
                                color: AppColors.onSurfaceVariant),
                            onPressed: () => controller.clearSearch(),
                          )
                              : const SizedBox.shrink()),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 1.2,
                            vertical: verticalPadding * 1.2,
                          ),
                        ),
                        onChanged: controller.setSearchQuery,
                        style: TextStyle(color: AppColors.onSurface, fontSize: bodyFont),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalPadding),

                // ── Paired records list ──
                Obx(() {

                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }


                  if (controller.groupedRecords.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.history_rounded,
                            size: ResponsiveHelper.getWidthPercentage(context, 18),
                            color: AppColors.onSurfaceVariant.withOpacity(0.3),
                          ),
                          SizedBox(height: verticalPadding * 1.5),
                          Text(
                            'No records found',
                            style: TextStyle(
                              fontSize: titleFont,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: verticalPadding * 0.75),
                          Text(
                            'Mark your first attendance to see records here',
                            style: TextStyle(
                              fontSize: bodyFont,
                              color:
                              AppColors.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: controller.groupedRecords.length,
                    itemBuilder: (context, index) {
                      final pair = controller.groupedRecords[index];
                      return _RecordTile(pair: pair);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// FILTER CHIP

class _FilterChip extends StatelessWidget {
  final String label;
  final RecordFilter filter;
  final RecordsController controller;

  const _FilterChip({
    required this.label,
    required this.filter,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bodyFont = ResponsiveHelper.getSmallFontSize(context);
    return Obx(
          () => FilterChip(
        label: Text(label, style: TextStyle(fontSize: bodyFont)),
        selected: controller.currentFilter.value == filter,
        onSelected: (_) => controller.setFilter(filter),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: controller.currentFilter.value == filter
              ? AppColors.primary
              : AppColors.onSurfaceVariant,
          fontWeight: controller.currentFilter.value == filter
              ? FontWeight.w600
              : FontWeight.normal,
        ),
        backgroundColor: AppColors.surfaceVariant,
        side: BorderSide(
          color: controller.currentFilter.value == filter
              ? AppColors.primary
              : AppColors.divider,
        ),
      ),
    );
  }
}
// PAIRED TILE — one user's IN + OUT for the same day
// Tap -> RecordDetailScreen

class _RecordTile extends StatelessWidget {
  final PunchPair pair;

  const _RecordTile({required this.pair});

  @override
  Widget build(BuildContext context) {
    final bodyFont = ResponsiveHelper.getSmallFontSize(context);
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.divider,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSmallSpacing(context) * 0.75),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getWidthPercentage(context, 4),
          vertical: ResponsiveHelper.getSmallSpacing(context) * 0.6,
        ),
        leading: CircleAvatar(
          radius: ResponsiveHelper.getWidthPercentage(context, 5),
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              pair.loginId.isNotEmpty ? pair.loginId : 'Unknown user',
              style: TextStyle(
                fontSize: bodyFont * 1.05,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSmallSpacing(context) * 0.3),
            Text(
              pair.formattedDate,
              style: TextStyle(
                fontSize: bodyFont * 0.9,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            if (pair.inRecord != null)
              Text(
                'IN: ${pair.inTime}',
                style: TextStyle(
                  fontSize: bodyFont * 0.9,
                  color: AppColors.info,
                ),
              ),
            if (pair.inRecord != null && pair.outRecord != null)
              const Text(
                '  |  ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            if (pair.outRecord != null)
              Text(
                'OUT: ${pair.outTime}',
                style: TextStyle(
                  fontSize: bodyFont * 0.9,
                  color: AppColors.warning,
                ),
              ),
            if (pair.inRecord == null && pair.outRecord == null)
              Text(
                '-',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: ResponsiveHelper.getSmallFontSize(context),
          color: AppColors.onSurfaceVariant.withOpacity(0.4),
        ),
        onTap: () {
          Get.to(() => RecordDetailScreen(pair: pair));
        },
      ),
    );
  }
}