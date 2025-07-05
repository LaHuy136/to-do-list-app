import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_custom_showDialog.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({super.key});

  @override
  State<SettingsAbout> createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
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
              'About',
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
          width: double.infinity,
          height: double.infinity,
          color: AppColors.defaultText,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'TASK-WAN',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(48),
                      bottomRight: Radius.circular(48),
                    ),
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primary),
                    ),
                  ),

                  SizedBox(height: 17),
                  // Version
                  Text(
                    'Version 2.22.18',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 10),
                  // CopyRight
                  Text(
                    '©2025 TaskWan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 158),
                  GestureDetector(
                    onTap:
                        () => MyCustomDialog.show(
                          context: context,
                          title: 'Nofitication',
                          content: 'Thank you for using task-wan app',
                        ),
                    child: Text(
                      'LICENSES',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
