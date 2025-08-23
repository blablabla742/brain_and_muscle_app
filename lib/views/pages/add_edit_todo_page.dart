import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_bloc.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_event.dart';
import 'package:brain_and_muscle_app/models/todo_model.dart';
import 'package:brain_and_muscle_app/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditTodoPage extends StatefulWidget {
  const AddEditTodoPage({super.key});

  @override
  State<AddEditTodoPage> createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends State<AddEditTodoPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  DateTime? _dueDate;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Neue Aufgabe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titel"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Titel eingeben" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Beschreibung"),
              ),

              // 🔽 Dropdown für Kategorien
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("Keine Kategorien vorhanden");
                  }

                  final categories = snapshot.data!.docs
                      .map((doc) => Category.fromFirestore(doc))
                      .toList();

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Kategorie"),
                    value: _selectedCategoryId,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id, // 👉 ID wird gespeichert
                            child: Text(cat.name), // 👉 Name wird angezeigt
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Kategorie wählen" : null,
                  );
                },
              ),

              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(labelText: "Zugewiesen an"),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? "Kein Fälligkeitsdatum gewählt"
                          : "Fällig am ${DateFormat('dd.MM.yyyy').format(_dueDate!)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 730)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                    child: const Text("Datum wählen"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Speichern"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newTodo = Todo(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      categoryId:
                          _selectedCategoryId!, // 👉 ID wird gespeichert
                      assignedTo: _assignedToController.text,
                      description: _descriptionController.text,
                      isDone: false,
                      status: "Offen",
                      dueDate: _dueDate,
                    );
                    context.read<TodoBloc>().add(AddTodo(newTodo));
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
