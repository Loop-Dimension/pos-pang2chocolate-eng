import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';

enum AuthStatus {
  unauthenticated,
  authenticatedNoMerchant,
  pendingApproval,
  approved,
}

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final sellerClaimProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  return await ref.watch(authRepositoryProvider).isSeller();
});

/// Toggle to bypass authentication for testing.
/// Set to true so you can freely test POS dashboard, registration, etc., without logging in.
const bool kBypassAuthForTesting = true;
const String kMockMerchantId = 'dCHIH0HBN4X8EtJCwYZFqBAWF9E3';

final activeMerchantIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) return user.uid;
  if (kBypassAuthForTesting) return kMockMerchantId;
  return null;
});

final merchantStatusProvider = StreamProvider<String?>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null) {
    return Stream.value(null);
  }
  return ref.watch(merchantRepositoryProvider).getMerchantStatus(merchantId);
});

final merchantDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null) {
    return Stream.value(null);
  }
  return ref.watch(merchantRepositoryProvider).getMerchantData(merchantId);
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  if (kBypassAuthForTesting) {
    return AuthStatus.approved;
  }

  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return AuthStatus.unauthenticated;
  }

  final isSellerClaim = ref.watch(sellerClaimProvider).value ?? false;
  final merchantStatusAsync = ref.watch(merchantStatusProvider);
  final merchantStatus = merchantStatusAsync.value;

  if (isSellerClaim || merchantStatus == 'approved') {
    return AuthStatus.approved;
  }

  if (merchantStatus == 'pending') {
    return AuthStatus.pendingApproval;
  }

  // If still loading and hasn't emitted yet, keep pending until document is verified
  if (merchantStatusAsync.isLoading && !merchantStatusAsync.hasValue) {
    return AuthStatus.pendingApproval;
  }

  return AuthStatus.authenticatedNoMerchant;
});
