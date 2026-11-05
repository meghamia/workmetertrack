import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_employee_controller.dart';
import '../theme/app_color.dart';
//
// class AddEmployeeScreen extends StatelessWidget {
//   const AddEmployeeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AddEmployeeController>();
//
//     return Scaffold(
//       backgroundColor: AppColors.surfaceVariant,
//       appBar: AppBar(
//         title: const Text('Add Employee'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.onPrimary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         return Form(
//           key: controller.formKey,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Employee Name
//                 _buildField(
//                   controller: controller.nameController,
//                   label: 'Employee Name',
//                   icon: Icons.person_outlined,
//                   validator: controller.validateName,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Login ID (Email)
//                 _buildField(
//                   controller: controller.loginIdController,
//                   label: 'Login ID (Email)',
//                   icon: Icons.email_outlined,
//                   validator: controller.validateLoginId,
//                   inputType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Password
//                 _buildField(
//                   controller: controller.passwordController,
//                   label: 'Password',
//                   icon: Icons.lock_outlined,
//                   obscureText: true,
//                   validator: controller.validatePassword,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Designation
//                 _buildField(
//                   controller: controller.designationController,
//                   label: 'Designation',
//                   icon: Icons.work_outlined,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Department Dropdown (replacing the text field)
//                 Obx(() => DropdownButtonFormField<String>(
//                   value: controller.selectedDepartment.value.isNotEmpty
//                       ? controller.selectedDepartment.value
//                       : null,
//                   decoration: InputDecoration(
//                     labelText: 'Department',
//                     hintText: 'Select department',
//                     prefixIcon: Icon(Icons.business_outlined, color: AppColors.primary),
//                     filled: true,
//                     fillColor: AppColors.surface,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: AppColors.divider,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                   items: AddEmployeeController.allowedDepartments.map((dept) {
//                     return DropdownMenuItem<String>(
//                       value: dept,
//                       child: Text(dept),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     controller.setDepartment(value);
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a department';
//                     }
//                     return null;
//                   },
//                 )),
//
//                 const SizedBox(height: 16),
//
//                 // Role Dropdown
//                 Obx(
//                       () => DropdownButtonFormField<String>(
//                     value: controller.selectedRoleId.value == 1
//                         ? '1'
//                         : controller.selectedRoleId.value == 2
//                         ? '2'
//                         : null,
//                     decoration: InputDecoration(
//                       labelText: 'Role',
//                       filled: true,
//                       fillColor: AppColors.surface,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(
//                           color: AppColors.divider,
//                         ),
//                       ),
//                     ),
//                     items: const [
//                       DropdownMenuItem(
//                         value: '2',
//                         child: Text('Employee'),
//                       ),
//                       DropdownMenuItem(
//                         value: '1',
//                         child: Text('Admin'),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       if (value != null) {
//                         controller.setRoleId(value);
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Submit Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: controller.submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       foregroundColor: AppColors.onPrimary,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Add Employee',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)? validator,
//     bool obscureText = false,
//     TextInputType inputType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: inputType,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(
//           icon,
//           color: AppColors.onSurfaceVariant,
//         ),
//         filled: true,
//         fillColor: AppColors.surface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: AppColors.divider,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.primary,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_employee_controller.dart';
import '../theme/app_color.dart';
import '../utils/responsive_helper.dart';

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddEmployeeController>();

    final isWide = ResponsiveHelper.screenWidth(context) >= 600;
    final double horizontalPadding =
        ResponsiveHelper.getWidthPercentage(context, isWide ? 10 : 5);
    final double verticalPadding = ResponsiveHelper.getSmallSpacing(context);
    final double fieldGap = ResponsiveHelper.getSmallSpacing(context);
    final double buttonGap = ResponsiveHelper.getMediumSpacing(context);
    final double buttonHeight =
        ResponsiveHelper.getButtonHeight(context).clamp(48.0, 56.0);
    final double labelFont = ResponsiveHelper.getMediumFontSize(context);
    final double buttonFont = ResponsiveHelper.getMediumFontSize(context);
    final double borderRadius = ResponsiveHelper.getSmallSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Add Employee',
          style: TextStyle(fontSize: labelFont * 1.5),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: ResponsiveHelper.getWidthPercentage(context, 5),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 600 : double.infinity,
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Employee Name
                    _buildField(
                      context: context,
                      controller: controller.nameController,
                      label: 'Employee Name',
                      icon: Icons.person_outlined,
                      validator: controller.validateName,
                    ),
                    SizedBox(height: fieldGap),

                    // Login ID (Email)
                    _buildField(
                      context: context,
                      controller: controller.loginIdController,
                      label: 'Login ID (Email)',
                      icon: Icons.email_outlined,
                      validator: controller.validateLoginId,
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: fieldGap),

                    // Password
                    _buildField(
                      context: context,
                      controller: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                      validator: controller.validatePassword,
                    ),
                    SizedBox(height: fieldGap),

                    // Designation
                    _buildField(
                      context: context,
                      controller: controller.designationController,
                      label: 'Designation',
                      icon: Icons.work_outlined,
                    ),
                    SizedBox(height: fieldGap),

                    // Department Dropdown (replacing the text field)
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedDepartment.value.isNotEmpty
                              ? controller.selectedDepartment.value
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Department',
                            hintText: 'Select department',
                            prefixIcon: Icon(
                              Icons.business_outlined,
                              color: AppColors.primary,
                              size: ResponsiveHelper.getWidthPercentage(
                                  context, 5),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          items: AddEmployeeController.allowedDepartments
                              .map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept,
                              child: Text(dept),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.setDepartment(value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                        )),
                    SizedBox(height: fieldGap),

                    // Role Dropdown
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedRoleId.value == 1
                            ? '1'
                            : controller.selectedRoleId.value == 2
                                ? '2'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            borderSide: const BorderSide(
                              color: AppColors.divider,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Employee'),
                          ),
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setRoleId(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: buttonGap),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                ResponsiveHelper.getSmallSpacing(context) *
                                    1.25,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        child: Text(
                          'Add Employee',
                          style: TextStyle(
                            fontSize: buttonFont,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    final labelFont = ResponsiveHelper.getMediumFontSize(context);
    final borderRadius = ResponsiveHelper.getSmallSpacing(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.onSurfaceVariant,
          size: ResponsiveHelper.getWidthPercentage(context, 5),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
