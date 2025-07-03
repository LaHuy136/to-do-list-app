// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:to_do_list_app/components/my_bottom_navbar.dart';
import 'package:to_do_list_app/screens/profile/my_profile.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = '';
  String profession = '';
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user['username'] ?? '';
        profession = user['profession'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            top: 160,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
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
                          loadUserData();
                        }
                      },
                    ),

                    // Statistics
                    SizedBox(height: 30),
                    itemProfile(
                      'assets/icons/analytics.svg',
                      'Statistics',
                      () {},
                    ),

                    // Location
                    SizedBox(height: 30),
                    itemProfile('assets/icons/location.svg', 'Location', () {}),

                    SizedBox(height: 30),
                    // Settings
                    itemProfile('assets/icons/settings.svg', 'Settings', () {}),

                    SizedBox(height: 30),
                    // Logout
                    itemProfile('assets/icons/log-out.svg', 'Logout', () {}),
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
                    userName,
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
                    profession,
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
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/location.svg',
                              width: 24,
                              height: 24,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 32),
                        Container(
                          width: 2,
                          height: 20,
                          color: AppColors.unfocusedIcon,
                        ),
                        SizedBox(width: 2),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/location.svg',
                              width: 24,
                              height: 24,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Task Completed',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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
            left: MediaQuery.of(context).size.width / 2 - 50, // căn giữa
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/images/verify-account.png'),
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
