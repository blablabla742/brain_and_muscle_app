import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'todo_event.dart';
import 'todo_state.dart';
import '../../repositories/todo_repository.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository; //Verbindung zur Datenquelle
  StreamSubscription?
  _todoSubscription; //Um laufende Stream-Subscription später wieder zu beenden (z. B. bei close())

  TodoBloc(this.todoRepository) : super(TodoLoading()) {
    //Konstruktor der Basisklasse wird mit einem initialen Zustand aufgerufen – in diesem Fall TodoLoading()
    on<LoadTodos>(
      _onLoadTodos,
    ); //Reagiere auf diesen Event-Typ mit dieser Handler-Funktion, die ausgeführt wird
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<TodosUpdated>(_onTodosUpdated);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) {
    _todoSubscription?.cancel();
    _todoSubscription = todoRepository.getTodos().listen(
      (todos) => add(TodosUpdated(todos)),
    );
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await todoRepository.addTodo(event.todo);
    } catch (_) {
      emit(TodoError('Fehler beim Hinzufügen der Kategorie'));
    }
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      //await todoRepository.updateTodo(event.todo);
      await todoRepository.updateTodo(event.todo);
    } catch (_) {
      emit(TodoError('Fehler beim Aktualisieren der Kategorie'));
    }
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await todoRepository.deleteTodo(event.id);
    } catch (_) {
      emit(TodoError('Fehler beim Löschen der Kategorie'));
    }
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodoState> emit) {
    emit(TodoLoaded(event.todos));
  }

  @override
  Future<void> close() {
    _todoSubscription?.cancel();
    return super.close();
  }
}
