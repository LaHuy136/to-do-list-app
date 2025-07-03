import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class CustomDialogContent extends StatefulWidget {
  final String title;
  final Color? backgroundColorIcon;
  final String buttonText;
  final VoidCallback onPressed;
  final ValueChanged<bool> onRememberMeChanged;
  const CustomDialogContent({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.backgroundColorIcon,
    required this.onRememberMeChanged,
  });

  @override
  State<CustomDialogContent> createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<CustomDialogContent> {
  @override
  Widget build(BuildContext context) {
    bool rememberLogin = true;
    return Dialog(
      backgroundColor: AppColors.defaultText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.unfocusedDate),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: rememberLogin,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          rememberLogin = val ?? false;
                          widget.onRememberMeChanged(rememberLogin);
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Remember my login info',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.bgprogessBar,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout button
                MyElevatedButton(
                  onPressed: widget.onPressed,
                  textButton: widget.buttonText,
                ),

                const SizedBox(height: 18),

                // Cancel button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.bgprogessBar,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
