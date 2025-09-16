// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/views/task/edit_task_screen.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class CalendarDaily extends StatelessWidget {
  final String category;
  final int userId;
  final DateTime selectedDate;

  const CalendarDaily({
    super.key,
    required this.category,
    required this.userId,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context);
    bool isSameDay(DateTime d1, DateTime d2) {
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    }

    final filteredTasks =
        taskVM.tasks.where((task) {
          return (task.dateStart.isBefore(selectedDate) ||
                  isSameDay(task.dateStart, selectedDate)) &&
              (task.dateEnd.isAfter(selectedDate) ||
                  isSameDay(task.dateEnd, selectedDate));
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
                      MyElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditTask(
                                    taskId: task.id!,
                                    title: task.title,
                                    category: task.category,
                                    description: task.description,
                                    dateStart: task.dateStart.toIso8601String(),
                                    dateEnd: task.dateEnd.toIso8601String(),
                                    isDone: task.isDone,
                                    onTaskChanged: () async {
                                      await taskVM.fetchTasks(userId: userId);
                                    },
                                  ),
                            ),
                          );
                          Navigator.pop(context);
                          if (result == true) {
                            await taskVM.fetchTasks(userId: userId);
                            showCustomSnackBar(
                              context: context,
                              message: 'Task updated successfully',
                            );
                          }
                        },
                        textButton: ("Edit Task"),
                      ),
                      SizedBox(height: 20),
                      MyElevatedButton(
                        onPressed: () async {
                          final ok = await taskVM.deleteTask(task.id!);
                          Navigator.pop(context);
                          if (ok) {
                            await taskVM.fetchTasks(userId: userId);
                            showCustomSnackBar(
                              context: context,
                              message: 'Task has been deleted successfully',
                            );
                          }
                        },
                        textButton: 'Delete Task',
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
            child: Text(
              task.title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}
