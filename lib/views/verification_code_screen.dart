// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/views/success_verification_screen.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/auth_viewmodel.dart';

class VerificationCode extends StatefulWidget {
  final String email;
  const VerificationCode({super.key, required this.email});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  String currentCode = '';
  int resendSeconds = 60;
  bool isResendAvailable = false;
  late Timer resendTimer;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    isResendAvailable = false;
    resendSeconds = 60;
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        setState(() {
          isResendAvailable = true;
        });
        resendTimer.cancel();
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    resendTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
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
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'TASK-WAN',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 30,
              ),
            ),
            // App Subname
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
            // Create your account
            Text(
              'Verify Account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),

            // Image
            Image.asset(
              'assets/images/verify-account.png',
              width: 200,
              height: 200,
            ),

            SizedBox(height: 10),
            // Subtil Image
            Text(
              'Please enter the verification number we send to your email',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 60),
            // Enter code
            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                fieldHeight: 70,
                fieldWidth: 50,
                activeColor: AppColors.primary,
                selectedColor: AppColors.primary,
                inactiveColor: AppColors.primary,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  currentCode = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive a code? ',
                  style: TextStyle(
                    color: AppColors.disabledSecondary,
                    fontSize: 12,
                  ),
                ),
                InkWell(
                  onTap:
                      isResendAvailable
                          ? () async {
                            final ok = await authVM.resendCode(widget.email);
                            if (ok) {
                              showCustomSnackBar(
                                context: context,
                                message: 'OTP resent',
                              );
                              startResendTimer();
                            } else {
                              showCustomSnackBar(
                                context: context,
                                message: 'Failed to resend',
                                type: SnackBarType.error,
                              );
                            }
                          }
                          : null,
                  child: Text(
                    isResendAvailable ? 'Resend' : 'Resend (${resendSeconds}s)',
                    style: TextStyle(
                      color:
                          isResendAvailable
                              ? AppColors.primary
                              : AppColors.disabledSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 60),
            // Button Confirm
            MyElevatedButton(
              onPressed: () async {
                final success = await authVM.verifyCode(
                  widget.email,
                  currentCode,
                );

                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessVerification(),
                    ),
                  );
                } else {
                  showCustomSnackBar(
                    context: context,
                    message: 'Verification failed',
                    type: SnackBarType.error,
                  );
                }
              },
              textButton: 'Confirm',
            ),
          ],
        ),
      ),
    );
  }
}
