import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/category_repository.dart';
import '../../data/product_repository.dart';

final categoriesStreamProvider = StreamProvider<List<PosCategory>>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null) return Stream.value([]);
  
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.streamCategories(merchantId);
});

final productsStreamProvider = StreamProvider.family<List<PosProduct>, String>((ref, categoryId) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  if (merchantId == null || categoryId.isEmpty) return Stream.value([]);
  
  final repo = ref.watch(productRepositoryProvider);
  return repo.streamProducts(merchantId, categoryId);
});
