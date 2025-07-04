import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskAPI {
  static const String baseUrl = 'http://192.168.38.126:3000/task';

  static Future<List<dynamic>> getAllTasks({int? userId}) async {
    final url = Uri.parse(
      userId != null ? '$baseUrl?user_id=$userId' : baseUrl,
    );
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load tasks');
  }

  static Future<dynamic> getTaskById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load task');
  }

  static Future<List<dynamic>> getTasksByCategory({
    required String category,
    int? userId,
  }) async {
    final url = Uri.parse(
      userId != null
          ? '$baseUrl?category=$category&user_id=$userId'
          : '$baseUrl?category=$category',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load tasks by category');
  }

  static Future<dynamic> createTask(Map<String, dynamic> task) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to create task');
  }

  static Future<dynamic> updateTask(int id, Map<String, dynamic> task) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update task');
  }

  static Future<void> deleteTask(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200) throw Exception('Failed to delete task');
  }

  static Future<Map<String, dynamic>> fetchStatistics(
    int userId,
    int year,
  ) async {
    final url = Uri.parse('$baseUrl/statistic?user_id=$userId&year=$year');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List monthlyData = data['monthly'];

      List<double> monthlyCompletion =
          monthlyData.map<double>((item) {
            final total = item['total'] ?? 0;
            final completed = item['completed'] ?? 0;
            return total > 0 ? completed / total : 0.0;
          }).toList();

      return {
        'monthly': monthlyCompletion,
        'total': data['totalTasks'] ?? 0,
        'completed': data['completedTasks'] ?? 0,
      };
    } else {
      throw Exception('Failed to load statistics');
    }
  }
}
