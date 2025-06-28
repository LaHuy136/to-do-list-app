import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class MyElevatedButton extends StatefulWidget {
  final void Function()? onPressed;
  final String textButton;
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.textButton,
  });

  @override
  State<MyElevatedButton> createState() => _MyElevatedButtonState();
}

class _MyElevatedButtonState extends State<MyElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          widget.textButton,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.defaultText,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
