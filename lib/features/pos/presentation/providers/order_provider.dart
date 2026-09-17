import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderItem {
  final String name;
  final int quantity;
  final bool isKitchen;

  OrderItem({required this.name, required this.quantity, this.isKitchen = true});
}

class PosOrder {
  final String id;
  final List<OrderItem> items;
  final DateTime paymentTime;
  final String contact;

  PosOrder({required this.id, required this.items, required this.paymentTime, required this.contact});
}

class OrderNotifier extends Notifier<List<PosOrder>> {
  @override
  List<PosOrder> build() {
    return _mockOrders();
  }

  List<PosOrder> _mockOrders() {
    return [
      PosOrder(
        id: '1',
        items: [
          OrderItem(name: '에어로스팅 아메리카노 HOT', quantity: 4),
          OrderItem(name: '아이스티', quantity: 1),
          OrderItem(name: '딥 말차 라떼', quantity: 3),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 31),
        contact: '01027526381',
      ),
      PosOrder(
        id: '2',
        items: [
          OrderItem(name: '에어로스팅 아메리카노 ICE', quantity: 3),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 35),
        contact: '01011112222',
      ),
      PosOrder(
        id: '3',
        items: [
          OrderItem(name: '에어 크림 아메리카노 ICE', quantity: 3),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 40),
        contact: '01033334444',
      ),
      PosOrder(
        id: '4',
        items: [
          OrderItem(name: '에어로스팅 아메리카노 HOT', quantity: 4),
          OrderItem(name: '아이스티', quantity: 1),
          OrderItem(name: '딥 말차 라떼', quantity: 3),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 45),
        contact: '01055556666',
      ),
      PosOrder(
        id: '5',
        items: [
          OrderItem(name: '딥 다크 초콜릿 쉐이크', quantity: 1),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 50),
        contact: '01077778888',
      ),
      PosOrder(
        id: '6',
        items: [
          OrderItem(name: '아메리카노 HOT', quantity: 2),
        ],
        paymentTime: DateTime(2026, 3, 16, 9, 55),
        contact: '01099990000',
      ),
    ];
  }

  void completeOrder(String id) {
    state = state.where((order) => order.id != id).toList();
    // In the future: Add to order history
  }

  void cancelOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<PosOrder>>(() {
  return OrderNotifier();
});

final pendingOrdersCountProvider = Provider<int>((ref) {
  return ref.watch(orderProvider).length;
});
