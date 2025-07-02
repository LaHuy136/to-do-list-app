// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/screens/edit_task.dart';
import 'package:to_do_list_app/services/task.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class CalendarPriority extends StatefulWidget {
  final List<Map<String, dynamic>> priotyTasks;
  final String category;
  final int userId;
  final DateTime selectedDate;
  const CalendarPriority({
    super.key,
    required this.priotyTasks,
    required this.category,
    required this.userId,
    required this.selectedDate,
  });

  @override
  State<CalendarPriority> createState() => _CalendarPriorityState();
}

class _CalendarPriorityState extends State<CalendarPriority> {
  @override
  Widget build(BuildContext context) {
    final filteredTasks =
        widget.priotyTasks.where((t) {
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
        final start = DateTime.tryParse(task['date_start'] ?? '');
        final end = DateTime.tryParse(task['date_end'] ?? '');
        final dateStart =
            start != null ? DateFormat('MMM, d').format(start) : '';
        final dateEnd = end != null ? DateFormat('MMM, d').format(end) : '';

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
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditTask(
                                        taskId: task['id'],
                                        title: task['title'],
                                        category: task['category'],
                                        description: task['description'],
                                        dateStart: task['date_start'],
                                        dateEnd: task['date_end'],
                                        isDone: task['is_done'],
                                      ),
                                ),
                              );
                              Navigator.pop(context);
                              if (result == true) {
                                try {
                                  final updatedTask = await TaskAPI.getTaskById(
                                    task['id'],
                                  );
                                  setState(() {
                                    final index = widget.priotyTasks.indexWhere(
                                      (t) => t['id'] == task['id'],
                                    );
                                    if (index != -1) {
                                      widget.priotyTasks[index] = updatedTask;
                                    }
                                  });
                                  showCustomSnackBar(
                                    context: context,
                                    message: 'Task updated successfully',
                                  );
                                } catch (e) {
                                  showCustomSnackBar(
                                    context: context,
                                    message: 'Failed to reload updated task',
                                    type: SnackBarType.error,
                                  );
                                }
                              }
                            },
                            textButton: ("Edit Task"),
                          ),

                          // Delete Button
                          SizedBox(height: 20),
                          MyElevatedButton(
                            onPressed: () async {
                              try {
                                await TaskAPI.deleteTask(task['id']);
                                setState(() {
                                  widget.priotyTasks.removeWhere(
                                    (t) => t['id'] == task['id'],
                                  );
                                });
                                Navigator.pop(context);
                                showCustomSnackBar(
                                  context: context,
                                  message: 'Task deleted successfully',
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                showCustomSnackBar(
                                  context: context,
                                  message: 'Error delete task: ${e.toString()}',
                                );
                              }
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
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),

                    SvgPicture.asset(
                      'assets/icons/dots-three.svg',
                      width: 28,
                      height: 28,
                      color: AppColors.unfocusedIcon,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  task['description'] ?? 'No Description',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 8),
                // Date Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox.shrink(),
                    Text(
                      '$dateStart - $dateEnd',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
