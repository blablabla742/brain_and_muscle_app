import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_bloc.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_state.dart';
import 'package:brain_and_muscle_app/models/todo_model.dart';
import 'package:brain_and_muscle_app/views/pages/add_edit_todo_page.dart';
import 'package:brain_and_muscle_app/views/widgets/todo_daysection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodosOverview extends StatefulWidget {
  const TodosOverview({super.key});

  @override
  State<TodosOverview> createState() => _TodosOverviewState();
}

class _TodosOverviewState extends State<TodosOverview> {
  String _filter = "withDate"; // Standard: mit DueDate
  // Gruppiert die To-Dos nach Datum
  Map<String, List<Todo>> groupTodosByDate(List<Todo> todos) {
    Map<String, List<Todo>> grouped = {};
    for (var todo in todos) {
      if (todo.dueDate == null) continue; // nur mit Datum gruppieren
      if (todo.isDone) continue; //nur offene Todos
      String dateKey = todo.dueDate!.toIso8601String().substring(0, 10);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(todo);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine To-Dos nach Datum'),
        actions: [Icon(Icons.sort)],
      ),
      body: Column(
        // 🔽 NEU (statt nur BlocBuilder direkt)
        children: [
          // 🔽 Filterauswahl (zwei Optionen nebeneinander)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Mit Fälligkeitsdatum"),
                  selected: _filter == "withDate",
                  onSelected: (_) {
                    setState(() => _filter = "withDate");
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Ohne Fälligkeitsdatum"),
                  selected: _filter == "withoutDate",
                  onSelected: (_) {
                    setState(() => _filter = "withoutDate");
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TodoLoaded) {
                  final todos = state.todos;

                  if (_filter == "withDate") {
                    final groupedTodos = groupTodosByDate(todos);
                    final sortedDates = groupedTodos.keys.toList()..sort();
                    return ListView.builder(
                      itemCount: groupedTodos.length, //sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        String date = sortedDates[dateIndex];
                        return TodoDaySection(
                          date: date,
                          todos: groupedTodos[date]!,
                        );
                      },
                    );
                  } else {
                    final todosWithoutDate = todos
                        .where((t) => t.dueDate == null)
                        .toList();
                    return ListView.builder(
                      itemCount: todosWithoutDate.length,
                      itemBuilder: (context, index) {
                        final todo = todosWithoutDate[index];
                        return ListTile(
                          title: Text(todo.title),
                          subtitle: Text(todo.description ?? ""),
                        );
                      },
                    );
                  }
                } else if (state is TodoError) {
                  return Center(child: Text('Fehler: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditTodoPage()));
        },
        //_showAddTodoDialog(context),
      ),
    );
  }

  /*void _showAddTodoDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Neue Aufgabe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DatePickerDialog(
              initialEntryMode: DatePickerEntryMode.inputOnly,
              initialDate: DateTime.now(),
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2026, 1, 1),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Hinzufügen'),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final newTodo = Todo(
                  id: DateTime.now().toString(),
                  title: controller.text,
                  categoryId: '1',
                  assignedTo: 'Phillo',
                  description: 'Ganz schön viel zu tun',
                  isDone: false,
                  status: 'Offen',
                  dueDate: DateTime.now(),
                );
                context.read<TodoBloc>().add(AddTodo(newTodo));
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }*/
}
