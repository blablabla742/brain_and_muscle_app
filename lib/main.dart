import 'package:brain_and_muscle_app/blocs/category_bloc/category_bloc.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_bloc.dart';
import 'package:brain_and_muscle_app/blocs/todo_bloc/todo_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'blocs/category_bloc/category_event.dart';
import 'data/notifiers.dart';
import 'firebase_options.dart';
import 'repositories/category_repository.dart';
import 'repositories/todo_repository.dart';
import 'views/widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('de_DE', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final categoryRepository = CategoryRepository();
  final todoRepository = TodoRepository();

  runApp(
    MyApp(
      categoryRepository: categoryRepository,
      todoRepository: todoRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final CategoryRepository categoryRepository;
  final TodoRepository todoRepository;

  const MyApp({
    super.key,
    required this.categoryRepository,
    required this.todoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<TodoBloc>(
              create: (_) => TodoBloc(todoRepository)..add(LoadTodos()),
            ),
            BlocProvider<CategoryBloc>(
              create: (_) =>
                  CategoryBloc(categoryRepository)..add(LoadCategories()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
            ),
            home: WidgetTree(),
          ),
        );
      },
    );
  }
}
