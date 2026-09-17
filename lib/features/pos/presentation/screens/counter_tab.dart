import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/category_repository.dart';
import '../providers/cart_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/checkout_cart_sheet.dart';

class CounterTab extends ConsumerStatefulWidget {
  const CounterTab({super.key});

  @override
  ConsumerState<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends ConsumerState<CounterTab> with SingleTickerProviderStateMixin {
  TabController? _categoryTabController;
  List<PosCategory> _categories = [];

  @override
  void dispose() {
    _categoryTabController?.dispose();
    super.dispose();
  }

  void _onCategoryChanged(List<PosCategory> newCategories) {
    if (_categories.length != newCategories.length) {
      _categoryTabController?.dispose();
      _categoryTabController = TabController(length: newCategories.length, vsync: this);
      _categories = newCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('상품 관리에서 카테고리와 상품을 추가해주세요.'));
        }

        _onCategoryChanged(categories);

        return Stack(
          children: [
            Column(
              children: [
                // Category Tabs
                Container(
                  color: const Color(0xFFF0F0F0),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: TabBar(
                    controller: _categoryTabController,
                    indicatorColor: Colors.black,
                    indicatorWeight: 3.h,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
                    tabs: categories.map((c) => Tab(text: c.name)).toList(),
                  ),
                ),
                
                // Grid Area
                Expanded(
                  child: TabBarView(
                    controller: _categoryTabController,
                    children: categories.map((cat) {
                      return _ProductGridTab(categoryId: cat.id);
                    }).toList(),
                  ),
                ),
              ],
            ),

        // Floating Cart Button logic below ...
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 24.h,
          child: Consumer(builder: (context, ref, child) {
            final cartItemCount = ref.watch(cartItemCountProvider);
            if (cartItemCount == 0) return const SizedBox.shrink(); // Hide if empty
            
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CheckoutCartSheet(),
                );
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartItemCount',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '장바구니',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
      },
    );
  }
}

class _ProductGridTab extends ConsumerWidget {
  final String categoryId;

  const _ProductGridTab({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final productsAsync = ref.watch(productsStreamProvider(categoryId));

    return productsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
      data: (products) {
        return GridView.builder(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.0,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final cartItem = cartItems.where((item) => item.productId == product.id).firstOrNull;
            final isActive = cartItem != null;
            final isOutOfStock = product.stockCount == 0;

            if (isOutOfStock && !isActive) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${product.name}\n(품절)',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (isActive) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          product.name,
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(product.id, cartItem.quantity - 1),
                            child: Icon(Icons.remove, size: 16.w),
                          ),
                          Text('${cartItem.quantity}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              if (product.stockCount != null && cartItem.quantity >= product.stockCount!) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('재고가 부족합니다.')));
                                return;
                              }
                              ref.read(cartProvider.notifier).updateQuantity(product.id, cartItem.quantity + 1);
                            },
                            child: Icon(Icons.add, size: 16.w),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                ref.read(cartProvider.notifier).addItem(
                  product.id, 
                  product.name, 
                  product.price, 
                  showOnKitchenOrderForm: product.showOnKitchenOrderForm
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Text(
                  product.name,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

