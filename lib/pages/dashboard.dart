// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:to_do_list_app/components/my_bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/screens/task_section.dart';
import 'package:to_do_list_app/services/task.dart';

import 'package:to_do_list_app/theme/app_colors.dart';

class TaskManagement extends StatefulWidget {
  const TaskManagement({super.key});

  @override
  State<TaskManagement> createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  late int userid;
  String username = '';
  String formattedDate = '';
  List<Map<String, dynamic>> priotyTasks = [];
  List<Map<String, dynamic>> dailyTasks = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    formattedDate = DateFormat('EEEE, MMM d yyyy').format(DateTime.now());
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final allTasks = await TaskAPI.getAllTasks(); // hoặc từ API của bạn
      setState(() {
        priotyTasks =
            allTasks
                .where((t) => t['category'] == 'Prioty')
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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      userid = prefs.getInt('id') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        backgroundColor: AppColors.defaultText,
        elevation: 0,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: Text(
            formattedDate,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                'assets/icons/notification.svg',
                width: 28,
                height: 28,
                color: AppColors.primary,
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
            TaskSection(tasks: priotyTasks, category: 'Prioty', userId: userid,),
            const SizedBox(height: 15),
            TaskSection(tasks: dailyTasks, category: 'Daily', userId: userid,),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavbar(),
    );
  }
}
