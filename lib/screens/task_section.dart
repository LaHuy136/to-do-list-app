import 'package:flutter/material.dart';
import 'package:to_do_list_app/screens/detail_daily_task.dart';
import 'package:to_do_list_app/screens/detail_priority_task.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class TaskSection extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final String category;
  final int userId;

  const TaskSection({
    super.key,
    required this.tasks,
    required this.category,
    required this.userId,
  });

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  int daysLeft(String start, String end) {
    final startDate = DateTime.parse(start);
    final endDate = DateTime.parse(end);
    return endDate.difference(startDate).inDays;
  }

  double progress(List todos) {
    if (todos.isEmpty) return 0.0;
    final completed = todos.where((t) => t['is_done'] == true).length;
    return completed / todos.length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks =
        widget.tasks
            .where((t) => t['category'] == widget.category && t['user_id'] == widget.userId)
            .toList();

    final List<Color> taskColors = [
      Color(0xFF68F4F4),
      Color(0xFFFFD166),
      Color(0xFFEF476F),
      Color(0xFF06D6A0),
      Color(0xFF118AB2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.category == 'Priority' ? 'My Priority Task' : 'Daily Task',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),

        if (widget.category == 'Priority')
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filteredTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    final taskTodos = task['todos'] ?? [];
                    final taskProgress = progress(taskTodos);
                    final taskColor = taskColors[index % taskColors.length];
                    final isExpired = DateTime.parse(
                      task['date_end'],
                    ).isBefore(DateTime.now());

                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DetailPriorityTask(taskId: task['id']),
                            ),
                          );
                        },
                        child: Container(
                          height: 300,
                          width: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: taskColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox.shrink(),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: AppColors.defaultText,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      isExpired
                                          ? 'Expired'
                                          : '${daysLeft(task['date_start'], task['date_end'])} days',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Text(
                                task['title'] ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: AppColors.defaultText,
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.defaultText,
                                ),
                              ),
                              LinearProgressIndicator(
                                value: taskProgress,
                                backgroundColor: AppColors.bgprogessBar,
                                color: AppColors.defaultText,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox.shrink(),
                                  Text(
                                    '${(taskProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: AppColors.defaultText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          )
        else
          Column(
            children:
                filteredTasks.map((task) {
                  final taskTodos = task['todos'] ?? [];
                  final isCompleted = task['is_done'] == true;
                  final taskCompleted =
                      taskTodos.isNotEmpty &&
                      taskTodos.every((t) => t['is_done'] == true);
                  final isExpired = DateTime.parse(
                    task['date_end'],
                  ).isBefore(DateTime.now());

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailDailyTask(taskId: task['id']),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            task['is_done'] = true;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.disabledTertiary),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              task['title'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    (isExpired || taskCompleted || isCompleted)
                                        ? AppColors.primary
                                        : AppColors.bgprogessBar,
                              ),
                            ),
                            Radio(
                              value: true,
                              groupValue: taskCompleted || isExpired || isCompleted,
                              onChanged: (_) {},
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
}
