import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/category_repository.dart';
import '../providers/cart_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/checkout_cart_sheet.dart';
import 'inventory_screen.dart';
import 'category_edit_screen.dart';
import 'product_management_screen.dart';
import 'store_info_screen.dart';
import 'block_type_setting_screen.dart';

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

  Widget _buildSettingsGear() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'inventory':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
            break;
          case 'categories':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryEditScreen()));
            break;
          case 'products':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
            break;
          case 'store_info':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreInfoScreen()));
            break;
          case 'block_type_setting':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockTypeSettingScreen()));
            break;
        }
      },
      offset: Offset(0, 44.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'inventory',
          child: Text('재고 관리', style: TextStyle(fontSize: 15.sp)),
        ),
        PopupMenuItem(
          value: 'categories',
          child: Text('카테고리 편집', style: TextStyle(fontSize: 15.sp)),
        ),
        PopupMenuItem(
          value: 'products',
          child: Text('상품 편집', style: TextStyle(fontSize: 15.sp)),
        ),
        PopupMenuItem(
          value: 'store_info',
          child: Text('가게 정보', style: TextStyle(fontSize: 15.sp)),
        ),
        PopupMenuItem(
          value: 'block_type_setting',
          child: Text('블록타입 설정', style: TextStyle(fontSize: 15.sp)),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Icon(
          Icons.settings_outlined,
          color: Colors.black87,
          size: 22.sp,
        ),
      ),
    );
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
          return Column(
            children: [
              Container(
                color: const Color(0xFFF0F0F0),
                padding: EdgeInsets.only(left: 16.w, right: 12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('카운터', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    _buildSettingsGear(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48.sp, color: Colors.grey),
                      SizedBox(height: 12.h),
                      Text(
                        '등록된 카테고리와 상품이 없습니다.',
                        style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoryEditScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('카테고리 추가하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        _onCategoryChanged(categories);

        return Stack(
          children: [
            Column(
              children: [
                // Category Tabs with Settings Gear Icon on far right
                Container(
                  color: const Color(0xFFF0F0F0),
                  padding: EdgeInsets.only(left: 16.w, right: 12.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _categoryTabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: Colors.black,
                          indicatorWeight: 3.h,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey.shade500,
                          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          unselectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
                          tabs: categories.map((c) => Tab(text: c.name)).toList(),
                        ),
                      ),
                      _buildSettingsGear(),
                    ],
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

        // Bottom Cart Button matching mockup
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Consumer(builder: (context, ref, child) {
            final cartItemCount = ref.watch(cartItemCountProvider);
            if (cartItemCount == 0) return const SizedBox.shrink(); // Hide if empty
            
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const CheckoutCartSheet(),
                    );
                  },
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$cartItemCount',
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '장바구니',
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
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
    final merchantData = ref.watch(merchantDataProvider).value;
    final int gridColumns = merchantData?['posGridColumns'] ?? 4;

    return productsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
      data: (products) {
        return GridView.builder(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
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
                  showOnKitchenOrderForm: product.showOnKitchenOrderForm,
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
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

