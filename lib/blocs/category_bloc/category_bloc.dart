import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'category_event.dart';
import 'category_state.dart';
import '../../repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository; //Verbindung zur Datenquelle
  StreamSubscription?
  _categorySubscription; //Um laufende Stream-Subscription später wieder zu beenden (z. B. bei close())

  CategoryBloc(this.categoryRepository) : super(CategoryLoading()) {
    //Konstruktor der Basisklasse wird mit einem initialen Zustand aufgerufen – in diesem Fall CategoryLoading()
    on<LoadCategories>(
      _onLoadCategories,
    ); //Reagiere auf diesen Event-Typ mit dieser Handler-Funktion, die ausgeführt wird
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<CategoriesUpdated>(_onCategoriesUpdated);
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) {
    _categorySubscription?.cancel();
    _categorySubscription = categoryRepository.getCategories().listen(
      (categories) => add(CategoriesUpdated(categories)),
    );
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await categoryRepository.addCategory(event.category);
    } catch (_) {
      emit(CategoryError('Fehler beim Hinzufügen der Kategorie'));
    }
  }

  void _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      //await categoryRepository.updateCategory(event.category);
      await categoryRepository.updateCategory(event.category);
    } catch (_) {
      emit(CategoryError('Fehler beim Aktualisieren der Kategorie'));
    }
  }

  void _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await categoryRepository.deleteCategory(event.id);
    } catch (_) {
      emit(CategoryError('Fehler beim Löschen der Kategorie'));
    }
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(CategoryLoaded(event.categories));
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    return super.close();
  }
}
