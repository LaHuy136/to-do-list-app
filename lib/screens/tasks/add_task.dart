// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/services/auth.dart';
import 'package:to_do_list_app/services/task.dart';
import 'package:to_do_list_app/services/todo.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
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
  final TextEditingController editingController = TextEditingController();
  bool isLoading = false;
  int userId = 0;
  List<dynamic> todos = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
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
      // Ngày trùng nhau → không cho chọn
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
    if (isLoading) return;
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

    final task = {
      'title': title,
      'description': description,
      'category': selectedCategory,
      'date_start': DateFormat('yyyy-MM-dd').format(startDate),
      'date_end': DateFormat('yyyy-MM-dd').format(endDate),
      'user_id': userId,
    };

    setState(() => isLoading = true);
    try {
      final taskResult = await TaskAPI.createTask(task);
      final taskId = taskResult['id'];

      for (final todo in todos) {
        await TodoAPI.createTodo({
          'content': todo['content'],
          'is_done': todo['is_done'] ?? false,
        }, taskId);
      }

      showCustomSnackBar(
        context: context,
        message: 'New task has been created successfully',
      );
      Navigator.pop(context, true);
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadUserData() async {
    final user = await AuthAPI.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user['id'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: AppColors.primary,
          title: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
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
              margin: EdgeInsets.only(left: 8, top: 8),
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
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          height: double.infinity,
          color: AppColors.defaultText,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                // Start and End Date
                Row(
                  children: [
                    Expanded(
                      child: buildDatePicker(
                        'Start',
                        startDate,
                        () => pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 16),
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

                // Title
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

                // Category
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

                // Description
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
                  // To Do Item
                  const SizedBox(height: 24),
                  Text(
                    'To do List',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 6),

                  // Add To do
                  MyElevatedButton(
                    onPressed: () {
                      showAddTodoModal();
                    },
                    textButton: '+',
                  ),
                ],
                if (todos.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Column(
                    children:
                        todos
                            .map(
                              (todo) => Container(
                                padding: EdgeInsets.all(8),
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
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: todo['is_done'] == true,
                                      activeColor: AppColors.primary,
                                      onChanged: (value) async {},
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],

                SizedBox(height: 32),

                // Create Button
                MyElevatedButton(
                  onPressed: handleCreateTask,
                  textButton: 'Create Task',
                  isLoading: isLoading,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            onSubmit: () {
              final content = newTodoController.text.trim();
              if (content.isEmpty) return;
              setState(() {
                todos.add({'content': content, 'is_done': isDone});
              });
              Navigator.pop(context);
            },
          ),
    );
  }
}
