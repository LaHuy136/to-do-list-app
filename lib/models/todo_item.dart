class TodoItem {
  final int? id;
  final int taskId;
  final String content;
  final bool isDone;

  TodoItem({
    this.id,
    required this.taskId,
    required this.content,
    this.isDone = false,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] != null ? json['id'] as int : null,
      taskId: json['task_id'] != null ? json['task_id'] as int : 0,
      content: json['content'] as String? ?? '',
      isDone: (json['is_done'] is bool)
          ? json['is_done'] as bool
          : (json['is_done'] == 1 || json['is_done'] == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'content': content,
      'is_done': isDone,
    };
  }

  TodoItem copyWith({
    int? id,
    int? taskId,
    String? content,
    bool? isDone,
  }) {
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
