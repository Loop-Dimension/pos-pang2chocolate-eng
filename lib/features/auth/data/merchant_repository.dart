import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helpers/image_upload_helper.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

class MerchantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MerchantRepository(this._firestore, this._storage);

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

  Future<String> uploadProfileImage(XFile image, String uid) async {
    final originalBytes = await image.readAsBytes();
    final preparedData = await ImageUploadHelper.prepareImageForUpload(
      rawBytes: originalBytes,
      originalName: image.name,
      minWidth: 400,
      minHeight: 400,
      quality: 80,
    );

    final storageRef = _storage.ref().child('merchant_profiles').child('$uid${preparedData.extension}');
    final uploadTask = await storageRef.putData(
      preparedData.bytes,
      SettableMetadata(contentType: preparedData.contentType),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}
