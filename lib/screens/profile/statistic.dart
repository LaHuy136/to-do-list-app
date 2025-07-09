// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:to_do_list_app/services/task.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class Statistic extends StatefulWidget {
  final int userId;
  const Statistic({super.key, required this.userId});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  int currentYear = DateTime.now().year;
  List<double> monthlyCompletion = List.filled(12, 0);
  int totalTasks = 0;
  int completedTasks = 0;
  bool isLoading = true;

  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  @override
  void initState() {
    super.initState();
    loadStatistics(currentYear);
  }

  void loadStatistics(int year) async {
    try {
      final result = await TaskAPI.fetchStatistics(widget.userId, year);
      setState(() {
        monthlyCompletion = result['monthly'];
        totalTasks = result['total'];
        completedTasks = result['completed'];
        currentYear = year;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: AppColors.primary,
          title: Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              'Statistic',
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
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút chọn năm
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 28),
                    onPressed: () {
                      final newYear = currentYear - 1;
                      setState(() {
                        isLoading = true;
                      });
                      loadStatistics(newYear);
                    },
                  ),
                  Text(
                    '$currentYear',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 28),
                    onPressed: () {
                      final newYear = currentYear + 1;
                      setState(() {
                        isLoading = true;
                      });
                      loadStatistics(newYear);
                    },
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Total & Completed Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Total Tasks
                  buildContainerTask('Total Tasks', totalTasks),
                  buildContainerTask('Completed Tasks', completedTasks),
                ],
              ),

              SizedBox(height: 24),

              // Biểu đồ từng tháng
              Expanded(
                child: GridView.builder(
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    double percent = monthlyCompletion[index];
                    return CircularPercentIndicator(
                      radius: 65,
                      lineWidth: 15,
                      percent: percent,
                      header: Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          monthNames[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      center: Text(
                        '${(percent * 100).round()}%',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      progressColor: AppColors.primary,
                      backgroundColor: AppColors.disabledSecondary,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainerTask(String title, int taskNumber) {
    return Container(
      width: 170,
      // height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.defaultText,
        boxShadow: [BoxShadow(blurRadius: 4, color: AppColors.unfocusedDate)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$taskNumber',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
