// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/components/my_text_form_field.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/auth_viewmodel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        backgroundColor: AppColors.defaultText,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name & Subname
              Center(
                child: Column(
                  children: const [
                    Text(
                      'TASK-WAN',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'Management App',
                      style: TextStyle(
                        color: AppColors.disabledPrimary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      'Login to your account',
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

              // Password
              MyTextFormField(
                controller: pwController,
                isPassword: true,
                hintText: '   Password',
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

              // Forgot Password?
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/resetPassword'),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.unfocusedIcon,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Button Login
              MyElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final success = await authVM.login(
                    emailController.text.trim(),
                    pwController.text.trim(),
                  );

                  if (success) {
                    showCustomSnackBar(
                      context: context,
                      message: 'Login successfully',
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      ModalRoute.withName('/home'),
                    );
                  } else {
                    showCustomSnackBar(
                      context: context,
                      message: authVM.errorMessage ?? 'Login failed',
                      type: SnackBarType.error,
                    );
                  }
                },
                isLoading: authVM.isLoading,
                textButton: 'Login',
              ),

              const SizedBox(height: 35),

              // Or Login with
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('—', style: TextStyle(color: AppColors.primary)),
                  const SizedBox(width: 6),
                  const Text(
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

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  socialButton('assets/icons/google.svg'),
                  const SizedBox(width: 40),
                  socialButton('assets/icons/facebook.svg'),
                  const SizedBox(width: 40),
                  socialButton('assets/icons/twitter.svg'),
                ],
              ),

              const SizedBox(height: 20),

              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/signUp'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontFamily: 'Poppins-Regular',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialButton(String asset) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.disabledTertiary),
        ),
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(asset, width: 35, height: 35),
      ),
    );
  }
}
