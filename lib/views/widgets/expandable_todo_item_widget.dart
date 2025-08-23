import 'package:brain_and_muscle_app/blocs/category_bloc/category_bloc.dart';
import 'package:brain_and_muscle_app/blocs/category_bloc/category_state.dart';
import 'package:brain_and_muscle_app/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:brain_and_muscle_app/models/todo_model.dart';
import 'package:brain_and_muscle_app/models/subtask_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/todo_bloc/todo_bloc.dart';
import '../../blocs/todo_bloc/todo_event.dart';

class ExpandableTodoItem extends StatefulWidget {
  final Todo todo;

  const ExpandableTodoItem({super.key, required this.todo});

  @override
  State<ExpandableTodoItem> createState() => _ExpandableTodoItemState();
}

class _ExpandableTodoItemState extends State<ExpandableTodoItem> {
  //bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  Todo? lastCompletedTodo; // das zuletzt abgeschlossene Todo

  @override
  void initState() {
    super.initState();
    /*print(
      '[DEBUG] ${widget.todo.title} hat ${widget.todo.subtasks.length} Subtasks.',
    );*/
  }

  void addSubtaskToTodo(String title) {
    final newSubtask = Subtask(title: title, isDone: false);
    final updatedSubtasks = List<Subtask>.from(widget.todo.subtasks)
      ..add(newSubtask);
    final updatedTodo = widget.todo.copyWith(subtasks: updatedSubtasks);

    context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
    _controller.clear();
  }

  void toggleSubtaskDone(int index) {
    final updatedSubtasks = List<Subtask>.from(widget.todo.subtasks);
    updatedSubtasks[index] = updatedSubtasks[index].copyWith(
      isDone: !updatedSubtasks[index].isDone,
    );
    final updatedTodo = widget.todo.copyWith(subtasks: updatedSubtasks);
    context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
  }

  void removeSubtaskFromTodo(int index) {
    final updatedSubtasks = List<Subtask>.from(widget.todo.subtasks)
      ..removeAt(index);
    final updatedTodo = widget.todo.copyWith(subtasks: updatedSubtasks);
    context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: CheckboxListTile(
            checkboxShape: CircleBorder(),
            title: Text(
              widget.todo.title,
              style: TextStyle(
                decoration: widget.todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            value: widget.todo.isDone,
            onChanged: (value) {
              final updatedTodo = widget.todo.copyWith(isDone: value);
              context.read<TodoBloc>().add(UpdateTodo(updatedTodo));

              if (value == true) lastCompletedTodo = widget.todo;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value!
                        ? 'Aufgabe "${widget.todo.title}" abgeschlossen'
                        : 'Aufgabe "${widget.todo.title}" reaktiviert',
                  ),
                  action: SnackBarAction(
                    label: '↩️ Rückgängig', // 🔹 Emoji als Icon-Alternative
                    onPressed: () {
                      if (lastCompletedTodo != null) {
                        final undoneTodo = lastCompletedTodo!.copyWith(
                          isDone: false,
                        );
                        context.read<TodoBloc>().add(UpdateTodo(undoneTodo));
                      }
                    },
                    textColor: Colors.white,
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          subtitle: Row(
            spacing: 5.0,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 15.0,
                child: Text(
                  widget.todo.assignedTo ?? '',
                  style: const TextStyle(fontSize: 10.0),
                ),
              ),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    final category = state.categories.firstWhere(
                      (c) => c.id == widget.todo.categoryId,
                      orElse: () => Category(
                        id: widget.todo.categoryId,
                        name: 'Unbekannt',
                        createdAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          category.name,
                          style: const TextStyle(fontSize: 10.0),
                        ),
                      ),
                    );
                  } else if (state is CategoryLoading) {
                    return const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else {
                    return const Text("Kategorie nicht gefunden");
                  }
                },
              ),
            ],
          ),
          children: [
            ...[
              //Du brauchst ...[], weil du mehrere Widgets (Checkboxen + Row) in einem einzigen if-Zweig zurückgibst.
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Row(children: [Text(widget.todo.description!)]),
              ),
              ...widget.todo.subtasks.asMap().entries.map((entry) {
                int index = entry.key;
                Subtask subtask = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: subtask.isDone,
                    onChanged: (val) => toggleSubtaskDone(index),
                    title: Text(
                      subtask.title,
                      style: TextStyle(
                        decoration: subtask.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    secondary: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeSubtaskFromTodo(index),
                    ),
                  ),
                );
              }),

              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Neue Unteraufgabe',
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          addSubtaskToTodo(_controller.text.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ],
        ),
      ],
    );
  }
}
