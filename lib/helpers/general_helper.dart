double progress(List todos) {
  if (todos.isEmpty) return 0.0;
  final completed = todos.where((t) => t['is_done'] == true).length;
  return completed / todos.length;
}

int daysLeft(String start, String end) {
  final startDate = DateTime.parse(start);
  final endDate = DateTime.parse(end);
  return endDate.difference(startDate).inDays;
}

List<DateTime> getDaysInMonth(DateTime date) {
  final first = DateTime(date.year, date.month, 1);
  final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
  return List.generate(daysInMonth, (i) => first.add(Duration(days: i)));
}

Map<String, dynamic> calculateTimeDiff(DateTime start, DateTime end) {
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    final duration = end.difference(start);
    return {
      'type': 'same-day',
      'hours': duration.inHours,
      'minutes': duration.inMinutes % 60,
    };
  } else {
    int months = (end.year - start.year) * 12 + (end.month - start.month);
    int days = end.difference(start).inDays % 30;
    int hours = end.difference(start).inHours % 24;

    return {'type': 'range', 'months': months, 'days': days, 'hours': hours};
  }
}
