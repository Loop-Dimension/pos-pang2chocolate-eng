import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/providers/order_provider.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  
  OrderRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // We are using 'merchant_orders' globally for POS orders.
  CollectionReference<Map<String, dynamic>> get _orders => _firestore.collection('merchant_orders');

  /// Creates a new order directly to Firestore
  Future<void> createOrder(String merchantId, PosOrder order) async {
    final docRef = _orders.doc();
    await docRef.set({
      'merchantId': merchantId,
      'paymentTime': order.paymentTime,
      'customerName': order.customerName,
      'contact': order.contact,
      'customerEmail': order.customerEmail,
      'totalAmount': order.totalAmount,
      'status': _statusToString(order.status),
      'items': order.items.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'isKitchen': item.isKitchen,
      }).toList(),
    });
  }

  /// Updates order status (e.g., pending -> completed, or completed -> refunded)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _orders.doc(orderId).update({
      'status': _statusToString(newStatus),
    });
  }

  /// Streams pending orders (Order Form Tab)
  Stream<List<PosOrder>> streamPendingOrders(String merchantId) {
    return _orders
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map(_docToOrder).toList();
          return orders
              .where((o) => o.status == OrderStatus.pending)
              .toList()
              ..sort((a, b) => a.paymentTime.compareTo(b.paymentTime));
        });
  }

  /// Streams history orders (Order History Tab)
  Stream<List<PosOrder>> streamHistoryOrders(String merchantId) {
    return _orders
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map(_docToOrder).toList();
          return orders
              .where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.refunded)
              .toList()
              ..sort((a, b) => b.paymentTime.compareTo(a.paymentTime));
        });
  }

  PosOrder _docToOrder(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final itemsList = (data['items'] as List<dynamic>?) ?? [];
    
    return PosOrder(
      id: doc.id,
      paymentTime: (data['paymentTime'] as Timestamp).toDate(),
      customerName: data['customerName'] ?? '비회원',
      contact: data['contact'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      totalAmount: data['totalAmount'] ?? 0,
      status: _stringToStatus(data['status'] as String?),
      items: itemsList.map((item) {
        final itemMap = item as Map<String, dynamic>;
        return OrderItem(
          name: itemMap['name'] ?? '',
          quantity: itemMap['quantity'] ?? 1,
          isKitchen: itemMap['isKitchen'] ?? true,
        );
      }).toList(),
    );
  }

  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.completed: return 'completed';
      case OrderStatus.refunded: return 'refunded';
    }
  }

  OrderStatus _stringToStatus(String? str) {
    switch (str) {
      case 'pending': return OrderStatus.pending;
      case 'completed': return OrderStatus.completed;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }
}
