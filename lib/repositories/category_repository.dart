import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'categories';

  Stream<List<Category>> getCategories() {
    return _firestore
        .collection(collectionPath)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addCategory(Category category) async {
    final docRef = _firestore.collection(collectionPath).doc();
    final newCategory = category.copyWith(id: docRef.id);
    await docRef.set(newCategory.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore
        .collection(collectionPath)
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }
}
