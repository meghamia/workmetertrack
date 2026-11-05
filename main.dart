import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_attendance_app/screens/add_employee_screen.dart';
import 'package:track_attendance_app/screens/admin_report_screen.dart';
import 'package:track_attendance_app/screens/profile_screen.dart';
import 'package:track_attendance_app/screens/record_detail_screen.dart';
import 'bindings/add_employee_binding.dart';
import 'bindings/admin_report_binding.dart';
import 'bindings/camera_binding.dart';
import 'bindings/dashboard_binding.dart';
import 'bindings/mark_attendance_binding.dart';
import 'bindings/profile_binding.dart';
import 'bindings/records_binding.dart';
import 'bindings/login_binding.dart';
import 'bindings/splash_binding.dart';
import 'models/attendance_record.dart';
import 'screens/camera_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/records_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mark_attendance_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_session.dart';
import 'services/attendance_storage.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/role_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // print('DEBUG: Starting app...');
  await Get.putAsync(() async => AppSession());

  await Get.putAsync(() async => ApiClient());
  print('DEBUG: ApiClient ready (no API calls made)');

  await Get.putAsync(() async => AuthService());

  await Get.putAsync(() async => AttendanceStorage());

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Track Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: '/login',
          page: () =>  LoginScreen(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/dashboard',
          page: () =>  DashboardScreen(),
          binding: DashboardBinding(),
        ),
        GetPage(
          name: '/mark-attendance',
          page: () => const MarkAttendanceScreen(),
          binding: MarkAttendanceBinding(),
        ),
        GetPage(
          name: '/camera',
          page: () => const CameraScreen(),
          binding: CameraBinding(),
        ),
        GetPage(
          name: '/records',
          page: () => const RecordsScreen(),
          binding: RecordsBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: '/admin-report',
          page: () => AdminReportScreen(),
          binding: AdminReportBinding(),
        ),
        GetPage(
          name: '/add-employee',
          page: () => AddEmployeeScreen(),
          binding: AddEmployeeBinding(),
        ),

      ],
    );
  }
}
