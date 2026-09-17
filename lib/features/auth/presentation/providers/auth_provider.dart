import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';

enum AuthStatus {
  unauthenticated,
  pendingApproval,
  approved,
}

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final merchantStatusProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(merchantRepositoryProvider).getMerchantStatus(user.uid);
});

final merchantDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(merchantRepositoryProvider).getMerchantData(user.uid);
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  final user = ref.watch(authStateProvider).value;
  final merchantStatus = ref.watch(merchantStatusProvider).value;

  if (user == null) {
    return AuthStatus.unauthenticated;
  }

  if (merchantStatus == 'approved') {
    return AuthStatus.approved;
  }

  return AuthStatus.pendingApproval;
});
