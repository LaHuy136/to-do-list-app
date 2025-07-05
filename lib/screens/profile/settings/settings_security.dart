// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/components/my_text_form_field.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class SettingsSecurity extends StatefulWidget {
  final String email;
  const SettingsSecurity({super.key, required this.email});

  @override
  State<SettingsSecurity> createState() => _SettingsSecurityState();
}

class _SettingsSecurityState extends State<SettingsSecurity> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController currentPwController = TextEditingController();
  final TextEditingController newPwController = TextEditingController();
  final TextEditingController confirmNewPwController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: AppColors.primary,
          title: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              'Security',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.defaultText,
              ),
            ),
          ),
          centerTitle: true,
          leadingWidth: 55,
          leading: InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              margin: EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.defaultText,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          height: double.infinity,
          color: AppColors.defaultText,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Current pw
                  MyTextFormField(
                    controller: currentPwController,
                    hintText: ' Current Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      if (value.length < 6) {
                        return 'Your password is not enough length';
                      }
                      return null;
                    },
                    icon: Icons.lock_rounded,
                  ),

                  const SizedBox(height: 24),
                  // newPw
                  MyTextFormField(
                    controller: newPwController,
                    hintText: ' New Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password';
                      }
                      if (value.length < 6) {
                        return 'Your password is not enough length';
                      }
                      return null;
                    },
                    icon: Icons.lock_rounded,
                  ),

                  const SizedBox(height: 24),
                  // Confirm newPW
                  MyTextFormField(
                    controller: confirmNewPwController,
                    hintText: ' Confirm New Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your confirm new password';
                      }
                      if (value.length < 6) {
                        return 'Your password is not enough length';
                      }
                      return null;
                    },
                    icon: Icons.lock_rounded,
                  ),

                  const SizedBox(height: 24),

                  // Button Submit
                  MyElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isLoading = true);

                      final currentPw = currentPwController.text;
                      final newPw = newPwController.text;
                      final confirmPw = confirmNewPwController.text;

                      try {
                        if (newPw != confirmPw) {
                          showCustomSnackBar(
                            context: context,
                            message: 'Passwords do not match',
                            type: SnackBarType.error,
                          );
                          return;
                        }

                        final success = await AuthAPI.updatePassword(
                          email: widget.email,
                          currentPassword: currentPw,
                          newPassword: newPw,
                        );
                        if (success) {
                          showCustomSnackBar(
                            context: context,
                            message: 'Password updated successfully',
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        showCustomSnackBar(
                          context: context,
                          message: e.toString().replaceFirst('Exception: ', ''),
                          type: SnackBarType.error,
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                    isLoading: isLoading,
                    textButton: 'Submit',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
