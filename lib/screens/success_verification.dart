import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class SuccessVerification extends StatelessWidget {
  const SuccessVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        backgroundColor: AppColors.defaultText,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              'assets/images/verify-account1.png',
              width: 200,
              height: 200,
            ),

            const SizedBox(height: 10),
            // Subtil Image
            const Text(
              'Your Account has been Verified Successfully!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 70),
            // Button Go To DashBoard
            MyElevatedButton(
              onPressed:
                  () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    ModalRoute.withName('/home'),
                  ),
              textButton: 'Go to Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}
