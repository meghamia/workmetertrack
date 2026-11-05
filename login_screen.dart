import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/login_controller.dart';
import '../models/user_role.dart';
import '../theme/app_color.dart';

import '../utils/responsive_helper.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    debugPrint('LOGIN SCREEN BUILD');

    final controller = Get.find<LoginController>();
    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
        ResponsiveHelper.getWidthPercentage(context, isWide ? 10 : 6);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (controller.rememberMe.value &&
          controller.emailController.text.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email') ?? '';
        if (savedEmail.isNotEmpty) {
          controller.emailController.text = savedEmail;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: AutofillGroup(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: ResponsiveHelper.getHeightPercentage(
                        context,
                        isWide ? 2 : 3,
                      ).clamp(12.0, 30.0),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/img.png',
                        width: ResponsiveHelper.getWidthPercentage(context, 35)
                            .clamp(100.0, 150.0),
                        height: ResponsiveHelper.getWidthPercentage(context, 35)
                            .clamp(100.0, 150.0),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getHeightPercentage(
                        context,
                        isWide ? 2 : 3,
                      ).clamp(16.0, 32.0),
                    ),
                    Obx(
                      () => DropdownButtonFormField<UserRole>(
                        value: controller.selectedRole.value,
                        isExpanded: true,
                        items: controller.roleOptions.map((UserRole role) {
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child: Text(
                              role == UserRole.admin ? 'Admin' : 'Employee',
                            ),
                          );
                        }).toList(),
                        onChanged: controller.isLoading.value
                            ? null
                            : (UserRole? newRole) {
                                if (newRole != null) {
                                  controller.setRole(newRole);
                                }
                              },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(
                            Icons.badge_rounded,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
                    TextFormField(
                      controller: controller.emailController,
                    //  focusNode: controller.emailFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Login ID / Email',
                        hintText: 'rahul@gmail.com',
                        prefixIcon: Icon(
                          Icons.email_rounded,
                          color: AppColors.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Login ID is required';
                        }
                        if (!controller.validateEmail(value)) {
                          return 'Enter a valid login ID or email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                      //  focusNode: controller.passwordFocusNode,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: AppColors.onSurface,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              controller.obscurePassword.value =
                                  !controller.obscurePassword.value;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getSmallSpacing(context) * 0.75),
                    Obx(
                      () => CheckboxListTile(
                        value: controller.rememberMe.value,
                        onChanged: (bool? value) {
                          controller.setRememberMe(value ?? false);
                        },
                        title: Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getSmallFontSize(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: AppColors.errorText,
                          fontSize: ResponsiveHelper.getSmallFontSize(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSmallSpacing(context)),
                    Obx(
                      () => SizedBox(
                        height: ResponsiveHelper.getButtonHeight(context)
                            .clamp(48.0, 56.0),
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  if (formKey.currentState!.validate()) {
                                    await controller.login(
                                      email: controller.emailController.text
                                          .trim(),
                                      password:
                                          controller.passwordController.text,
                                      rememberMe: controller.rememberMe.value,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: ResponsiveHelper.getWidthPercentage(
                                      context, 6),
                                  height: ResponsiveHelper.getWidthPercentage(
                                      context, 6),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.onSurface,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getMediumFontSize(
                                            context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getSmallSpacing(context) * 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
