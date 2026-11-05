import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../services/auth_service.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final double titleFont = ResponsiveHelper.getMediumFontSize(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title:  Text('Profile', style: TextStyle(fontSize: titleFont * 1.5),),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getMediumSpacing(context)), // Changed from fixed 20
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Profile Header ───
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: ResponsiveHelper.getAvatarRadius(context), // Changed from 50
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        controller.getInitials(),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getLargeFontSize(context), // Changed from 28
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

                    SizedBox(height: ResponsiveHelper.getSmallSpacing(context)), // Changed from 4
                    Obx(() {
                      final role = controller.userRole.value;
                      return Text(
                        role == 'admin' ? 'Administrator' : 'Employee',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getSmallFontSize(context), // Changed from 12
                          color: role == 'admin'
                              ? AppColors.primary
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)), // Changed from 32

              // ─── Editable Fields ───
              _buildSectionTitle(context, 'Personal Information'),
              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

              _buildTextField(
                context: context,
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: controller.nameController,
                icon: Icons.person_outline,
              ),
              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

              _buildTextField(
                context: context,
                label: 'Email',
                hint: 'Enter your email',
                controller: controller.emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

              // ─── Designation Field ───
              _buildTextField(
                context: context,
                label: 'Designation',
                hint: 'Enter your designation',
                controller: controller.designationController,
                icon: Icons.work_outline,
              ),
              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

              // ─── Department Dropdown ───
              _buildDepartmentDropdown(context, controller),
              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16

              // ─── Save Button ───
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getButtonHeight(context), // Changed from 50
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : () => controller.saveProfile(),
                  icon: controller.isSaving.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.save_rounded),
                  label: Text(controller.isSaving.value ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: TextStyle(
                      fontSize: ResponsiveHelper.getSmallFontSize(context), // Added responsive font
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ),

              SizedBox(height: ResponsiveHelper.getMediumSpacing(context)), // Changed from 16
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Text(
    title,
    style: TextStyle(
      fontSize: ResponsiveHelper.getMediumFontSize(context), // Changed from 18
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) => TextField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getMediumSpacing(context),
        vertical: ResponsiveHelper.getSmallSpacing(context),
      ),
    ),
    style: TextStyle(
      fontSize: ResponsiveHelper.getSmallFontSize(context), // Added responsive font
    ),
  );

  Widget _buildDepartmentDropdown(BuildContext context, ProfileController controller) =>
      Obx(() {
        // Use only the allowed fixed departments, ensuring uniqueness
        final fixedDepartments = ProfileController.allowedDepartments.toSet().toList();

        // Check if current selection exists in fixed list, if not, we'll still show it
        final currentValue = controller.selectedDepartmentValue.value.isNotEmpty &&
            fixedDepartments.contains(controller.selectedDepartmentValue.value)
            ? controller.selectedDepartmentValue.value
            : null;

        return DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            labelText: 'Department',
            hintText: 'Select department',
            prefixIcon: Icon(Icons.business_outlined, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getMediumSpacing(context),
              vertical: ResponsiveHelper.getSmallSpacing(context),
            ),
          ),
          items: fixedDepartments.asMap().entries.map((entry) {
            final int index = entry.key;
            final dept = entry.value;
            return DropdownMenuItem<String>(
              value: dept,
              child: Text(
                dept,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSmallFontSize(context), // Added responsive font
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.selectedDepartmentValue.value = newValue;
              controller.selectedDepartment.value = newValue;
              controller.departmentController.text = newValue;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a department';
            }
            return null;
          },
        );
      });
}