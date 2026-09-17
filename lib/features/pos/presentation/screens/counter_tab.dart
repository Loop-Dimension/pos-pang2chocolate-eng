import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/cart_provider.dart';
import '../widgets/checkout_cart_sheet.dart';

class CounterTab extends ConsumerStatefulWidget {
  const CounterTab({super.key});

  @override
  ConsumerState<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends ConsumerState<CounterTab> with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                tabs: const [
                  Tab(text: '식품'),
                  Tab(text: '생활'),
                  Tab(text: '카페'),
                ],
              ),
            ),
            
            // Grid Area
            Expanded(
              child: TabBarView(
                controller: _categoryTabController,
                children: [
                  _buildProductGrid(),
                  _buildProductGrid(),
                  _buildProductGrid(),
                ],
              ),
            ),
          ],
        ),

        // Floating Cart Button
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
  }

  Widget _buildProductGrid() {
    final cartItems = ref.watch(cartProvider);

    return GridView.builder(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1.0,
      ),
      itemCount: 36,
      itemBuilder: (context, index) {
        final id = index + 1;
        final cartItem = cartItems.where((item) => item.productId == id).firstOrNull;
        final isActive = cartItem != null;

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
                      '$id',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(cartProvider.notifier).updateQuantity(id, cartItem.quantity - 1),
                        child: Icon(Icons.remove, size: 16.w),
                      ),
                      Text('${cartItem.quantity}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => ref.read(cartProvider.notifier).updateQuantity(id, cartItem.quantity + 1),
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
            // Mock prices: 4000 for regular items, etc.
            int price = 4000;
            String name = '상품 $id';
            ref.read(cartProvider.notifier).addItem(id, name, price);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              '$id',
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

