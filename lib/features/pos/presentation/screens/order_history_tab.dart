import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../providers/order_provider.dart';

class OrderHistoryTab extends ConsumerStatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  ConsumerState<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends ConsumerState<OrderHistoryTab> {
  String? _expandedOrderId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRefundDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주문 환불'),
        content: const Text('이 주문을 환불 처리하시겠습니까?'),
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
    final historyAsync = ref.watch(historyOrdersStreamProvider);
    final completedCount = ref.watch(completedOrdersCountProvider);
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');
    final currencyFormatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: historyAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (historyOrders) {
          // Filter orders based on search query
          final filteredOrders = historyOrders.where((order) {
            if (_searchQuery.isEmpty) return true;
            final productString = order.items.map((item) => item.name).join(' ');
            return order.customerName.toLowerCase().contains(_searchQuery) ||
                   order.contact.contains(_searchQuery) ||
                   order.customerEmail.toLowerCase().contains(_searchQuery) ||
                   productString.toLowerCase().contains(_searchQuery);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
                child: Text(
                  '완료된 주문 : $completedCount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                final isExpanded = _expandedOrderId == order.id;
                final isCompleted = order.status == OrderStatus.completed;

                final productString = order.items.map((item) => '${item.name} * ${item.quantity}개').join(', ');

                return GestureDetector(
                  onTap: () {
                    if (isCompleted) {
                      setState(() {
                        _expandedOrderId = isExpanded ? null : order.id;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                      child: Column(
                        children: [
                          Text(
                            '결제일시:${dateFormatter.format(order.paymentTime)}',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '이름: ${order.customerName}',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '연락처: ${order.contact}',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '아이디: ${order.customerEmail}',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '제품: $productString',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '결제 금액: ${currencyFormatter.format(order.totalAmount)}원',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '상태: ${isCompleted ? '결제완료' : '환불완료'}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isCompleted ? Colors.black87 : Colors.red,
                              fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isExpanded && isCompleted) ...[
                            SizedBox(height: 16.h),
                            GestureDetector(
                              onTap: () => _showRefundDialog(order.id),
                              child: Container(
                                width: 100.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC4C4C4),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '환불',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
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
          
          // Bottom Search Bar
          Container(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 8.h),
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 24.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '주문내역 검색하기',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Icon(Icons.search, size: 28.w, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }),
    );
  }
}
