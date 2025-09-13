class TodoItem {
  final int id;
  final int taskId;
  final String content;
  final bool isDone;

  TodoItem({
    required this.id,
    required this.taskId,
    required this.content,
    this.isDone = false,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      taskId: json['task_id'],
      content: json['content'],
      isDone: json['is_done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'task_id': taskId, 'content': content, 'is_done': isDone};
  }

  TodoItem copyWith({int? id, int? taskId, String? content, bool? isDone}) {
    return TodoItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  String toString() =>
      'TodoItem(id:$id, taskId:$taskId, content:$content, isDone:$isDone)';
}
