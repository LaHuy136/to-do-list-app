// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  DateTime? formattedDob;
  File? avatar;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('avatar_path');

    if (savedPath != null && File(savedPath).existsSync()) {
      avatar = File(savedPath);
    }

    if (user != null) {
      setState(() {
        nameController.text = user['username'] ?? '';
        professionController.text = user['profession'] ?? '';
        final parseDob = DateTime.tryParse(user['dateofbirth'] ?? '');
        if (parseDob != null) {
          formattedDob = parseDob;
          dobController.text = DateFormat('MMM-dd-yyyy').format(parseDob);
        }
        emailController.text = user['email'] ?? '';
      });
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formattedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.defaultText,
              onSurface: AppColors.bgprogessBar,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        formattedDob = picked;
        dobController.text = DateFormat('MMM-dd-yyyy').format(picked);
      });
    }
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');

      imageCache.clear();
      imageCache.clearLiveImages();

      setState(() {
        avatar = savedImage;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', savedImage.path);
    }
  }

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
              'My Profile',
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
          topLeft: Radius.circular(56),
          topRight: Radius.circular(56),
        ),
        child: Container(
          height: double.infinity,
          color: AppColors.defaultText,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),

                // Avatar
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 45,
                          key: ValueKey(avatar?.path),
                          backgroundImage:
                              avatar != null
                                  ? FileImage(avatar!) as ImageProvider
                                  : AssetImage(
                                    'assets/images/verify-account1.png',
                                  ),
                        ),
                      ),
                      GestureDetector(
                        onTap: pickAndSaveImage,
                        child: Container(
                          margin: EdgeInsets.only(top: 60),
                          child: SvgPicture.asset(
                            'assets/icons/edit.svg',
                            width: 24,
                            height: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Name
                buildContent('Name', nameController),

                SizedBox(height: 24),

                // Profession
                buildContent('Profession', professionController),

                SizedBox(height: 24),

                // Date of Birth
                buildContent('Date of Birth', dobController, isDob: true),

                SizedBox(height: 24),

                // Email
                buildContent('Email', emailController),

                SizedBox(height: 55),

                // Button Save
                MyElevatedButton(
                  onPressed: () async {
                    final success = await AuthAPI.updateUser(
                      email: emailController.text,
                      username: nameController.text,
                      profession: professionController.text,
                      dateOfBirth: DateFormat(
                        'yyyy-MM-dd',
                      ).format(formattedDob!),
                    );

                    if (success) {
                      showCustomSnackBar(
                        context: context,
                        message: 'New profile has been successfully updated',
                      );
                      Navigator.pop(context, true);
                    } else {
                      showCustomSnackBar(
                        context: context,
                        message: 'Failed to update profile',
                      );
                    }
                  },
                  textButton: 'Save',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent(
    String text,
    TextEditingController controller, {
    bool isDob = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: isDob ? true : false,
          decoration: InputDecoration(
            prefixIcon:
                isDob
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: InkWell(
                          onTap: pickDate,
                          child: SvgPicture.asset(
                            'assets/icons/calendar-add-task.svg',
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    : null,
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
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
      ],
    );
  }
}
