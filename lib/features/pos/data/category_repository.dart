import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosCategory {
  final String id;
  final String merchantId;
  final String name;
  final int orderIndex;
  final bool showInSelfOrder;

  PosCategory({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.orderIndex,
    this.showInSelfOrder = false,
  });

  PosCategory copyWith({
    String? id,
    String? merchantId,
    String? name,
    int? orderIndex,
    bool? showInSelfOrder,
  }) {
    return PosCategory(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      showInSelfOrder: showInSelfOrder ?? this.showInSelfOrder,
    );
  }
}

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories => _firestore.collection('merchant_categories');

  Stream<List<PosCategory>> streamCategories(String merchantId) {
    return _categories
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_docToCategory).toList();
          list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          return list;
        });
  }

  Future<void> createCategory(PosCategory category) async {
    final docRef = _categories.doc();
    await docRef.set({
      'merchantId': category.merchantId,
      'name': category.name,
      'orderIndex': category.orderIndex,
      'showInSelfOrder': category.showInSelfOrder,
    });
  }

  Future<void> updateCategory(PosCategory category) async {
    await _categories.doc(category.id).update({
      'name': category.name,
      'orderIndex': category.orderIndex,
      'showInSelfOrder': category.showInSelfOrder,
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categories.doc(categoryId).delete();
  }

  /// Bulk update categories for reordering
  Future<void> updateCategoriesOrder(List<PosCategory> updatedCategories) async {
    final batch = _firestore.batch();
    for (var cat in updatedCategories) {
      batch.update(_categories.doc(cat.id), {'orderIndex': cat.orderIndex});
    }
    await batch.commit();
  }

  PosCategory _docToCategory(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PosCategory(
      id: doc.id,
      merchantId: data['merchantId'] ?? '',
      name: data['name'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
      showInSelfOrder: data['showInSelfOrder'] ?? false,
    );
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});
