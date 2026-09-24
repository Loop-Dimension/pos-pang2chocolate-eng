import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

import '../providers/order_provider.dart';

class OrderFormTab extends ConsumerStatefulWidget {
  const OrderFormTab({super.key});

  @override
  ConsumerState<OrderFormTab> createState() => _OrderFormTabState();
}

class _OrderFormTabState extends ConsumerState<OrderFormTab> {
  String? _expandedOrderId;

  Future<void> _triggerNewOrderAlert() async {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 500);
      }
    } catch (_) {}
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
    // Listen for new orders to play sound and trigger vibration
    ref.listen<AsyncValue<List<PosOrder>>>(pendingOrdersStreamProvider, (previous, next) {
      if (previous?.value != null && next.value != null) {
        if (next.value!.length > previous!.value!.length) {
          _triggerNewOrderAlert();
        }
      }
    });

    final pendingOrdersAsync = ref.watch(pendingOrdersStreamProvider);
    final pendingCount = ref.watch(pendingOrdersCountProvider);
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: pendingOrdersAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (error, stack) => Center(child: Text('에러 발생: $error')),
        data: (orders) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 14.h, bottom: 10.h),
                child: Text(
                  '미완료 주문 : $pendingCount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF8E8E93),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          '들어온 주문이 없습니다.',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isExpanded = _expandedOrderId == order.id;
                          final kitchenItems = order.items.where((item) => item.isKitchen).toList();

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedOrderId = isExpanded ? null : order.id;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(bottom: 10.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Products List
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: kitchenItems.map((item) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: item == kitchenItems.last ? 0 : 10.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.name,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
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
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          // Complete Button
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(orderRepositoryProvider).updateOrderStatus(
                                                    order.id,
                                                    OrderStatus.completed,
                                                  );
                                            },
                                            child: Container(
                                              width: 68.w,
                                              constraints: BoxConstraints(minHeight: 52.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFC4C4C4),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '완료',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Expanded Details Area
                                    if (isExpanded) ...[
                                      SizedBox(height: 20.h),
                                      Text(
                                        '결제일시:${dateFormatter.format(order.paymentTime)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '연락처: ${order.contact}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      GestureDetector(
                                        onTap: () => _showCancelDialog(order.id),
                                        child: Container(
                                          width: 110.w,
                                          height: 38.h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC4C4C4),
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '주문 취소',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
        },
      ),
    );
  }
}
