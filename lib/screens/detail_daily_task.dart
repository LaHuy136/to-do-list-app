// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/services/task.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class DetailDailyTask extends StatefulWidget {
  final int taskId;
  const DetailDailyTask({super.key, required this.taskId});

  @override
  State<DetailDailyTask> createState() => _DetailDailyTaskState();
}

class _DetailDailyTaskState extends State<DetailDailyTask> {
  double progress(List todos) {
    if (todos.isEmpty) return 0.0;
    final completed = todos.where((t) => t['is_done'] == true).length;
    return completed / todos.length;
  }

  Map<String, dynamic> calculateTimeDiff(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      final duration = end.difference(start);
      return {
        'type': 'same-day',
        'hours': duration.inHours,
        'minutes': duration.inMinutes % 60,
      };
    } else {
      int months = (end.year - start.year) * 12 + (end.month - start.month);
      int days = end.difference(start).inDays % 30; // gần đúng
      int hours = end.difference(start).inHours % 24;

      return {'type': 'range', 'months': months, 'days': days, 'hours': hours};
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return FutureBuilder(
      future: TaskAPI.getTaskById(widget.taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          );
        }
        final task = snapshot.data;
        final startDate = DateTime.parse(task['date_start']);
        final endDate = DateTime.parse(task['date_end']);
        final isExpired = DateTime.parse(
          task['date_end'],
        ).isBefore(DateTime.now());
        final timeData = calculateTimeDiff(startDate, endDate);

        return Scaffold(
          backgroundColor: AppColors.defaultText,
          appBar: AppBar(
            backgroundColor: AppColors.defaultText,
            elevation: 0,
            leadingWidth: 360,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                task['title'] ?? 'Task Detail',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primary,
                  ),
                  padding: EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/close.svg',
                      width: 16,
                      height: 16,
                      color: AppColors.defaultText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Task
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date Start
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'start',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            task['date_start'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Date End
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'end',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            task['date_end'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  // Container Date Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...(timeData['type'] == 'same-day'
                          ? [
                            buildTimeBox('${timeData['hours']}', 'hours'),
                            SizedBox(width: 10),
                            buildTimeBox('${timeData['minutes']}', 'minutes'),
                          ]
                          : [
                            buildTimeBox('${timeData['months']}', 'months'),
                            SizedBox(width: 10),
                            buildTimeBox('${timeData['days']}', 'days'),
                            SizedBox(width: 10),
                            buildTimeBox('${timeData['hours']}', 'hours'),
                          ]),
                    ],
                  ),

                  SizedBox(height: 20),
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    task['description'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 20),
                  // Button Finish
                  MyElevatedButton(
                    isLoading: isLoading,
                    onPressed:
                        isExpired
                            ? null
                            : () {
                              Navigator.pop(context, true);
                            },
                    textButton: isExpired ? 'Expired' : 'Finish',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget buildTimeBox(String value, String label) {
  return Expanded(
    child: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.defaultText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.defaultText,
            ),
          ),
        ],
      ),
    ),
  );
}
