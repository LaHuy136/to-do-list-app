// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/models/todo_item.dart';
import 'package:to_do_list_app/services/todo.dart';

class TodoItemViewModel extends ChangeNotifier {
  final List<Task> _tasks = [];
  List<TodoItem> _todos = [];
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  List<TodoItem> get todos => _todos;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách todo theo taskId
  Future<bool> fetchTodosByTask(int taskId) async {
    try {
      final data = await TodoAPI.getTodosByTask(taskId);
      _todos = data.map<TodoItem>((e) => TodoItem.fromJson(e)).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }

  /// Tạo todo mới
  Future<bool> createTodo(int taskId, TodoItem todo) async {
    try {
      final data = await TodoAPI.createTodo(taskId, todo.toJson());
      final newTodo = TodoItem.fromJson(data);

      _todos.add(newTodo);

      // Nếu muốn đồng bộ Task -> cũng update luôn
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index].todos.add(newTodo);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Cập nhật todo
  Future<bool> updateTodo(
    TodoItem todo, {
    bool? isDone,
    String? content,
  }) async {
    try {
      final payload = todo.copyWith(
        isDone: isDone ?? todo.isDone,
        content: content ?? todo.content,
      );

      final updatedJson = await TodoAPI.updateTodo(todo.id!, payload.toJson());
      final updatedTodo = TodoItem.fromJson(updatedJson);

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Xoá todo
  Future<bool> deleteTodo(int taskId, int todoId) async {
    try {
      await TodoAPI.deleteTodo(todoId);

      // xoá trong todos state
      _todos.removeWhere((td) => td.id == todoId);

      // đồng bộ với tasks nếu có
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].todos.removeWhere((td) => td.id == todoId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
