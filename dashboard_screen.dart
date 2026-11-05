import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/mark_attendance_controller.dart';
import '../services/auth_service.dart';
import '../theme/app_color.dart';

import '../utils/responsive_helper.dart';
//
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});
//
//   static const _navy = Color(0xFF1B2A4A);
//   static const _green = Color(0xFF1E7B4F);
//   static const _red = Color(0xFFC62828);
//   static const _blue = Color(0xFF1565C0);
//   static const _muted = Color(0xFF6B7A99);
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<DashboardController>();
//     final attendance = Get.find<MarkAttendanceController>();
//
//     final isWide = ResponsiveHelper.screenWidth(context) >= 600;
//     final double maxWidth = isWide ? 700 : double.infinity;
//
//     final double gap = ResponsiveHelper.getSmallSpacing(context);
//     final double tileHeight = ResponsiveHelper.getHeightPercentage(
//       context,
//       isWide ? 16 : 22,
//     ).clamp(110.0, 160.0);
//
//     final double titleFont = ResponsiveHelper.getMediumFontSize(context);
//     final double subFont = ResponsiveHelper.getSmallFontSize(context);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       appBar: AppBar(
//         title: Text(
//           'Dashboard',
//           style: TextStyle(fontSize: titleFont * 1.5),
//         ),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.person_rounded),
//           onPressed: () => Get.toNamed('/profile'),
//           tooltip: 'Profile',
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout_rounded),
//             onPressed: () async {
//               await Get.find<AuthService>().logout();
//               Get.offAllNamed('/login');
//             },
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: maxWidth),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.getWidthPercentage(
//                 context,
//                 isWide ? 10 : 5,
//               ),
//               // vertical: 0,
//               vertical: ResponsiveHelper.getSmallSpacing(context),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(
//                     left: ResponsiveHelper.getWidthPercentage(context, 3),
//                   ),
//                   child: Obx(() {
//                     final isEmployee = !controller.isAdmin.value;
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                          SizedBox(height: gap * 2.0),
//                         Text(
//                           isEmployee ? 'Employee' : 'Administrator',
//                           style: TextStyle(
//                             fontSize: ResponsiveHelper.getSmallFontSize(
//                               context,
//                             ) * 1.5,
//                             color: _muted,
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//                 ),
//                 SizedBox(height: gap * 2.0),
//                 _card(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: ResponsiveHelper.getWidthPercentage(context, 4),
//                     vertical: ResponsiveHelper.getSmallSpacing(context) * 1.8,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: ResponsiveHelper.getWidthPercentage(context, 8),
//                         height: ResponsiveHelper.getWidthPercentage(context, 8),
//                         alignment: Alignment.center,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFE3E6FA),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Obx(() {
//                           final email = controller.currentUserEmail.value;
//                           final localPart =
//                               email.contains('@') ? email.split('@')[0] : email;
//                           final initial = localPart.isNotEmpty
//                               ? localPart[0].toUpperCase()
//                               : 'U';
//                           return Text(
//                             initial,
//                             style: TextStyle(
//                               fontSize: ResponsiveHelper.getSmallFontSize(
//                                     context,
//                                   ) *
//                                   1.0,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF5B5FC7),
//                             ),
//                           );
//                         }),
//                       ),
//                       SizedBox(width: gap),
//                       Expanded(
//                         child: Obx(() => Text(
//                               controller.currentUserEmail.value.isNotEmpty
//                                   ? controller.currentUserEmail.value
//                                   : 'User',
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: subFont,
//                                 fontWeight: FontWeight.bold,
//                                 color: _navy,
//                               ),
//                             )),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: gap * 1.4),
//                 Obx(() {
//                   if (controller.isLoadingEmployees.value) {
//                     return Padding(
//                       padding: EdgeInsets.only(bottom: gap),
//                       child: SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     );
//                   }
//                   if (controller.employeeError.value.isNotEmpty) {
//                     return Padding(
//                       padding: EdgeInsets.only(bottom: gap),
//                       child: Text(
//                         'Could not load employees: ${controller.employeeError.value}',
//                         style: TextStyle(
//                           fontSize: ResponsiveHelper.getSmallFontSize(
//                                 context,
//                               ) *
//                               0.85,
//                           color: _red,
//                         ),
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//                 // Employee dashboard
//                 Obx(() {
//                   final isEmployee = !controller.isAdmin.value;
//                   if (isEmployee) {
//                     return Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 final alreadyDone =
//                                     attendance.hasCheckedInToday;
//                                 return _tile(
//                                   context: context,
//                                   height: tileHeight,
//                                   title: 'IN',
//                                   subtitle: alreadyDone ? 'Done' : 'Clock In',
//                                   color: alreadyDone
//                                       ? Colors.green.withOpacity(0.35)
//                                       : _green,
//                                   onTap: alreadyDone
//                                       ? () {
//                                           Get.snackbar(
//                                             'Already Punched In',
//                                             'You have already punched in for today.',
//                                             snackPosition: SnackPosition.BOTTOM,
//                                             margin: const EdgeInsets.all(16),
//                                             backgroundColor:
//                                                 Colors.green.withOpacity(0.8),
//                                             colorText: Colors.white,
//                                           );
//                                         }
//                                       : () => attendance.startAttendance('IN'),
//                                 );
//                               }),
//                             ),
//                             SizedBox(width: gap),
//                             Expanded(
//                               child: Obx(() {
//                                 final alreadyDone =
//                                     attendance.hasCheckedOutToday;
//                                 return _tile(
//                                   context: context,
//                                   height: tileHeight,
//                                   title: 'OUT',
//                                   subtitle: alreadyDone ? 'Done' : 'Clock Out',
//                                   color: alreadyDone
//                                       ? Colors.green.withOpacity(0.35)
//                                       : _red,
//                                   onTap: alreadyDone
//                                       ? () {
//                                           Get.snackbar(
//                                             'Already Punched Out',
//                                             'You have already punched out for today.',
//                                             snackPosition: SnackPosition.BOTTOM,
//                                             margin: const EdgeInsets.all(16),
//                                             backgroundColor:
//                                                 Colors.green.withOpacity(0.8),
//                                             colorText: Colors.white,
//                                           );
//                                         }
//                                       : () => attendance.startAttendance('OUT'),
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: gap),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _tile(
//                                 context: context,
//                                 height: tileHeight,
//                                 title: 'RECORDS',
//                                 subtitle: 'My Attendance',
//                                 color: _navy,
//                                 subtitleColor: _blue,
//                                 onTap: () => Get.toNamed('/records'),
//                               ),
//                             ),
//                             SizedBox(width: gap),
//                             Expanded(
//                               child: Obx(() {
//                                 if (controller.isLoadingPresentToday.value) {
//                                   return _tile(
//                                     context: context,
//                                     height: tileHeight,
//                                     title: '...',
//                                     subtitle: 'Present Today',
//                                     color: _blue,
//                                     subtitleColor: _navy,
//                                   );
//                                 }
//                                 return _tile(
//                                   context: context,
//                                   height: tileHeight,
//                                   title: controller.presentToday.toString(),
//                                   subtitle: 'Present Today',
//                                   color: _blue,
//                                   subtitleColor: _navy,
//                                   onTap: () {
//                                     _showPresentTodayEmployees(
//                                         context, controller);
//                                   },
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),
//                       ],
//                     );
//                   }
//                   // Admin dashboard
//                   return Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _tile(
//                               context: context,
//                               height: tileHeight,
//                               title: 'TODAY RECORDS',
//                               subtitle: 'Attendance Log',
//                               color: _navy,
//                               subtitleColor: _blue,
//
//                               onTap: () => Get.toNamed('/records'),
//                             ),
//                           ),
//                           SizedBox(width: gap),
//                           Expanded(
//                             child: Obx(() => _tile(
//                                   context: context,
//                                   height: tileHeight,
//                                   title: 'ATTENDANCE RECORD ',
//                                   subtitle:
//                                       controller.totalEmployees.toString(),
//                                   color: _blue,
//                                   subtitleColor: _navy,
//                                   onTap: () => Get.toNamed('/admin-report'),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: gap),
//                       Row(
//                         children: [
//                           // Spacer(),
//                           Expanded(
//                             child: _tile(
//                               context: context,
//                               height: tileHeight ,
//                               title: 'ADD EMPLOYEE',
//                               subtitle: 'ADD EMPLOYEE',
//                               color: _green,
//                               subtitleColor: Colors.white,
//                               onTap: () => Get.toNamed('/add-employee'),
//                             ),
//                           ),
//                           const Spacer(),
//                         ],
//                       ),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _card({required Widget child, EdgeInsets? padding}) => Container(
//         width: double.infinity,
//         padding: padding,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2))
//           ],
//         ),
//         child: child,
//       );
//
//   Widget _tile({
//     required BuildContext context,
//     required double height,
//     required String title,
//     required String subtitle,
//     required Color color,
//     Color? subtitleColor,
//     VoidCallback? onTap,
//   }) =>
//       Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(14),
//           child: SizedBox(
//             height: height,
//             child: _card(
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: Text(
//                         title,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: ResponsiveHelper.getMediumFontSize(context),
//                           fontWeight: FontWeight.bold,
//                           color: color,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     SizedBox(
//                       width: double.infinity,
//                       child: Text(
//                         subtitle,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: ResponsiveHelper.getSmallFontSize(context),
//                           color: subtitleColor ?? color,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//
//   void _showPresentTodayEmployees(
//     BuildContext context,
//     DashboardController controller,
//   ) {
//     Get.bottomSheet(
//       Container(
//         height:
//             ResponsiveHelper.getHeightPercentage(context, 65).clamp(300, 650),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(20),
//           ),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Obx(() {
//           final employees = controller.presentEmployeesToday;
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Today's Present Employees (${employees.length})",
//                 style: TextStyle(
//                   fontSize: ResponsiveHelper.getMediumFontSize(context),
//                   fontWeight: FontWeight.bold,
//                   color: _navy,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Employees who punched in today',
//                 style: TextStyle(
//                   fontSize: ResponsiveHelper.getSmallFontSize(context),
//                   color: _muted,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Divider(),
//               Expanded(
//                 child: employees.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No employees have punched in today.',
//                         ),
//                       )
//                     : ListView.separated(
//                         itemCount: employees.length,
//                         separatorBuilder: (_, __) => const Divider(height: 1),
//                         itemBuilder: (context, index) {
//                           final employee = employees[index];
//
//                           final punchInTime =
//                               controller.todayPunchInTimes[employee.id] ??
//                                   '--:--';
//
//                           return ListTile(
//                             contentPadding: EdgeInsets.zero,
//                             leading: CircleAvatar(
//                               backgroundColor: const Color(0xFFE3E6FA),
//                               child: Text(
//                                 employee.displayName.isEmpty
//                                     ? '?'
//                                     : employee.displayName[0].toUpperCase(),
//                                 style: const TextStyle(
//                                   color: Color(0xFF5B5FC7),
//                                 ),
//                               ),
//                             ),
//                             title: Text(
//                               employee.displayName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize:
//                                     ResponsiveHelper.getSmallFontSize(context),
//                               ),
//                             ),
//                             subtitle: Text(
//                               employee.loginId,
//                               style: TextStyle(
//                                 fontSize:
//                                     ResponsiveHelper.getSmallFontSize(context) *
//                                         0.9,
//                               ),
//                             ),
//                             trailing: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   punchInTime,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: ResponsiveHelper.getSmallFontSize(
//                                         context),
//                                   ),
//                                 ),
//                                 Text(
//                                   controller
//                                           .todayAttendanceStatus[employee.id] ??
//                                       'Punched In',
//                                   style: TextStyle(
//                                     color: controller.todayAttendanceStatus[
//                                                 employee.id] ==
//                                             'Punched Out'
//                                         ? _red
//                                         : _green,
//                                     fontSize: ResponsiveHelper.getSmallFontSize(
//                                             context) *
//                                         0.85,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           );
//         }),
//       ),
//       isScrollControlled: true,
//     );
//   }
// }

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _navy = Color(0xFF1B2A4A);
  static const _green = Color(0xFF1E7B4F);
  static const _red = Color(0xFFC62828);
  static const _blue = Color(0xFF1565C0);
  static const _muted = Color(0xFF6B7A99);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final attendance = Get.find<MarkAttendanceController>();

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double maxWidth = isWide ? 700 : double.infinity;

    final double gap = ResponsiveHelper.getSmallSpacing(context);
    final double tileHeight = ResponsiveHelper.getHeightPercentage(
      context,
      isWide ? 16 : 22,
    ).clamp(120.0, 190.0);

    final double titleFont = ResponsiveHelper.getMediumFontSize(context);
    final double subFont = ResponsiveHelper.getSmallFontSize(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isAdmin.value
                  ? 'Attendance Management'
                  : 'Workday Tracker',
              style: TextStyle(fontSize: titleFont * 1.5),
            )),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.blue,
              size: 22,
            ),
          ),
          onPressed: () => Get.toNamed('/profile'),
          tooltip: 'Profile',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              await Get.find<AuthService>().logout();
              Get.offAllNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getWidthPercentage(
                context,
                isWide ? 10 : 5,
              ),
              // vertical: 0,
              vertical: ResponsiveHelper.getSmallSpacing(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: ResponsiveHelper.getWidthPercentage(context, 3),
                  ),
                  child: Obx(() {
                    final isEmployee = !controller.isAdmin.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: gap * 2.0),
                        Text(
                          isEmployee ? 'Employee' : 'Administrator',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getSmallFontSize(
                                  context,
                                ) *
                                1.5,
                            fontWeight: FontWeight.w500,
                            color: _muted,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: gap * 2.0),
                Obx(() {
                  final isAdmin = controller.isAdmin.value;

                  return _card(
                    backgroundColor: isAdmin
                        ? const Color(0xFFEEF2FF) // Admin light blue
                        : const Color(0xFFF0EAFE), // Employee light purple

                    borderColor: isAdmin
                        ? const Color(0xFFCAD5F5)
                        : const Color(0xFFD8C9F2),

                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getWidthPercentage(context, 4),
                      vertical: ResponsiveHelper.getSmallSpacing(context) * 1.8,
                    ),

                    child: Row(
                      children: [
                        Container(
                          width:
                              ResponsiveHelper.getWidthPercentage(context, 8),
                          height:
                              ResponsiveHelper.getWidthPercentage(context, 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFFDCE5FF)
                                : const Color(0xFFE3D8FA),
                            shape: BoxShape.circle,
                          ),
                          child: Obx(() {
                            final email = controller.currentUserEmail.value;
                            final localPart = email.contains('@')
                                ? email.split('@')[0]
                                : email;
                            final initial = localPart.isNotEmpty
                                ? localPart[0].toUpperCase()
                                : 'U';

                            return Text(
                              initial,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getSmallFontSize(context),
                                fontWeight: FontWeight.w600,
                                color: isAdmin
                                    ? const Color(0xFF3556A8)
                                    : const Color(0xFF7045A5),
                              ),
                            );
                          }),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: Obx(() => Text(
                                controller.currentUserEmail.value.isNotEmpty
                                    ? controller.currentUserEmail.value
                                    : 'User',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: subFont,
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                ),
                              )),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: gap * 1.4),
                Obx(() {
                  if (controller.isLoadingEmployees.value) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: gap),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (controller.employeeError.value.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: gap),
                      child: Text(
                        'Could not load employees: ${controller.employeeError.value}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getSmallFontSize(
                                context,
                              ) *
                              0.85,
                          color: _red,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                // Employee dashboard
                Obx(() {
                  final isEmployee = !controller.isAdmin.value;
                  if (isEmployee) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final alreadyDone =
                                    attendance.hasCheckedInToday;
                                return _tile(
                                  context: context,
                                  height: tileHeight,
                                  title: 'IN',
                                  tileColor: const Color(0xFFE2F3EC),
                                  icon: Icons.login_rounded,
                                  subtitle: alreadyDone ? 'Done' : 'Clock In',
                                  color: alreadyDone
                                      ? Colors.green.withOpacity(0.35)
                                      : _green,
                                  onTap: alreadyDone
                                      ? () {
                                          Get.snackbar(
                                            'Already Punched In',
                                            'You have already punched in for today.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            margin: const EdgeInsets.all(16),
                                            backgroundColor:
                                                Colors.green.withOpacity(0.8),
                                            colorText: Colors.white,
                                          );
                                        }
                                      : () => attendance.startAttendance('IN'),
                                );
                              }),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: Obx(() {
                                final alreadyDone =
                                    attendance.hasCheckedOutToday;
                                return _tile(
                                  context: context,
                                  height: tileHeight,
                                  title: 'OUT',
                                  tileColor: const Color(0xFFFFEAEA),
                                  icon: Icons.logout_rounded,
                                  subtitle: alreadyDone ? 'Done' : 'Clock Out',
                                  color: alreadyDone
                                      ? Colors.green.withOpacity(0.35)
                                      : _red,
                                  onTap: alreadyDone
                                      ? () {
                                          Get.snackbar(
                                            'Already Punched Out',
                                            'You have already punched out for today.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            margin: const EdgeInsets.all(16),
                                            backgroundColor:
                                                Colors.green.withOpacity(0.8),
                                            colorText: Colors.white,
                                          );
                                        }
                                      : () => attendance.startAttendance('OUT'),
                                );
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: gap),
                        Row(
                          children: [
                            Expanded(
                              child: _tile(
                                context: context,
                                height: tileHeight,
                                title: 'RECORDS',
                                tileColor: const Color(0xFFE8EEFF),
                                icon: Icons.receipt_long_rounded,
                                subtitle: 'My Attendance',
                                color: _navy,
                                subtitleColor: _blue,
                                onTap: () => Get.toNamed('/records'),
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: Obx(() {
                                if (controller.isLoadingPresentToday.value) {
                                  return _tile(
                                    context: context,
                                    height: tileHeight,
                                    title: '...',
                                    subtitle: 'Present Today',
                                    color: _blue,
                                    subtitleColor: _navy,
                                    tileColor: const Color(0xFFF0EAEE),
                                  );
                                }
                                return _tile(
                                  context: context,
                                  height: tileHeight,
                                  title: controller.presentToday.toString(),
                                  subtitle: 'Present Today',
                                  color: _blue,
                                  subtitleColor: _navy,
                                  tileColor: const Color(0xFFF0EAFE),
                                  onTap: () {
                                    _showPresentTodayEmployees(
                                        context, controller);
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  // Admin dashboard
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _tile(
                              context: context,
                              height: tileHeight,

                              title: 'TODAY RECORDS',
                              icon: Icons.event_note_rounded,
                              subtitle: 'Attendance Log',
                              color: _navy,

                              // subtitleColor: _blue,
                              tileColor: const Color(0xFFE8EEFF),
                              subtitleColor: const Color(0xFF3556A8),

                              onTap: () => Get.toNamed('/records'),
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Obx(() => _tile(
                                  context: context,
                                  height: tileHeight,
                                  title: 'ATTENDANCE\nRECORD',
                                  icon: Icons.assessment_rounded,
                                  subtitle:
                                      controller.totalEmployees.toString(),
                                  color: _blue,
                                  // subtitleColor: _navy,
                                  tileColor: const Color(0xFFE2F3EC),
                                  subtitleColor: const Color(0xFF267653),
                                  onTap: () => Get.toNamed('/admin-report'),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          // Spacer(),
                          Expanded(
                            child: _tile(
                              context: context,
                              height: tileHeight,
                              title: 'ADD EMPLOYEE',
                              icon: Icons.person_add_alt_1_rounded,
                              subtitle: 'create employee profile',
                              color: _green,
                              tileColor: const Color(0xFFFFF0DF),
                              subtitleColor: const Color(0xFFB66A24),
                              // subtitleColor: Colors.white,
                              onTap: () => Get.toNamed('/add-employee'),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets? padding,
    Color backgroundColor = Colors.white,
    Color? borderColor,
  }) =>
      Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _tile({
    required BuildContext context,
    required double height,
    required String title,
    required String subtitle,
    required Color color,
    Color? subtitleColor,
    Color? tileColor,
    IconData? icon,
    VoidCallback? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: height,
            child: _card(
              backgroundColor: tileColor ?? Colors.white,
              borderColor:
                  tileColor != null ? Color.lerp(tileColor, color, 0.25) : null,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: ResponsiveHelper.getWidthPercentage(context, 8)
                            .clamp(28.0, 38.0),
                        color: color,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSmallSpacing(context) * 1.3,
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getMediumFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getSmallFontSize(context),
                          color: subtitleColor ?? color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void _showPresentTodayEmployees(
    BuildContext context,
    DashboardController controller,
  ) {
    Get.bottomSheet(
      Container(
        height:
            ResponsiveHelper.getHeightPercentage(context, 65).clamp(300, 650),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final employees = controller.presentEmployeesToday;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Present Employees (${employees.length})",
                style: TextStyle(
                  fontSize: ResponsiveHelper.getMediumFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Employees who punched in today',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSmallFontSize(context),
                  color: _muted,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Expanded(
                child: employees.isEmpty
                    ? const Center(
                        child: Text(
                          'No employees have punched in today.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: employees.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final employee = employees[index];

                          final punchInTime =
                              controller.todayPunchInTimes[employee.id] ??
                                  '--:--';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE3E6FA),
                              child: Text(
                                employee.displayName.isEmpty
                                    ? '?'
                                    : employee.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF5B5FC7),
                                ),
                              ),
                            ),
                            title: Text(
                              employee.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    ResponsiveHelper.getSmallFontSize(context),
                              ),
                            ),
                            subtitle: Text(
                              employee.loginId,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getSmallFontSize(context) *
                                        0.9,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  punchInTime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveHelper.getSmallFontSize(
                                        context),
                                  ),
                                ),
                                Text(
                                  controller
                                          .todayAttendanceStatus[employee.id] ??
                                      'Punched In',
                                  style: TextStyle(
                                    color: controller.todayAttendanceStatus[
                                                employee.id] ==
                                            'Punched Out'
                                        ? _red
                                        : _green,
                                    fontSize: ResponsiveHelper.getSmallFontSize(
                                            context) *
                                        0.85,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }
}
