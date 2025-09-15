// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/models/todo_item.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/todoitem_viewmodel.dart';
import 'package:to_do_list_app/widget/todo_modal.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  String selectedCategory = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int userId = 0;
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user['id'] ?? 0;
      });
    }
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
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
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked == startDate || picked == endDate) {
        showCustomSnackBar(
          context: context,
          message: 'The starting date and ending is not overlapping',
        );
        return;
      }

      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate.add(const Duration(days: 1));
          }
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) {
            startDate = endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void handleCreateTask() async {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final todoitemVM = Provider.of<TodoItemViewModel>(context, listen: false);
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || selectedCategory.isEmpty) {
      showCustomSnackBar(
        context: context,
        message: 'Please fill in information',
        type: SnackBarType.error,
      );
      return;
    }

    final task = Task(
      userId: userId,
      title: title,
      category: selectedCategory,
      description: description,
      dateStart: startDate,
      dateEnd: endDate,
      isDone: false,
      todos: [],
    );

    final result = await taskVM.createTask(task);

    if (!result) {
      showCustomSnackBar(
        context: context,
        message: taskVM.errorMessage ?? 'Failed to create task',
        type: SnackBarType.error,
      );
      return;
    }

    // Tạo todos kèm theo
    final createdTask = taskVM.tasks.last;
    for (final todo in todos) {
      await todoitemVM.createTodo(
        createdTask.id!,
        TodoItem(
          taskId: createdTask.id!,
          content: todo['content'],
          isDone: todo['is_done'] ?? false,
        ),
      );
    }

    showCustomSnackBar(
      context: context,
      message: 'New task has been created successfully',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: AppColors.primary,
          title: Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Text(
              'Add Task',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: buildDatePicker(
                        'Start',
                        startDate,
                        () => pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: buildDatePicker(
                        'End',
                        endDate,
                        () => pickDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Title',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                buildTextField(titleController, 'Enter title'),
                const SizedBox(height: 24),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    buildCategoryButton('Priority Task', 'Priority'),
                    const SizedBox(width: 12),
                    buildCategoryButton('Daily Task', 'Daily'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                buildTextField(
                  descriptionController,
                  'Enter description',
                  maxLines: 5,
                ),
                if (selectedCategory == 'Priority') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'To do List',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyElevatedButton(
                    onPressed: () => showAddTodoModal(),
                    textButton: '+',
                  ),
                ],
                if (todos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Column(
                    children:
                        todos.map((todo) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.disabledTertiary,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      todo['content'],
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    value: todo['is_done'] == true,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
                const SizedBox(height: 32),
                MyElevatedButton(
                  onPressed: handleCreateTask,
                  textButton: 'Create Task',
                  isLoading: taskVM.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.unfocusedIcon),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/calendar-add-task.svg',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM-dd-yyyy').format(date),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unfocusedIcon),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.unfocusedIcon),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
    );
  }

  Widget buildCategoryButton(String label, String value) {
    final bool isSelected = selectedCategory == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.unfocusedDate,
            ),
            color: isSelected ? AppColors.primary : AppColors.defaultText,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.defaultText : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void showAddTodoModal() {
    final newTodoController = TextEditingController();
    bool isDone = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => TodoModal(
            title: 'New To do',
            controller: newTodoController,
            onSubmit: () async {
              final content = newTodoController.text.trim();
              if (content.isEmpty) return;
              Navigator.pop(context);
              try {
                setState(() {
                  todos.add({'content': content, 'is_done': isDone});
                });
                showCustomSnackBar(
                  context: context,
                  message: 'To do created successfully',
                );
              } catch (e) {
                showCustomSnackBar(
                  context: context,
                  message: 'To do create failed: $e',
                  type: SnackBarType.error,
                );
              }
            },
          ),
    );
  }
}
