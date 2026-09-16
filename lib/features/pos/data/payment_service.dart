import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentServiceProvider = Provider<IPaymentService>((ref) {
  return MockPaymentService();
});

abstract class IPaymentService {
  Future<bool> processPayment(double amount, String paymentMethod);
}

class MockPaymentService implements IPaymentService {
  @override
  Future<bool> processPayment(double amount, String paymentMethod) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate successful payment
    return true;
  }
}
