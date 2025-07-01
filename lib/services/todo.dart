import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoAPI {
  static const String baseUrl = 'http://192.168.38.126:3000/todoItem';

  static Future<List<dynamic>> getTodosByTask(int taskId) async {
    final res = await http.get(Uri.parse('$baseUrl/tasks/$taskId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load todos');
  }

  static Future<dynamic> createTodo(Map<String, dynamic> todo, int taskId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to create todo');
  }

  static Future<dynamic> updateTodo(int id, Map<String, dynamic> todo) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update todo');
  }

  static Future<void> deleteTodo(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200) throw Exception('Failed to delete todo');
  }
}
