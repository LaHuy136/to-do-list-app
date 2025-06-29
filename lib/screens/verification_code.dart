import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/screens/success_verification.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class VerificationCode extends StatefulWidget {
  const VerificationCode({super.key});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
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
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            // Create your account
            const Text(
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

            const SizedBox(height: 10),
            // Subtil Image
            const Text(
              'Please enter the verification number we send to your email',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),
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
                // handle code change
              },
            ),
            Row(
              children: [
                const Text(
                  'Don\'t recieve a code? ',
                  style: TextStyle(
                    color: AppColors.disabledSecondary,
                    fontSize: 12,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Resend',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
            // Button Confirm
            MyElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessVerification(),
                    ),
                  ),
              textButton: 'Confirm',
            ),
          ],
        ),
      ),
    );
  }
}
