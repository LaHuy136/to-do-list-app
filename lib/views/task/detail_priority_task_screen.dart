// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/helpers/general_helper.dart';
import 'package:to_do_list_app/models/todo_item.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/todoitem_viewmodel.dart';

class DetailPriorityTask extends StatefulWidget {
  final int taskId;
  const DetailPriorityTask({super.key, required this.taskId});

  @override
  State<DetailPriorityTask> createState() => _DetailPriorityTaskState();
}

class _DetailPriorityTaskState extends State<DetailPriorityTask> {
  final editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TaskViewModel>(
        context,
        listen: false,
      ).fetchTaskById(widget.taskId);
      Provider.of<TodoItemViewModel>(
        context,
        listen: false,
      ).fetchTodosByTask(widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, TodoItemViewModel>(
      builder: (context, taskVM, todoVM, child) {
        final task = taskVM.selectedTask;
        final todos = todoVM.todos;
        final isLoading = taskVM.isLoading;

        if (isLoading && task == null) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
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

        final taskProgress = progress(todos.map((t) => t.toJson()).toList());
        final startDate = task.dateStart;
        final endDate = task.dateEnd;
        final timeData = calculateTimeDiff(startDate, endDate);
        final isExpired = endDate.isBefore(DateTime.now());

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
                padding: const EdgeInsets.only(right: 16, top: 8),
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

                // Progress
                const SizedBox(height: 20),
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: taskProgress,
                        backgroundColor: AppColors.bgprogessBar,
                        color: AppColors.primary,
                        minHeight: 20,
                      ),
                      Text(
                        '${(taskProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.defaultText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Todo List
                const SizedBox(height: 20),
                const Text(
                  'To do List',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final taskCompleted =
                        todos.isNotEmpty &&
                        todos.every((t) => t.isDone == true);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          _showEditDeleteModal(context, todoVM, todo);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.disabledTertiary,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  todo.content,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        (isExpired ||
                                                taskCompleted ||
                                                todo.isDone)
                                            ? AppColors.primary
                                            : AppColors.bgprogessBar,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: todo.isDone,
                                onChanged: (value) async {
                                  await todoVM.updateTodo(
                                    todo.copyWith(isDone: value ?? false),
                                  );
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Add Todo
                const SizedBox(height: 10),
                MyElevatedButton(
                  onPressed: () => _showAddTodoModal(context, todoVM),
                  textButton: '+',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateColumn(String label, DateTime value, {bool isEnd = false}) {
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
          value.toIso8601String().substring(0, 11),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showEditDeleteModal(
    BuildContext context,
    TodoItemViewModel todoVM,
    todo,
  ) {
    editingController.text = todo.content;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
              TextField(
                controller: editingController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'To do Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  MyElevatedButton(
                    onPressed: () async {
                      final newContent = editingController.text.trim();
                      if (newContent.isEmpty) return;
                      Navigator.pop(context);
                      await todoVM.updateTodo(
                        todo.copyWith(content: newContent),
                      );
                      showCustomSnackBar(
                        context: context,
                        message: 'To do updated successfully',
                        type: SnackBarType.success,
                      );
                    },
                    textButton: "Edit To do",
                  ),
                  const SizedBox(height: 20),
                  MyElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await todoVM.deleteTodo(widget.taskId, todo.id);
                      showCustomSnackBar(
                        context: context,
                        message: 'To do deleted successfully',
                        type: SnackBarType.success,
                      );
                    },
                    textButton: 'Delete To do',
                  ),
                  const SizedBox(height: 20),
                  MyElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    textButton: 'Cancel',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTodoModal(BuildContext context, TodoItemViewModel todoVM) {
    final newTodoController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
              TextField(
                controller: newTodoController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'New To do',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  MyElevatedButton(
                    onPressed: () async {
                      final content = newTodoController.text.trim();
                      if (content.isEmpty) return;
                      Navigator.pop(context);
                      await todoVM.createTodo(
                        widget.taskId,
                        TodoItem(
                          taskId: widget.taskId,
                          content: newTodoController.text.trim(),
                          isDone: false,
                        ),
                      );
                      showCustomSnackBar(
                        context: context,
                        message: 'To do added successfully',
                        type: SnackBarType.success,
                      );
                    },
                    textButton: 'Add To do',
                  ),
                  const SizedBox(height: 20),
                  MyElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    textButton: 'Cancel',
                  ),
                ],
              ),
            ],
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
