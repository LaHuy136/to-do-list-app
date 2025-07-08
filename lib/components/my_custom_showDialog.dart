// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class MyCustomDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required void Function()? onPressed,
    bool isTwoButton = false,
    String confirmText = 'OK',
    Color? titleColor,
    Color? buttonColor,
  }) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            content: Text(
              content,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            actions: [
              isTwoButton
                  ? TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  )
                  : SizedBox.shrink(),
              TextButton(
                onPressed: onPressed,
                child: Text(
                  confirmText,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
