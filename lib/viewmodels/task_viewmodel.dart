import 'package:flutter/foundation.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/services/task.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> _tasks = [];
  Task? _selectedTask;
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Lấy toàn bộ task
  Future<void> fetchTasks({int? userId}) async {
    _setLoading(true);
    try {
      final res = await TaskAPI.getAllTasks(userId: userId);
      _tasks = res.map<Task>((json) => Task.fromJson(json)).toList();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy task theo ID
  Future<void> fetchTaskById(int id) async {
    _setLoading(true);
    try {
      final res = await TaskAPI.getTaskById(id);
      _selectedTask = Task.fromJson(res);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy task theo category
  Future<void> fetchTasksByCategory(String category, {int? userId}) async {
    _setLoading(true);
    try {
      final res = await TaskAPI.getTasksByCategory(category: category, userId: userId);
      _tasks = res.map<Task>((json) => Task.fromJson(json)).toList();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Tạo task
  Future<bool> createTask(Task task) async {
    _setLoading(true);
    try {
      final res = await TaskAPI.createTask(task.toJson());
      final newTask = Task.fromJson(res);
      _tasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật task
  Future<bool> updateTask(Task task) async {
    _setLoading(true);
    try {
      final res = await TaskAPI.updateTask(task.id!, task.toJson());
      final updatedTask = Task.fromJson(res);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xoá task
  Future<bool> deleteTask(int id) async {
    _setLoading(true);
    try {
      await TaskAPI.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Thống kê task
  Future<Map<String, dynamic>?> fetchStatistics(int userId, int year) async {
    _setLoading(true);
    try {
      final stats = await TaskAPI.fetchStatistics(userId, year);
      _setError(null);
      return stats;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
