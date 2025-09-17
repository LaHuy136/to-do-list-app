// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/helpers/general_helper.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';

class DetailDailyTask extends StatefulWidget {
  final int taskId;
  const DetailDailyTask({super.key, required this.taskId});

  @override
  State<DetailDailyTask> createState() => _DetailDailyTaskState();
}

class _DetailDailyTaskState extends State<DetailDailyTask> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TaskViewModel>(
        context,
        listen: false,
      ).fetchTaskById(widget.taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskVM, child) {
        final task = taskVM.selectedTask;
        final isLoading = taskVM.isLoading;

        if (isLoading && task == null) {
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

        if (task == null) {
          return Center(
            child: Text(
              taskVM.errorMessage ?? "Không tìm thấy task",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final startDate = task.dateStart;
        final endDate = task.dateEnd;
        final isExpired = endDate.isBefore(DateTime.now());
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
                task.title,
                style: const TextStyle(
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
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, true),
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
                  // Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateColumn("start", task.dateStart),
                      _buildDateColumn("end", task.dateEnd, isEnd: true),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Time Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...(timeData['type'] == 'same-day'
                          ? [
                            buildTimeBox('${timeData['hours']}', 'hours'),
                            const SizedBox(width: 10),
                            buildTimeBox('${timeData['minutes']}', 'minutes'),
                          ]
                          : [
                            buildTimeBox('${timeData['months']}', 'months'),
                            const SizedBox(width: 10),
                            buildTimeBox('${timeData['days']}', 'days'),
                            const SizedBox(width: 10),
                            buildTimeBox('${timeData['hours']}', 'hours'),
                          ]),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Finish Button
                  MyElevatedButton(
                    isLoading: taskVM.isLoading,
                    onPressed:
                        isExpired
                            ? null
                            : () async {
                              final updated = task.copyWith(isDone: true);
                              final success = await taskVM.updateTask(updated);
                              if (success) {
                                showCustomSnackBar(
                                  context: context,
                                  message:
                                      'Update daily task as done is successfully',
                                );
                                Navigator.pop(context, true);
                              } else {
                                showCustomSnackBar(
                                  context: context,
                                  message:
                                      'Update daily task as done is failed',
                                );
                              }
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

  Widget _buildDateColumn(String label, DateTime value, {bool isEnd = false}) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(value);
    return Column(
      crossAxisAlignment:
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          formattedDate,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.defaultText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
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
