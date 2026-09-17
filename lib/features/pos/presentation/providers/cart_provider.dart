import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int productId;
  final String name;
  final int price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addItem(int productId, String name, int price) {
    final existingIndex = state.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final updatedList = [...state];
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: updatedList[existingIndex].quantity + 1,
      );
      state = updatedList;
    } else {
      state = [...state, CartItem(productId: productId, name: name, price: price)];
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item
    ];
  }

  void removeItem(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (total, item) => total + (item.price * item.quantity));
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (total, item) => total + item.quantity);
});
