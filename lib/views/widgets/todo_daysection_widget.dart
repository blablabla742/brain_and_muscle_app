import 'package:brain_and_muscle_app/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expandable_todo_item_widget.dart';

class TodoDaySection extends StatelessWidget {
  final String date;
  final List<Todo> todos;

  const TodoDaySection({super.key, required this.date, required this.todos});

  String _formatDate(String dateString) {
    // Datum parsen
    DateTime parsedDate = DateTime.parse(dateString);
    // Formatieren: Montag, 4. August 2025
    return DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _formatDate(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        ...todos.map((todo) {
          return ExpandableTodoItem(todo: todo);
        }).toList(),
        const Divider(),
      ],
    );
  }
}
