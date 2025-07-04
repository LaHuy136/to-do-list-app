// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/components/my_text_form_field.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPwController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        leadingWidth: 55,
        leading: Container(
          margin: EdgeInsets.only(left: 8, top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primary,
          ),
          alignment: Alignment.center,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_rounded, size: 22),
          ),
        ),
        backgroundColor: AppColors.defaultText,
        foregroundColor: AppColors.defaultText,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    // App Name
                    const Text(
                      'TASK-WAN',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                    // App Subname
                    const Text(
                      'Management App',
                      style: TextStyle(
                        color: AppColors.disabledPrimary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 50),
                    // Reset your password
                    const Text(
                      'Reset your password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Email
              MyTextFormField(
                controller: emailController,
                hintText: '   Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Your email is invalid';
                  }
                  return null;
                },
                icon: Icons.email_rounded,
              ),

              const SizedBox(height: 20),
              // pw
              MyTextFormField(
                controller: newPasswordController,
                hintText: '   New password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Your password is not enough length';
                  }
                  return null;
                },
                icon: Icons.lock_rounded,
              ),

              const SizedBox(height: 20),
              // Confirm PW
              MyTextFormField(
                controller: confirmPwController,
                hintText: '   Confirm Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Your password is not enough length';
                  }
                  return null;
                },
                icon: Icons.lock_rounded,
              ),

              const SizedBox(height: 25),
              // Button Reset Password
              MyElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final newPassword = newPasswordController.text;
                  final confirmPassword = confirmPwController.text;

                  if (newPassword != confirmPassword) {
                    showCustomSnackBar(
                      context: context,
                      message: 'Passwords do not match',
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final success = await AuthAPI.resetPassword(
                      email: email,
                      newPassword: newPassword,
                    );

                    if (success) {
                      showCustomSnackBar(
                        context: context,
                        message: 'Password reset successfully',
                      );
                      Navigator.pushReplacementNamed(context, '/login');
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
                textButton: 'Reset Password',
              ),

              const SizedBox(height: 35),
              // Or Login with
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('—', style: TextStyle(color: AppColors.primary)),
                  const SizedBox(width: 6),
                  Text(
                    'Or Login with',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('—', style: TextStyle(color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 20),
              // // Social Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     // Google
              //     Expanded(
              //       child: Container(
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(color: AppColors.disabledTertiary),
              //         ),
              //         padding: EdgeInsets.all(16),
              //         child: SvgPicture.asset(
              //           'assets/icons/google.svg',
              //           width: 35,
              //           height: 35,
              //         ),
              //       ),
              //     ),

              //     const SizedBox(width: 40),
              //     // Facebook
              //     Expanded(
              //       child: Container(
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(color: AppColors.disabledTertiary),
              //         ),
              //         padding: EdgeInsets.all(16),
              //         child: SvgPicture.asset(
              //           'assets/icons/facebook.svg',
              //           width: 35,
              //           height: 35,
              //         ),
              //       ),
              //     ),

              //     const SizedBox(width: 40),
              //     // Twitter
              //     Expanded(
              //       child: Container(
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(color: AppColors.disabledTertiary),
              //         ),
              //         padding: EdgeInsets.all(16),
              //         child: SvgPicture.asset(
              //           'assets/icons/twitter.svg',
              //           width: 35,
              //           height: 35,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
