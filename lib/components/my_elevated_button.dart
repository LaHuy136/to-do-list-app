import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class MyElevatedButton extends StatefulWidget {
  final void Function()? onPressed;
  final String textButton;
  final bool isLoading;

  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.textButton,
    this.isLoading = false,
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
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            widget.isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.defaultText,
                    ),
                  ),
                )
                : Text(
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
