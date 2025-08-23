import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'todos';

  Stream<List<Todo>> getTodos() {
    return _firestore
        .collection(collectionPath)
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addTodo(Todo todo) async {
    final docRef = _firestore.collection(collectionPath).doc();
    final newTodo = todo.copyWith(id: docRef.id);
    await docRef.set(newTodo.toMap());
  }

  Future<void> updateTodo(Todo todo) async {
    await _firestore
        .collection(collectionPath)
        .doc(todo.id)
        .update(todo.toMap());
  }

  Future<void> deleteTodo(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}
