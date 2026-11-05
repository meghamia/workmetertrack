import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../theme/app_color.dart';
//
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<SplashController>();
//
//     return Scaffold(
//       backgroundColor: AppColors.surface,
//       body: Center(
//         child: AnimatedBuilder(
//           animation: controller.animationController,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: controller.scaleAnimation.value,
//               child: FadeTransition(
//                 opacity: controller.fadeAnimation,
//                 child: Image.asset(
//                   'assets/images/img.png',
//                   width: 180,
//                   height: 180,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();

    final double logoSize =
    ResponsiveHelper.getWidthPercentage(context, 40).clamp(120.0, 220.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: controller.scaleAnimation.value,
              child: FadeTransition(
                opacity: controller.fadeAnimation,
                child: Image.asset(
                  'assets/images/img.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}