import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';         // <-- ADD THIS
import '../services/app_session.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AppSession _appSession = Get.find<AppSession>();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    scaleAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
              parent: animationController, curve: Curves.elasticOut),
        );

    fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: animationController, curve: Curves.easeIn),
        );

    animationController.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // final prefs = await SharedPreferences.getInstance();
    // final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isLoggedIn = _appSession.isLoggedIn;
    if (isLoggedIn) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}