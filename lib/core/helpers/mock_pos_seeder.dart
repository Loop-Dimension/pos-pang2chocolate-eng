import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MockPosSeeder {
  static Future<void> seedMockDataIfEmpty(String merchantId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final catSnap = await firestore
          .collection('merchant_categories')
          .where('merchantId', isEqualTo: merchantId)
          .limit(1)
          .get();

      String cat1Id = '';
      String cat2Id = '';

      if (catSnap.docs.isEmpty) {
        // Create 2 sample categories
        final cat1Ref = firestore.collection('merchant_categories').doc();
        await cat1Ref.set({
          'merchantId': merchantId,
          'name': '커피',
          'orderIndex': 0,
          'showInSelfOrder': true,
        });
        cat1Id = cat1Ref.id;

        final cat2Ref = firestore.collection('merchant_categories').doc();
        await cat2Ref.set({
          'merchantId': merchantId,
          'name': '디저트',
          'orderIndex': 1,
          'showInSelfOrder': true,
        });
        cat2Id = cat2Ref.id;

        // Create sample products
        final prod1Ref = firestore.collection('merchant_products').doc();
        await prod1Ref.set({
          'merchantId': merchantId,
          'categoryId': cat1Id,
          'name': '아메리카노 (ICED)',
          'price': 4500,
          'description': '깊고 진한 풍미의 에스프레소 아메리카노',
          'memo': '',
          'stockCount': null,
          'showOnKitchenOrderForm': true,
          'showInSelfOrder': true,
          'imageUrls': [],
          'gridIndex': 1,
        });

        final prod2Ref = firestore.collection('merchant_products').doc();
        await prod2Ref.set({
          'merchantId': merchantId,
          'categoryId': cat1Id,
          'name': '카페라떼',
          'price': 5000,
          'description': '부드러운 스팀밀크와 에스프레소',
          'memo': '',
          'stockCount': null,
          'showOnKitchenOrderForm': true,
          'showInSelfOrder': true,
          'imageUrls': [],
          'gridIndex': 2,
        });

        final prod3Ref = firestore.collection('merchant_products').doc();
        await prod3Ref.set({
          'merchantId': merchantId,
          'categoryId': cat2Id,
          'name': '두바이초콜릿',
          'price': 8500,
          'description': '카다이프와 피스타치오 스프레드가 듬뿍 들어간 시그니처 초콜릿',
          'memo': '',
          'stockCount': 20,
          'showOnKitchenOrderForm': false,
          'showInSelfOrder': true,
          'imageUrls': [],
          'gridIndex': 1,
        });
      }

      // Check if orders exist
      final orderSnap = await firestore
          .collection('merchant_orders')
          .where('merchantId', isEqualTo: merchantId)
          .limit(1)
          .get();

      if (orderSnap.docs.isEmpty) {
        // 1. Pending Order with kitchen item (Appears in Order Form Tab)
        final order1Ref = firestore.collection('merchant_orders').doc();
        await order1Ref.set({
          'merchantId': merchantId,
          'paymentTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 3))),
          'customerName': '이영희',
          'contact': '010-9876-5432',
          'customerEmail': 'younghee@example.com',
          'totalAmount': 9500,
          'status': 'pending',
          'items': [
            {'name': '아메리카노 (ICED)', 'quantity': 1, 'isKitchen': true},
            {'name': '카페라떼', 'quantity': 1, 'isKitchen': true},
          ],
        });

        // 2. Completed Order without kitchen item (Appears in Order History Tab)
        final order2Ref = firestore.collection('merchant_orders').doc();
        await order2Ref.set({
          'merchantId': merchantId,
          'paymentTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
          'customerName': '김철수',
          'contact': '010-1234-5678',
          'customerEmail': 'chulsoo@example.com',
          'totalAmount': 8500,
          'status': 'completed',
          'items': [
            {'name': '두바이초콜릿', 'quantity': 1, 'isKitchen': false},
          ],
        });
      }
    } catch (e) {
      // Gracefully catch and log any permission or network error
      debugPrint('MockPosSeeder: seedMockDataIfEmpty error: $e');
    }
  }
}
