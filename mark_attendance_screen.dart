import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mark_attendance_controller.dart';
import '../controllers/location_controller.dart';
import '../theme/app_color.dart';

//
// class MarkAttendanceScreen extends StatelessWidget {
//   const MarkAttendanceScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MarkAttendanceController>();
//     final locationController = Get.find<LocationController>();
//
//     /// FIX: Refresh day state when the screen becomes visible.
//     /// This ensures records saved during a prior app session are
//     /// recognized, and the OUT card is properly disabled if the
//     /// day is already complete.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.refreshDayState();
//     });
//
//     return Scaffold(
//       backgroundColor: AppColors.surfaceVariant,
//       appBar: AppBar(
//         title: const Text('Mark Attendance'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//       ),
//       body: Obx(() {
//         if (!controller.isDayStateLoaded.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final nextAction = controller.nextAction;
//         final isComplete = controller.isAttendanceCompleteToday;
//         final actionColor = isComplete
//             ? AppColors.successText
//             : (nextAction == 'IN' ? AppColors.info : AppColors.warning);
//         final actionIcon = isComplete
//             ? Icons.check_circle_rounded
//             : (nextAction == 'IN' ? Icons.login_rounded : Icons.logout_rounded);
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Tappable summary card
//               GestureDetector(
//                 onTap: controller.openCameraOrShowAlreadyMarked,
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         actionColor.withOpacity(0.15),
//                         actionColor.withOpacity(0.05),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: actionColor.withOpacity(0.3)),
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: actionColor.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Icon(actionIcon, size: 40, color: actionColor),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         isComplete
//                             ? 'Attendance Completed'
//                             : 'Next Action: $nextAction',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: actionColor,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         isComplete
//                             ? 'You have already marked your attendance today'
//                             : (nextAction == 'IN'
//                             ? 'Tap below to mark your check-in'
//                             : 'Tap below to mark your check-out'),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Location container
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.divider),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.location_on_rounded,
//                             color: AppColors.primary, size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Current Location',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Obx(() => Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             locationController.currentAddress.value,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: locationController
//                                   .currentAddress.value
//                                   .contains('Unable') ||
//                                   locationController
//                                       .currentAddress.value
//                                       .contains('Fetching') ||
//                                   locationController
//                                       .currentAddress.value
//                                       .contains('denied')
//                                   ? AppColors.errorText
//                                   : AppColors.onSurface,
//                             ),
//                           ),
//                         ),
//                         if (locationController.isLoading.value)
//                           const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         else
//                           IconButton(
//                             onPressed:
//                             locationController.getCurrentLocation,
//                             icon: Icon(Icons.refresh_rounded,
//                                 color: AppColors.primary),
//                             tooltip: 'Refresh location',
//                           ),
//                       ],
//                     )),
//                     const SizedBox(height: 12),
//                     Obx(() => LinearProgressIndicator(
//                       value: locationController
//                           .currentAddress.value
//                           .contains('Unable') ||
//                           locationController.currentAddress.value
//                               .contains('Fetching') ||
//                           locationController.currentAddress.value
//                               .contains('denied')
//                           ? 0.0
//                           : 1.0,
//                       backgroundColor: AppColors.divider,
//                       valueColor: AlwaysStoppedAnimation<Color>(actionColor),
//                     )),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Status message
//               Obx(() => Text(
//                 controller.statusMessage.value,
//                 style: TextStyle(
//                   color: controller.statusMessage.value.contains('Failed')
//                       ? AppColors.errorText
//                       : AppColors.successText,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               )),
//
//               const SizedBox(height: 24),
//
//               // Action button — DISABLED when day is complete
//               Obx(() => SizedBox(
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   // FIX: onPressed is null when complete — card is
//                   // non-interactive, not just visually different
//                   onPressed: isComplete
//                       ? null
//                       : controller.openCameraOrShowAlreadyMarked,
//                   icon: Icon(
//                     isComplete
//                         ? Icons.check_circle_rounded
//                         : Icons.camera_alt_rounded,
//                   ),
//                   label: Text(
//                     controller.isLoading.value
//                         ? 'Processing...'
//                         : (isComplete
//                         ? 'Attendance Already Marked'
//                         : 'Open Camera to Mark $nextAction'),
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                     isComplete ? AppColors.divider : actionColor,
//                     foregroundColor: isComplete
//                         ? AppColors.onSurfaceVariant
//                         : AppColors.onPrimary,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     elevation: 2,
//                     disabledBackgroundColor: actionColor.withOpacity(0.5),
//                   ),
//                 ),
//               )),
//
//               const SizedBox(height: 16),
//
//               // Last marked record
//               if (controller.lastTodayRecord != null)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.successSurface,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                         color: AppColors.successText.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle_rounded,
//                           color: AppColors.successText),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Last marked: ${controller.lastTodayRecord!.type}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.successText,
//                               ),
//                             ),
//                             Text(
//                               'at ${controller.lastTodayRecord!.formattedTime}',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: AppColors.successText.withOpacity(0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mark_attendance_controller.dart';
import '../controllers/location_controller.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

class MarkAttendanceScreen extends StatelessWidget {
  const MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarkAttendanceController>();
    final locationController = Get.find<LocationController>();

    /// FIX: Refresh day state when the screen becomes visible.
    /// This ensures records saved during a prior app session are
    /// recognized, and the OUT card is properly disabled if the
    /// day is already complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshDayState();
    });

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 8 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: TextStyle(
            fontSize: ResponsiveHelper.getMediumFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (!controller.isDayStateLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final nextAction = controller.nextAction;
        final isComplete = controller.isAttendanceCompleteToday;
        final actionColor = isComplete
            ? AppColors.successText
            : (nextAction == 'IN' ? AppColors.info : AppColors.warning);
        final actionIcon = isComplete
            ? Icons.check_circle_rounded
            : (nextAction == 'IN' ? Icons.login_rounded : Icons.logout_rounded);

        return Center(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tappable summary card
                  GestureDetector(
                    onTap: controller.openCameraOrShowAlreadyMarked,
                    child: Container(
                      padding: EdgeInsets.all(verticalPadding * 1.25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            actionColor.withOpacity(0.15),
                            actionColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: actionColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(verticalPadding),
                            decoration: BoxDecoration(
                              color: actionColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              actionIcon,
                              size: ResponsiveHelper.getWidthPercentage(context, 12),
                              color: actionColor,
                            ),
                          ),
                          SizedBox(height: verticalPadding),
                          Text(
                            isComplete
                                ? 'Attendance Completed'
                                : 'Next Action: $nextAction',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getLargeFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: actionColor,
                            ),
                          ),
                          SizedBox(height: verticalPadding * 0.5),
                          Text(
                            isComplete
                                ? 'You have already marked your attendance today'
                                : (nextAction == 'IN'
                                ? 'Tap below to mark your check-in'
                                : 'Tap below to mark your check-out'),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.9,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: verticalPadding * 2),

                  // Location container
                  Container(
                    padding: EdgeInsets.all(verticalPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: ResponsiveHelper.getWidthPercentage(context, 5),
                            ),
                            SizedBox(width: verticalPadding * 0.5),
                            Text(
                              'Current Location',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getMediumFontSize(context),
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: verticalPadding),
                        Obx(() => Row(
                          children: [
                            Expanded(
                              child: Text(
                                locationController.currentAddress.value,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.95,
                                  color: locationController
                                      .currentAddress.value
                                      .contains('Unable') ||
                                      locationController
                                          .currentAddress.value
                                          .contains('Fetching') ||
                                      locationController
                                          .currentAddress.value
                                          .contains('denied')
                                      ? AppColors.errorText
                                      : AppColors.onSurface,
                                ),
                              ),
                            ),
                            if (locationController.isLoading.value)
                              SizedBox(
                                width: verticalPadding * 1.25,
                                height: verticalPadding * 1.25,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              IconButton(
                                onPressed:
                                locationController.getCurrentLocation,
                                icon: Icon(Icons.refresh_rounded,
                                    color: AppColors.primary),
                                tooltip: 'Refresh location',
                              ),
                          ],
                        )),
                        SizedBox(height: verticalPadding),
                        Obx(() => LinearProgressIndicator(
                          value: locationController
                              .currentAddress.value
                              .contains('Unable') ||
                              locationController.currentAddress.value
                                  .contains('Fetching') ||
                              locationController.currentAddress.value
                                  .contains('denied')
                              ? 0.0
                              : 1.0,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                        )),
                      ],
                    ),
                  ),

                  SizedBox(height: verticalPadding * 2),

                  // Status message
                  Obx(() => Text(
                    controller.statusMessage.value,
                    style: TextStyle(
                      color: controller.statusMessage.value.contains('Failed')
                          ? AppColors.errorText
                          : AppColors.successText,
                      fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.95,
                    ),
                    textAlign: TextAlign.center,
                  )),

                  SizedBox(height: verticalPadding * 2),

                  // Action button — DISABLED when day is complete
                  Obx(() => SizedBox(
                    height: ResponsiveHelper.getButtonHeight(context).clamp(48.0, 60.0),
                    child: ElevatedButton.icon(
                      // FIX: onPressed is null when complete — card is
                      // non-interactive, not just visually different
                      onPressed: isComplete
                          ? null
                          : controller.openCameraOrShowAlreadyMarked,
                      icon: Icon(
                        isComplete
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_rounded,
                      ),
                      label: Text(
                        controller.isLoading.value
                            ? 'Processing...'
                            : (isComplete
                            ? 'Attendance Already Marked'
                            : 'Open Camera to Mark $nextAction'),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getMediumFontSize(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isComplete ? AppColors.divider : actionColor,
                        foregroundColor: isComplete
                            ? AppColors.onSurfaceVariant
                            : AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        disabledBackgroundColor: actionColor.withOpacity(0.5),
                      ),
                    ),
                  )),

                  SizedBox(height: verticalPadding),

                  // Last marked record
                  if (controller.lastTodayRecord != null)
                    Container(
                      padding: EdgeInsets.all(verticalPadding),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.successText.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.successText),
                          SizedBox(width: verticalPadding * 0.75),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last marked: ${controller.lastTodayRecord!.type}',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getMediumFontSize(context),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.successText,
                                  ),
                                ),
                                Text(
                                  'at ${controller.lastTodayRecord!.formattedTime}',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getSmallFontSize(context) * 0.95,
                                    color: AppColors.successText.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}