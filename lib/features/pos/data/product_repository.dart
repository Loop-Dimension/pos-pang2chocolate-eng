import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosProduct {
  final String id;
  final String merchantId;
  final String categoryId;
  final String name;
  final int price;
  final String description;
  final String memo;
  final int? stockCount; // null means unlimited
  final bool showOnKitchenOrderForm;
  final bool showInSelfOrder;
  final List<String> imageUrls;
  final int gridIndex; // 1-36

  PosProduct({
    required this.id,
    required this.merchantId,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description = '',
    this.memo = '',
    this.stockCount,
    this.showOnKitchenOrderForm = true,
    this.showInSelfOrder = true,
    this.imageUrls = const [],
    required this.gridIndex,
  });

  PosProduct copyWith({
    String? id,
    String? merchantId,
    String? categoryId,
    String? name,
    int? price,
    String? description,
    String? memo,
    int? stockCount,
    bool? showOnKitchenOrderForm,
    bool? showInSelfOrder,
    List<String>? imageUrls,
    int? gridIndex,
    bool clearStockCount = false,
  }) {
    return PosProduct(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      stockCount: clearStockCount ? null : (stockCount ?? this.stockCount),
      showOnKitchenOrderForm: showOnKitchenOrderForm ?? this.showOnKitchenOrderForm,
      showInSelfOrder: showInSelfOrder ?? this.showInSelfOrder,
      imageUrls: imageUrls ?? this.imageUrls,
      gridIndex: gridIndex ?? this.gridIndex,
    );
  }
}

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('merchant_products');

  Stream<List<PosProduct>> streamProducts(String merchantId, String categoryId) {
    return _products
        .where('merchantId', isEqualTo: merchantId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_docToProduct).toList();
          list.sort((a, b) => a.gridIndex.compareTo(b.gridIndex));
          return list;
        });
  }

  Future<void> createProduct(PosProduct product) async {
    final docRef = _products.doc();
    await docRef.set({
      'merchantId': product.merchantId,
      'categoryId': product.categoryId,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'memo': product.memo,
      'stockCount': product.stockCount,
      'showOnKitchenOrderForm': product.showOnKitchenOrderForm,
      'showInSelfOrder': product.showInSelfOrder,
      'imageUrls': product.imageUrls,
      'gridIndex': product.gridIndex,
    });
  }

  Future<void> updateProduct(PosProduct product) async {
    await _products.doc(product.id).update({
      'categoryId': product.categoryId,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'memo': product.memo,
      'stockCount': product.stockCount,
      'showOnKitchenOrderForm': product.showOnKitchenOrderForm,
      'showInSelfOrder': product.showInSelfOrder,
      'imageUrls': product.imageUrls,
      'gridIndex': product.gridIndex,
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  Future<void> updateProductGridIndex(String productId, int newIndex) async {
    await _products.doc(productId).update({'gridIndex': newIndex});
  }

  Future<void> updateProductStock(String productId, int? newStockCount) async {
    await _products.doc(productId).update({'stockCount': newStockCount});
  }

  PosProduct _docToProduct(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PosProduct(
      id: doc.id,
      merchantId: data['merchantId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      memo: data['memo'] ?? '',
      stockCount: data['stockCount'],
      showOnKitchenOrderForm: data['showOnKitchenOrderForm'] ?? true,
      showInSelfOrder: data['showInSelfOrder'] ?? true,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      gridIndex: data['gridIndex'] ?? 0,
    );
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});
