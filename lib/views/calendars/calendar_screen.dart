// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_bottom_navbar.dart';
import 'package:to_do_list_app/helpers/general_helper.dart';
import 'package:to_do_list_app/views/task/add_task_screen.dart';
import 'package:to_do_list_app/views/calendars/calendar_daily_screen.dart';
import 'package:to_do_list_app/views/calendars/calendar_priority_screen.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  String formattedDate = '';
  DateTime selectedDate = DateTime.now();
  late TabController _tabController;
  late ScrollController scrollController;
  final double itemWidth = 82;

  int userId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    formattedDate = DateFormat('MMM, yyyy').format(DateTime.now());
    scrollController = ScrollController();
    loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int todayIndex = selectedDate.day - 1;
      scrollController.animateTo(
        todayIndex * itemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user['id'] ?? 0;
      });

      final taskVM = context.read<TaskViewModel>();
      await taskVM.fetchTasks(userId: userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void handleDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.defaultText,
              onSurface: AppColors.bgprogessBar,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('MMM, yyyy').format(picked);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        int dayIndex = picked.day - 1;
        scrollController.animateTo(
          dayIndex * itemWidth,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = getDaysInMonth(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: AppBar(
        backgroundColor: AppColors.defaultText,
        elevation: 0,
        leadingWidth: 360,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: InkWell(
            onTap: handleDatePicker,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 28,
                  height: 28,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTask()),
                );

                if (result == true) {
                  context.read<TaskViewModel>().fetchTasks(userId: userId);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/add.svg',
                      width: 24,
                      height: 24,
                      color: AppColors.defaultText,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Add Task',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.defaultText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Horizontal day scroller
          SizedBox(
            height: 95,
            width: double.infinity,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final weekday = DateFormat.E().format(day);
                final dayNum = day.day.toString();
                final isSelected =
                    day.day == selectedDate.day &&
                    day.month == selectedDate.month &&
                    day.year == selectedDate.year;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedDate = day;
                      formattedDate = DateFormat('MMM, yyyy').format(day);
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      int dayIndex = day.day - 1;
                      scrollController.animateTo(
                        dayIndex * itemWidth,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: Container(
                    width: isSelected ? 95 : 75,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding:
                        isSelected
                            ? const EdgeInsets.all(24)
                            : const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.unfocusedDate,
                      border: Border.all(color: AppColors.disabledTertiary),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekday,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isSelected ? 14 : 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isSelected
                                    ? AppColors.defaultText
                                    : AppColors.primary,
                          ),
                        ),
                        Text(
                          dayNum,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isSelected ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? AppColors.defaultText
                                    : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4, color: AppColors.primary),
              insets: EdgeInsets.symmetric(horizontal: 36),
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.bgprogessBar,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: const [Tab(text: 'Priority Task'), Tab(text: 'Daily Task')],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CalendarPriority(
                  category: 'Priority',
                  userId: userId,
                  selectedDate: selectedDate,
                ),
                CalendarDaily(
                  category: 'Daily',
                  userId: userId,
                  selectedDate: selectedDate,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavbar(),
    );
  }
}
