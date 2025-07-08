// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/components/my_bottom_navbar.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/provider/notification.provider.dart';
import 'package:to_do_list_app/screens/notification.dart';
import 'package:to_do_list_app/screens/tasks/task_section.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/services/task.dart';

import 'package:to_do_list_app/theme/app_colors.dart';

class TaskManagement extends StatefulWidget {
  const TaskManagement({super.key});

  @override
  State<TaskManagement> createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  int userId = 0;
  String username = '';
  String formattedDate = '';
  List<Map<String, dynamic>> priorityTasks = [];
  List<Map<String, dynamic>> dailyTasks = [];
  bool hasNotification = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    formattedDate = DateFormat('EEEE, MMM d yyyy').format(DateTime.now());
    loadTasks();
    checkNotificationStatus();
  }

  Future<void> loadTasks() async {
    try {
      final allTasks = await TaskAPI.getAllTasks();
      setState(() {
        priorityTasks =
            allTasks
                .where((t) => t['category'] == 'Priority')
                .toList()
                .cast<Map<String, dynamic>>();
        dailyTasks =
            allTasks
                .where((t) => t['category'] == 'Daily')
                .toList()
                .cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Lỗi khi tải tasks: $e');
    }
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user['id'] ?? 0;
        username = user['username'] ?? '';
      });
    }
  }

  Future<void> checkNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('notifications') ?? [];
    final hasUnread = stored.any((e) {
      final item = NotificationItem.fromJson(jsonDecode(e));
      return !item.isRead;
    });

    setState(() {
      hasNotification = hasUnread;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        backgroundColor: AppColors.defaultText,
        elevation: 0,
        leadingWidth: 180,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: Text(
            formattedDate,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    hasNotification = result;
                  });
                }
                if (result == false || result == 'cleared') {
                  setState(() {
                    hasNotification = false;
                  });
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/icons/notification.svg',
                    width: 28,
                    height: 28,
                    color: AppColors.primary,
                  ),

                  if (hasNotification == true)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.destructive,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Welcome $username',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Have a nice day ! ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 32),
            TaskSection(
              tasks: priorityTasks,
              category: 'Priority',
              userId: userId,
              onTaskChanged: loadTasks,
            ),
            const SizedBox(height: 15),
            TaskSection(
              tasks: dailyTasks,
              category: 'Daily',
              userId: userId,
              onTaskChanged: loadTasks,
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavbar(),
    );
  }
}
