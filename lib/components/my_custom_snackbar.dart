import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

enum SnackBarType { normal, success, error }

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  SnackBarType type = SnackBarType.normal,
}) {
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = AppColors.success;
      break;
    case SnackBarType.error:
      backgroundColor = AppColors.destructive;
      break;
    case SnackBarType.normal:
      backgroundColor = AppColors.success;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: AppColors.defaultText,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
