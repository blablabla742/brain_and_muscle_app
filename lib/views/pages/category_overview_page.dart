import 'package:brain_and_muscle_app/blocs/category_bloc/category_bloc.dart';
import 'package:brain_and_muscle_app/blocs/category_bloc/category_event.dart';
import 'package:brain_and_muscle_app/blocs/category_bloc/category_state.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_bloc.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_state.dart';
import 'package:brain_and_muscle_app/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryOverviewPage extends StatefulWidget {
  const CategoryOverviewPage({super.key});

  @override
  State<CategoryOverviewPage> createState() => _CategoryOverviewPageState();
}

class _CategoryOverviewPageState extends State<CategoryOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meine Kategorien")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;
                  return BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, todoState) {
                      Map<String, int> todosPerCategory = {};
                      if (todoState is TodoLoaded) {
                        for (var cat in categories) {
                          final count = todoState.todos
                              .where((t) => t.categoryId == cat.id && !t.isDone)
                              .length;
                          todosPerCategory[cat.id] = count;
                        }
                      }

                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(cat.colorValue),
                              child: Text(cat.name.characters.first),
                            ),
                            title: Text(cat.name),
                            subtitle: Text(
                              "${todosPerCategory[cat.id] ?? 0} offene Todos",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditCategoryDialog(context, cat),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _confirmDeleteCategory(cat);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is CategoryError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDeleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Kategorie löschen?"),
        content: Text(
          'Willst du die Kategorie "${category.name}" wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
              Navigator.of(context).pop();
            },
            child: const Text("Löschen"),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Neue Kategorie"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Farbe: "),
                GestureDetector(
                  onTap: () async {
                    // Farbe auswählen
                    Color? color = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Farbe auswählen"),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (color) {
                              selectedColor = color;
                              Navigator.of(context).pop(color);
                            },
                          ),
                        ),
                      ),
                    );
                    if (color != null) setState(() => selectedColor = color);
                  },
                  child: CircleAvatar(backgroundColor: selectedColor),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().toString(),
                  name: name,
                  createdAt: DateTime.now(),
                  colorValue: selectedColor.value,
                );
                context.read<CategoryBloc>().add(AddCategory(newCategory));
                Navigator.of(context).pop();
              }
            },
            child: const Text("Hinzufügen"),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final TextEditingController nameController = TextEditingController(
      text: category.name,
    );

    Color selectedColor = Color(category.colorValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kategorie bearbeiten"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (var color in [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                    Colors.grey,
                  ])
                    GestureDetector(
                      onTap: () {
                        selectedColor = color;
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Speichern"),
              onPressed: () {
                final updatedCategory = category.copyWith(
                  name: nameController.text.trim(),
                  createdAt: category.createdAt, // unverändert
                  id: category.id, // bleibt gleich
                  colorValue: selectedColor.value,
                );

                context.read<CategoryBloc>().add(
                  UpdateCategory(updatedCategory),
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
