// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/components/my_bottom_navbar.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/views/profile/location_screen.dart';
import 'package:to_do_list_app/views/profile/my_profile_screen.dart';
import 'package:to_do_list_app/views/profile/settings_screen.dart';
import 'package:to_do_list_app/views/profile/statistic_screen.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/auth_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/widget/custom_dialog.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? avatar;
  String? selectedAddress;
  bool rememberMe = true;
  bool isLoading = true;
  List<double> monthlyCompletion = List.filled(12, 0);
  int totalTasks = 0;
  int completedTasks = 0;
  int currentYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    loadAddress();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('avatar_path');

    avatar = null;

    if (savedPath != null && File(savedPath).existsSync()) {
      avatar = File(savedPath);
    }

    loadStatistics(DateTime.now().year);
  }

  void loadStatistics(int year) async {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    try {
      final result = await taskVM.fetchStatistics(user!.id, year);
      if (result != null) {
        setState(() {
          monthlyCompletion = result['monthly'];
          totalTasks = result['total'];
          completedTasks = result['completed'];
          currentYear = year;
          isLoading = false;
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Statistic is empty',
          type: SnackBarType.error,
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Loading statistics error',
        type: SnackBarType.error,
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('address');

    if (address != null && mounted) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            top: 160,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(56),
                topRight: Radius.circular(56),
              ),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(color: AppColors.defaultText),
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 150),
                    // Profile
                    itemProfile(
                      'assets/icons/profile.svg',
                      'My Profile',
                      () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyProfile()),
                        );

                        if (result == true) {
                          loadData();
                        }
                      },
                    ),

                    // Statistics
                    SizedBox(height: 30),
                    itemProfile(
                      'assets/icons/analytics.svg',
                      'Statistics',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Statistic(userId: user!.id),
                        ),
                      ),
                    ),

                    // Location
                    SizedBox(height: 30),
                    itemProfile(
                      'assets/icons/location.svg',
                      'Location',
                      () async {
                        final selectedAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Location(),
                          ),
                        );

                        if (selectedAddress != null) {
                          setState(() {
                            this.selectedAddress = selectedAddress;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 30),
                    // Settings
                    itemProfile(
                      'assets/icons/settings.svg',
                      'Settings',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  Settings(email: user!.email, userId: user.id),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    // Logout
                    itemProfile('assets/icons/log-out.svg', 'Logout', () async {
                      await showDialog(
                        context: context,
                        builder:
                            (_) => CustomDialogContent(
                              title: 'Logout of Taskwan?',
                              buttonText: 'Logout',
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                if (!rememberMe) {
                                  await prefs.remove('token');
                                }
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                              onRememberMeChanged: (val) => rememberMe = val,
                            ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Profile góc trái
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.defaultText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Widget nổi
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.only(
                top: 60,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.defaultText,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(blurRadius: 4, color: AppColors.unfocusedDate),
                ],
              ),
              child: Column(
                children: [
                  // User name
                  Text(
                    user?.username ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 10),
                  // Profession
                  Text(
                    user?.profession ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 10),
                  // Location & Task completed
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/location.svg',
                                width: 24,
                                height: 24,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  selectedAddress ?? 'Location',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16),
                        Container(
                          width: 2,
                          height: 20,
                          color: AppColors.unfocusedIcon,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/complete.svg',
                                width: 24,
                                height: 24,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$completedTasks Task Completed',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar nổi
          Positioned(
            top: 80,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 45,
                backgroundImage:
                    avatar != null
                        ? FileImage(avatar!)
                        : const AssetImage('assets/images/avatar.png'),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: MyBottomNavbar(),
    );
  }

  Widget itemProfile(String svgPath, String item, void Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // svgPath
            SvgPicture.asset(
              svgPath,
              width: 28,
              height: 28,
              color: AppColors.primary,
            ),
            SizedBox(width: 32),
            // item
            Text(
              item,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
