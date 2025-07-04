// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/services/message.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class Help extends StatefulWidget {
  final int userId;
  const Help({super.key, required this.userId});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
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
              'Help',
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
          height: double.infinity,
          color: AppColors.defaultText,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Text(
                      'Tell us how we can help',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 12),
                    buildTextField(subjectController, 'Type message subject'),

                    const SizedBox(height: 24),

                    buildTextField(
                      messageController,
                      'Type some message.......',
                      maxLines: 10,
                    ),

                    const SizedBox(height: 24),

                    // Button Submit
                    MyElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        setState(() => isLoading = true);

                        try {
                          await MessageAPI.sendMessage(
                            userId: widget.userId,
                            subject: subjectController.text.trim(),
                            message: messageController.text.trim(),
                          );
                          FocusScope.of(context).unfocus();
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(
                                    'Success',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  content: Text(
                                    'Your message has been sent.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => {Navigator.pop(context)},
                                      child: Text(
                                        'OK',
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
                          subjectController.clear();
                          messageController.clear();
                          formKey.currentState!.reset();
                        } catch (e) {
                          showCustomSnackBar(
                            context: context,
                            message: e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                            type: SnackBarType.error,
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                      isLoading: isLoading,
                      textButton: 'Send',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      autofocus: false,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unfocusedIcon),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unfocusedIcon),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
    );
  }
}
