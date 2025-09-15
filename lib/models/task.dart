import 'package:to_do_list_app/models/todo_item.dart';

class Task {
  final int? id;
  final int userId;
  final String title;
  final String category;
  final String description;
  final DateTime dateStart;
  final DateTime dateEnd;
  final bool isDone;

  final List<TodoItem> todos;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    this.isDone = false,
    this.todos = const [],
  });

  // Chuyển từ JSON (từ API BE) -> Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      dateStart: DateTime.parse(json['date_start']),
      dateEnd: DateTime.parse(json['date_end']),
      isDone: json['is_done'] ?? false,
      todos:
          json['todos'] != null
              ? (json['todos'] as List)
                  .map((item) => TodoItem.fromJson(item))
                  .toList()
              : [],
    );
  }

  // Chuyển từ Task object -> JSON (gửi API khi tạo/cập nhật)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'description': description,
      'date_start': dateStart.toIso8601String(),
      'date_end': dateEnd.toIso8601String(),
      'is_done': isDone,
      'todos': todos.map((t) => t.toJson()).toList(),
    };
  }

  Task copyWith({List<TodoItem>? todos}) {
    return Task(
      id: id,
      userId: userId,
      title: title,
      category: category,
      description: description,
      dateStart: dateStart,
      dateEnd: dateEnd,
      isDone: isDone,
      todos: todos ?? this.todos,
    );
  }
}
