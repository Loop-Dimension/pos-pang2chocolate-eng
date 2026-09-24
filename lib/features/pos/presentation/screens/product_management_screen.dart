import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/category_repository.dart';
import '../../data/product_repository.dart';
import '../providers/inventory_provider.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<PosCategory> _categories = [];
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onCategoryChanged(List<PosCategory> newCategories) {
    if (_categories.length != newCategories.length) {
      _tabController?.dispose();
      _tabController = TabController(length: newCategories.length, vsync: this);
      _categories = newCategories;
    }
  }

  void _deleteProduct(PosProduct product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('"${product.name}" 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(productRepositoryProvider).deleteProduct(product.id);
    }
  }

  void _onReorder(String categoryId, int oldIndex, int newIndex, List<PosProduct> products) async {
    final repo = ref.read(productRepositoryProvider);
    
    // Convert to mutable list
    final list = List.from(products);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    
    for (int i = 0; i < list.length; i++) {
      if (list[i].gridIndex != i) {
        await repo.updateProductGridIndex(list[i].id, i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('상품 편집', style: TextStyle(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('카테고리를 먼저 추가해주세요.'));
          }

          _onCategoryChanged(categories);

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: categories.map((c) => Tab(text: c.name)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: categories.map((cat) {
                    return _ProductGridTab(
                      categoryId: cat.id,
                      onDelete: _deleteProduct,
                      onReorder: (oldIdx, newIdx, products) => _onReorder(cat.id, oldIdx, newIdx, products),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductGridTab extends ConsumerWidget {
  final String categoryId;
  final Function(PosProduct) onDelete;
  final Function(int, int, List<PosProduct>) onReorder;

  const _ProductGridTab({
    required this.categoryId,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(categoryId));

    return Column(
      children: [
        // Add Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(initialCategoryId: categoryId),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(16.w),
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 32.w),
          ),
        ),
        // Grid
        Expanded(
          child: productsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
            error: (err, stack) => Center(child: Text('에러 발생: $err')),
            data: (products) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 32.w - 24.w) / 4;
                  final itemHeight = itemWidth / 1.05;

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      // DragTarget to receive reordered items
                      return DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          onReorder(details.data, index, products);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered = candidateData.isNotEmpty;

                          return LongPressDraggable<int>(
                            data: index,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: Opacity(
                                  opacity: 0.85,
                                  child: _buildProductCard(context, product, true),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildProductCard(context, product, false),
                            ),
                            child: Container(
                              decoration: isHovered
                                  ? BoxDecoration(
                                      border: Border.all(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(8.r),
                                    )
                                  : null,
                              child: _buildProductCard(context, product, false),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, PosProduct product, bool isDragging) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(productId: product.id, initialCategoryId: categoryId),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              product.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (!isDragging)
          Positioned(
            right: -6.w,
            top: -6.h,
            child: GestureDetector(
              onTap: () => onDelete(product),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFBCBCBC),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.close,
                  size: 13.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
