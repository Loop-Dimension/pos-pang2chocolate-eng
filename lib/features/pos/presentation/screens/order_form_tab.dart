import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/order_provider.dart';

class OrderFormTab extends ConsumerStatefulWidget {
  const OrderFormTab({super.key});

  @override
  ConsumerState<OrderFormTab> createState() => _OrderFormTabState();
}

class _OrderFormTabState extends ConsumerState<OrderFormTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _expandedOrderId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }



  void _showCancelDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주문 취소'),
        content: const Text('이 주문을 취소하고 환불 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(orderRepositoryProvider).updateOrderStatus(orderId, OrderStatus.refunded);
              Navigator.pop(context);
              setState(() {
                if (_expandedOrderId == orderId) _expandedOrderId = null;
              });
            },
            child: const Text('예', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrdersAsync = ref.watch(pendingOrdersStreamProvider);
    final pendingCount = ref.watch(pendingOrdersCountProvider);
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: pendingOrdersAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (error, stack) => Center(child: Text('에러 발생: $error')),
        data: (orders) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
                child: Text(
                  '미완료 주문 : $pendingCount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? Center(child: Text('들어온 주문이 없습니다.', style: TextStyle(fontSize: 16.sp, color: Colors.grey)))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isExpanded = _expandedOrderId == order.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedOrderId = isExpanded ? null : order.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Products List
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: order.items.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8.h),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${item.quantity}잔',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Complete Button
                              GestureDetector(
                                onTap: () {
                                  ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.completed);
                                },
                                child: Container(
                                  width: 60.w,
                                  // Make it tall enough to match the product list height generally
                                  height: 80.h, 
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '완료',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Expanded Area
                          if (isExpanded) ...[
                            SizedBox(height: 16.h),
                            const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                            SizedBox(height: 16.h),
                            Text(
                              '결제일시:${dateFormatter.format(order.paymentTime)}',
                              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '연락처: ${order.contact}',
                              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            ),
                            SizedBox(height: 24.h),
                            GestureDetector(
                              onTap: () => _showCancelDialog(order.id),
                              child: Container(
                                width: 120.w,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(22.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '주문 취소',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }),
    );
  }
}
