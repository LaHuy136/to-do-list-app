// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/screens/tasks/edit_task.dart';
import 'package:to_do_list_app/services/task.dart';
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
  List<Map<String, dynamic>> priorityTasks = [];
  List<Map<String, dynamic>> dailyTasks = [];
  @override
  void initState() {
    super.initState();
    loadTasks();
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
                                        onTaskChanged: loadTasks,
                                      ),
                                ),
                              );
                              Navigator.pop(context);
                              if (result == true) {
                                try {
                                  final updatedTask = await TaskAPI.getTaskById(
                                    task['id'],
                                  );
                                  await loadTasks(); 
                                  setState(() {
                                    final index = widget.dailyTasks.indexWhere(
                                      (t) => t['id'] == task['id'],
                                    );
                                    if (index != -1) {
                                      widget.dailyTasks[index] = updatedTask;
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
                                  widget.dailyTasks.removeWhere(
                                    (t) => t['id'] == task['id'],
                                  );
                                });
                                Navigator.pop(context);
                                showCustomSnackBar(
                                  context: context,
                                  message: 'Task has been deleted successfully',
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
