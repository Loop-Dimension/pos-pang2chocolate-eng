import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/order_repository.dart';

class OrderItem {
  final String name;
  final int quantity;
  final bool isKitchen;

  OrderItem({required this.name, required this.quantity, this.isKitchen = true});
}

enum OrderStatus {
  pending,
  completed,
  refunded,
}

class PosOrder {
  final String id;
  final List<OrderItem> items;
  final DateTime paymentTime;
  final String customerName;
  final String contact;
  final String customerEmail;
  final int totalAmount;
  final OrderStatus status;

  PosOrder({
    required this.id,
    required this.items,
    required this.paymentTime,
    this.customerName = '비회원',
    required this.contact,
    this.customerEmail = '',
    required this.totalAmount,
    this.status = OrderStatus.completed,
  });
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final pendingOrdersStreamProvider = StreamProvider<List<PosOrder>>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null) return Stream.value([]);
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.streamPendingOrders(merchantId);
});

final historyOrdersStreamProvider = StreamProvider<List<PosOrder>>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null) return Stream.value([]);
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.streamHistoryOrders(merchantId);
});

final pendingOrdersCountProvider = Provider<int>((ref) {
  final asyncOrders = ref.watch(pendingOrdersStreamProvider);
  return asyncOrders.value?.length ?? 0;
});

final completedOrdersCountProvider = Provider<int>((ref) {
  final asyncOrders = ref.watch(historyOrdersStreamProvider);
  return asyncOrders.value?.where((o) => o.status == OrderStatus.completed).length ?? 0;
});
