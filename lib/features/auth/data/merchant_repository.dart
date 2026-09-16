import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepository(ref.watch(firebaseFirestoreProvider));
});

class MerchantRepository {
  final FirebaseFirestore _firestore;

  MerchantRepository(this._firestore);

  Stream<String?> getMerchantStatus(String uid) {
    return _firestore.collection('merchants').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['status'] as String?;
      }
      return null;
    });
  }

  Future<void> createPendingMerchant(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('merchants').doc(uid).set({
      ...data,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
