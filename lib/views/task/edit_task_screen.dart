// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable, must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/components/my_custom_snackbar.dart';
import 'package:to_do_list_app/components/my_elevated_button.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/models/todo_item.dart';
import 'package:to_do_list_app/theme/app_colors.dart';
import 'package:to_do_list_app/viewmodels/auth_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/task_viewmodel.dart';
import 'package:to_do_list_app/viewmodels/todoitem_viewmodel.dart';
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
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    super.initState();
    dateStart = DateTime.parse(widget.dateStart);
    dateEnd = DateTime.parse(widget.dateEnd);
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    isDone = widget.isDone;
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.loadUser().then((_) {
      setState(() {
        userId = authVM.currentUser?.id ?? 0;
      });
    });
    fetchTodos();
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? dateStart : dateEnd,
      firstDate: DateTime.now(),
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
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);

    setState(() => isLoading = true);

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      showCustomSnackBar(
        context: context,
        message: 'Please fill in information',
        type: SnackBarType.error,
      );
      setState(() => isLoading = false);
      return;
    }

    final task = Task(
      id: widget.taskId,
      userId: userId,
      title: title,
      category: widget.category,
      description: description,
      dateStart: dateStart,
      dateEnd: dateEnd,
      isDone: isDone,
      todos: [],
    );

    try {
      final result = await taskVM.updateTask(task);
      if (!result) {
        if (!mounted) return;
        showCustomSnackBar(
          context: context,
          message: 'Failed to update task',
          type: SnackBarType.error,
        );
        return;
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchTodos() async {
    final todoVM = Provider.of<TodoItemViewModel>(context, listen: false);
    try {
      final ok = await todoVM.fetchTodosByTask(widget.taskId);
      if (!mounted) return;

      if (ok) {
        setState(() {});
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Error loading list todo',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context: context,
        message: 'Error loading list todo',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final todos = context.watch<TodoItemViewModel>().todos;

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
                      final todoVM = Provider.of<TodoItemViewModel>(
                        context,
                        listen: false,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => showEditTodoModal(todo.toJson()),
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                                    todo.content,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: todo.isDone,
                                  activeColor: AppColors.primary,
                                  onChanged: (value) async {
                                    try {
                                      await todoVM.updateTodo(
                                        todo.copyWith(isDone: value),
                                      );
                                      await fetchTodos();
                                      widget.onTaskChanged();
                                    } catch (e) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: 'Update failed: $e',
                                        type: SnackBarType.error,
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
    final todoVM = Provider.of<TodoItemViewModel>(context, listen: false);
    editingController.text = todo['content'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (modalContext) => TodoModal(
            title: 'Edit To do',
            controller: editingController,
            onSubmit: () async {
              final newContent = editingController.text.trim();
              if (newContent.isEmpty) return;
              Navigator.pop(context);
              try {
                await todoVM.updateTodo(
                  TodoItem.fromJson(todo),
                  content: newContent,
                  isDone: todo['is_done'] as bool,
                );

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
                await todoVM.deleteTodo(widget.taskId, todo['id']);
                await fetchTodos();
                showCustomSnackBar(
                  context: context,
                  message: 'To do has been deleted successfully',
                );
              } catch (e) {
                showCustomSnackBar(
                  context: context,
                  message: 'Delete To do failed: $e',
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
    final todoVM = Provider.of<TodoItemViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => TodoModal(
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
