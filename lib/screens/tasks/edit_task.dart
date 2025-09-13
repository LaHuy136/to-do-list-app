// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable, must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/services/task.dart';
import 'package:to_do_list_app/services/todo.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/widget/todo_modal.dart';

class EditTask extends StatefulWidget {
  final int taskId;
  final String title;
  final String category;
  final String description;
  final String dateStart;
  final String dateEnd;
  final bool isDone;
  final VoidCallback onTaskChanged;
  const EditTask({
    super.key,
    required this.taskId,
    required this.title,
    required this.category,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.isDone,
    required this.onTaskChanged,
  });

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController editingController = TextEditingController();
  bool isLoading = false;
  bool isDone = false;
  int userId = 0;
  late DateTime dateStart;
  late DateTime dateEnd;
  List<dynamic> todos = [];

  @override
  void initState() {
    super.initState();
    dateStart = DateTime.parse(widget.dateStart);
    dateEnd = DateTime.parse(widget.dateEnd);
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    isDone = widget.isDone;
    fetchTodos();
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? dateStart : dateEnd,
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
      setState(() {
        if (isStart) {
          dateStart = picked;
          if (dateStart.isAfter(dateEnd)) {
            dateEnd = dateStart.add(const Duration(days: 1));
          }
        } else {
          dateEnd = picked;
          if (dateEnd.isBefore(dateStart)) {
            dateStart = dateEnd.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void handleUpdateTask() async {
    if (isLoading) return;
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
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
      'category': widget.category,
      'date_start': DateFormat('yyyy-MM-dd').format(dateStart),
      'date_end': DateFormat('yyyy-MM-dd').format(dateEnd),
      'is_done': isDone,
    };

    setState(() => isLoading = true);
    try {
      final result = await TaskAPI.updateTask(widget.taskId, task);
      Navigator.pop(context, true);
    } catch (e) {
      print('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTodos() async {
    try {
      todos = await TodoAPI.getTodosByTask(widget.taskId);
      setState(() {});
    } catch (e) {
      print('Lỗi khi tải todos: $e');
      showCustomSnackBar(context: context, message: 'Error loading list todo');
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
              'Edit Task',
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
            onTap: () => Navigator.pop(context, false),
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
                SizedBox(height: 30),
                // Start and End Date
                Row(
                  children: [
                    Expanded(
                      child: buildDatePicker(
                        'Start',
                        dateStart,
                        () => pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildDatePicker(
                        'End',
                        dateEnd,
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

                buildCategoryText('${widget.category} Task'),

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

                const SizedBox(height: 12),

                // Checkbox is_done
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: Text(
                    'Mark as done',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  value: isDone,
                  onChanged: (value) {
                    setState(() {
                      isDone = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 12),
                if (widget.category == 'Priority') ...[
                  // To Do Item
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final taskCompleted =
                          todos.isNotEmpty &&
                          todos.every((t) => t['is_done'] == true);
                      final isExpired = DateTime.parse(
                        widget.dateEnd,
                      ).isBefore(DateTime.now());
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            showEditTodoModal(todo);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.disabledTertiary,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onChanged: (value) async {
                                    try {
                                      await TodoAPI.updateTodo(todo['id'], {
                                        ...todo,
                                        'is_done': value,
                                      });
                                      widget.onTaskChanged();
                                      await fetchTodos();
                                    } catch (e) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: 'Update failed: $e',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Add To do
                  SizedBox(height: 10),
                  MyElevatedButton(
                    onPressed: () {
                      showAddTodoModal();
                    },
                    textButton: '+',
                  ),
                ],
                SizedBox(height: 32),

                // Create Button
                MyElevatedButton(
                  onPressed: handleUpdateTask,
                  textButton: 'Edit Task',
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

  Widget buildCategoryText(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
        color: AppColors.primary,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.defaultText,
        ),
      ),
    );
  }

  void showEditTodoModal(Map<String, dynamic> todo) {
    editingController.text = todo['content'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => TodoModal(
            title: 'Edit To do',
            controller: editingController,
            onSubmit: () async {
              final newContent = editingController.text.trim();
              if (newContent.isEmpty) return;
              Navigator.pop(context);
              try {
                await TodoAPI.updateTodo(todo['id'], {
                  ...todo,
                  'content': newContent,
                });
                editingController.clear();
                await fetchTodos();
                showCustomSnackBar(
                  context: context,
                  message: 'To do updated successfully',
                );
              } catch (e) {
                showCustomSnackBar(
                  context: context,
                  message: 'To do update failed: $e',
                  type: SnackBarType.error,
                );
              }
            },
            onDelete: () async {
              Navigator.pop(context);
              try {
                await TodoAPI.deleteTodo(todo['id']);
                await fetchTodos();
                showCustomSnackBar(
                  context: context,
                  message: 'Deleted successfully',
                );
              } catch (e) {
                showCustomSnackBar(
                  context: context,
                  message: 'Delete failed: $e',
                  type: SnackBarType.error,
                );
              }
            },
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
                await TodoAPI.createTodo(widget.taskId, {
                  'content': content,
                  'is_done': isDone,
                });
                await fetchTodos();
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
