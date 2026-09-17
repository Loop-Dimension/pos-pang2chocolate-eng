import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/qr_scan_screen.dart';

class CheckoutCartSheet extends ConsumerWidget {
  const CheckoutCartSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(cartItemCountProvider);
    final totalAmount = ref.watch(cartTotalProvider);
    
    // Fetch merchant discount rate dynamically
    final merchantData = ref.watch(merchantDataProvider).value;
    double discountPercentage = 0.03; // Default 3% fallback
    if (merchantData != null && merchantData['discountRate'] != null) {
      final rateStr = merchantData['discountRate'] as String;
      // "3% ~", "4% ~", "10% ~" -> parse int
      final parsedStr = rateStr.replaceAll(RegExp(r'[^0-9]'), '');
      if (parsedStr.isNotEmpty) {
        discountPercentage = int.parse(parsedStr) / 100.0;
      }
    }
    
    final discountAmount = (totalAmount * discountPercentage).round();
    final finalMembershipAmount = totalAmount - discountAmount;
    final formatter = NumberFormat('#,###');

    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Almost full screen
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Header with back button
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h, bottom: 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, size: 28.w, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          // Cart Items List
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Text('장바구니가 비어 있습니다.', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(ref, item.productId, item.name, item.price, item.quantity);
                    },
                  ),
          ),
          
          // Bottom Payment Summary
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$totalItems',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('결제금액', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('일반회원', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                    Text('${formatter.format(totalAmount)}원', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('멤버십 회원 ', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text('${(discountPercentage * 100).toInt()}% 할인', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                        ),
                      ],
                    ),
                    Text('${formatter.format(finalMembershipAmount)}원', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: totalItems == 0
                        ? null
                        : () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const QrScanScreen()));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: totalItems == 0 ? Colors.grey.shade400 : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('결제하기', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(WidgetRef ref, int id, String name, int price, int quantity) {
    final formatter = NumberFormat('#,###');
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${formatter.format(price)}원', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(id, quantity - 1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              child: Icon(Icons.remove, size: 16.w),
                            ),
                          ),
                          Text('$quantity', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(id, quantity + 1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              child: Icon(Icons.add, size: 16.w),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
