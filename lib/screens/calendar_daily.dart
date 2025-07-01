import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class CalendarDaily extends StatefulWidget {
  final List<Map<String, dynamic>> dailyTasks;
  final String category;
  final int userId;
  final DateTime selectedDate;
  const CalendarDaily({
    super.key,
    required this.dailyTasks,
    required this.category,
    required this.userId,
    required this.selectedDate,
  });

  @override
  State<CalendarDaily> createState() => _CalendarDailyState();
}

class _CalendarDailyState extends State<CalendarDaily> {
  @override
  Widget build(BuildContext context) {
    final filteredTasks =
        widget.dailyTasks.where((t) {
          final taskDate = DateTime.tryParse(t['date_start']);
          return t['category'] == widget.category &&
              t['user_id'] == widget.userId &&
              taskDate != null &&
              taskDate.year == widget.selectedDate.year &&
              taskDate.month == widget.selectedDate.month &&
              taskDate.day == widget.selectedDate.day;
        }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks available.',
          style: TextStyle(fontSize: 16, color: AppColors.disabledPrimary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        // final start = DateTime.tryParse(task['date_start'] ?? '');
        // final end = DateTime.tryParse(task['date_end'] ?? '');

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          // Edit Button
                          MyElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            textButton: ("Edit Task"),
                          ),

                          // Delete Button
                          SizedBox(height: 20),
                          MyElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            textButton: 'Delete Task',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.defaultText,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.unfocusedIcon),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task['title'] ?? 'No Title',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
