import 'dart:io';
import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_controller.dart';
import '../theme/app_color.dart';
//
// class CameraScreen extends StatelessWidget {
//   const CameraScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<CameraController>();
//     final args = Get.arguments as Map<String, dynamic>?;
//     final attendanceType = args?['type'] as String? ?? 'IN';
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Mark ' + attendanceType),
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           Obx(() => controller.hasMultipleCameras.value &&
//               controller.capturedImagePath.value.isEmpty
//               ? IconButton(
//             onPressed: controller.switchCamera,
//             icon: const Icon(Icons.flip_camera_android_rounded,
//                 color: Colors.white),
//             tooltip: 'Flip camera',
//           )
//               : const SizedBox.shrink()),
//           IconButton(
//             onPressed: controller.refreshLocation,
//             icon: const Icon(Icons.my_location_rounded, color: Colors.white),
//             tooltip: 'Refresh location',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Live preview ya photo
//           Positioned.fill(
//             child: Obx(() {
//               final path = controller.capturedImagePath.value;
//               final preview = controller.previewController;
//               if (path.isNotEmpty) {
//                 return Image.file(File(path), fit: BoxFit.cover);
//               }
//               if (controller.isCameraInitialized.value && preview != null) {
//                 return cam.CameraPreview(preview);
//               }
//               return const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               );
//             }),
//           ),
//
//           // Transparent location tile
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Obx(() => Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.location_on_rounded,
//                       color: AppColors.info, size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       controller.locationController.currentAddress.value,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         shadows: [
//                           Shadow(blurRadius: 4, color: Colors.black54)
//                         ],
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//           ),
//
//           // Bottom buttons
//           Positioned(
//             bottom: 40,
//             left: 16,
//             right: 16,
//             child: Obx(() {
//               if (controller.capturedImagePath.value.isEmpty) {
//                 return Center(
//                   child: GestureDetector(
//                     onTap: controller.isLoading.value
//                         ? null
//                         : controller.captureImage,
//                     child: Container(
//                       width: 72,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: controller.isLoading.value
//                             ? Colors.grey
//                             : Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: controller.isLoading.value
//                           ? const Center(
//                         child: SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.black),
//                         ),
//                       )
//                           : const Icon(Icons.camera_alt_rounded,
//                           size: 32, color: Colors.black),
//                     ),
//                   ),
//                 );
//               }
//               return Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: controller.cancelCapture,
//                       icon: const Icon(Icons.close_rounded),
//                       label: const Text('Retake'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         side: const BorderSide(color: Colors.white),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: controller.confirmCapture,
//                       icon: const Icon(Icons.check_rounded),
//                       label: const Text('Confirm'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.successText,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_controller.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CameraController>();
    final args = Get.arguments as Map<String, dynamic>?;
    final attendanceType = args?['type'] as String? ?? 'IN';

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double edgePadding =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 6 : 4);
    final double locationTilePaddingH =
    ResponsiveHelper.getWidthPercentage(context, 3);
    final double locationTilePaddingV =
        ResponsiveHelper.getSmallSpacing(context) * 0.6;
    final double locationIconSize =
    ResponsiveHelper.getWidthPercentage(context, 5);
    final double locationFont =
        ResponsiveHelper.getSmallFontSize(context) * 0.95;
    final double captureButtonSize =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 12 : 20)
        .clamp(56.0, 80.0);
    final double captureIconSize =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 5 : 10);
    final double spinnerSize =
    ResponsiveHelper.getWidthPercentage(context, isWide ? 3 : 6);
    final double bottomButtonPaddingV =
    ResponsiveHelper.getSmallSpacing(context);
    final double bottomButtonRadius =
    ResponsiveHelper.getSmallSpacing(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Mark ' + attendanceType,
          style: TextStyle(
            fontSize: ResponsiveHelper.getMediumFontSize(context),
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.hasMultipleCameras.value &&
              controller.capturedImagePath.value.isEmpty
              ? IconButton(
            onPressed: controller.switchCamera,
            icon: Icon(
              Icons.flip_camera_android_rounded,
              color: Colors.white,
              size: ResponsiveHelper.getWidthPercentage(context, 5),
            ),
            tooltip: 'Flip camera',
          )
              : const SizedBox.shrink()),
          IconButton(
            onPressed: controller.refreshLocation,
            icon: Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: ResponsiveHelper.getWidthPercentage(context, 5),
            ),
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live preview ya photo
          Positioned.fill(
            child: Obx(() {
              final path = controller.capturedImagePath.value;
              final preview = controller.previewController;
              if (path.isNotEmpty) {
                return Image.file(File(path), fit: BoxFit.cover);
              }
              if (controller.isCameraInitialized.value && preview != null) {
                return cam.CameraPreview(preview);
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }),
          ),

          // Transparent location tile
          Positioned(
            top: edgePadding,
            left: edgePadding,
            right: edgePadding,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: locationTilePaddingH,
                vertical: locationTilePaddingV,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.info,
                    size: locationIconSize,
                  ),
                  SizedBox(width: edgePadding * 0.5),
                  Expanded(
                    child: Text(
                      controller.locationController.currentAddress.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: locationFont,
                        shadows: [
                          Shadow(
                              blurRadius: 4, color: Colors.black54)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ),

          // Bottom buttons
          Positioned(
            bottom: ResponsiveHelper.getHeightPercentage(context, 5),
            left: edgePadding,
            right: edgePadding,
            child: Obx(() {
              if (controller.capturedImagePath.value.isEmpty) {
                return Center(
                  child: GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.captureImage,
                    child: Container(
                      width: captureButtonSize,
                      height: captureButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isLoading.value
                            ? Colors.grey
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: controller.isLoading.value
                          ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        ),
                      )
                          : Icon(Icons.camera_alt_rounded,
                          size: captureIconSize, color: Colors.black),
                    ),
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.cancelCapture,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(vertical: bottomButtonPaddingV),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(bottomButtonRadius)),
                      ),
                    ),
                  ),
                  SizedBox(width: edgePadding * 0.5),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.confirmCapture,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successText,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: bottomButtonPaddingV),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(bottomButtonRadius)),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}