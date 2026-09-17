import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final bool showOnKitchenOrderForm;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.showOnKitchenOrderForm = true,
  });

  CartItem copyWith({int? quantity, bool? showOnKitchenOrderForm}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      showOnKitchenOrderForm: showOnKitchenOrderForm ?? this.showOnKitchenOrderForm,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addItem(String productId, String name, int price, {bool showOnKitchenOrderForm = true}) {
    final existingIndex = state.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final updatedList = [...state];
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: updatedList[existingIndex].quantity + 1,
      );
      state = updatedList;
    } else {
      state = [...state, CartItem(productId: productId, name: name, price: price, showOnKitchenOrderForm: showOnKitchenOrderForm)];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item
    ];
  }

  void removeItem(String productId) {
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
