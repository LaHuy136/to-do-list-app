import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class MyTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool? enable;
  final bool isPassword;

  // final FocusNode? focusNode;
  // final TextInputAction? textInputAction;
  // final void Function(String)? onFieldSubmitted;
  const MyTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.isPassword = false,
    this.enable = true,
    this.suffixIcon,
    // this.focusNode,
    // this.textInputAction,
    // this.onFieldSubmitted,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      // focusNode: widget.focusNode,
      // textInputAction: widget.textInputAction ?? TextInputAction.next,
      // onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: widget.isPassword ? obscureText : false,
      validator: widget.validator,
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        prefixIconConstraints: const BoxConstraints(
          minHeight: 55,
          minWidth: 55,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  color: AppColors.disabledSecondary,
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
                : widget.suffixIcon,

        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        enabled: widget.enable!,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.unfocusedIcon),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.unfocusedIcon),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
