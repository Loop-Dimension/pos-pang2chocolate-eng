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
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');
    final currencyFormatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: historyAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (historyOrders) {
          final totalCount = historyOrders.length;

          // Filter orders based on search query
          final filteredOrders = historyOrders.where((order) {
            if (_searchQuery.isEmpty) return true;
            final productString = order.items.map((item) => item.name).join(' ');
            final dateString = dateFormatter.format(order.paymentTime);
            return order.customerName.toLowerCase().contains(_searchQuery) ||
                   order.contact.contains(_searchQuery) ||
                   order.customerEmail.toLowerCase().contains(_searchQuery) ||
                   order.id.toLowerCase().contains(_searchQuery) ||
                   dateString.contains(_searchQuery) ||
                   productString.toLowerCase().contains(_searchQuery);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 14.h, bottom: 10.h),
                child: Text(
                  '완료된 주문 : $totalCount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF8E8E93),
                    fontWeight: FontWeight.normal,
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
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final isExpanded = _expandedOrderId == order.id;
                          final isCompleted = order.status == OrderStatus.completed;

                          final productString = order.items
                              .map((item) => '${item.name} * ${item.quantity}개')
                              .join(', ');

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
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                                child: Column(
                                  children: [
                                    Text(
                                      '결제일시:${dateFormatter.format(order.paymentTime)}',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '이름: ${order.customerName}',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '연락처: ${order.contact}',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '아이디: ${order.customerEmail}',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '제품: $productString',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '결제 금액: ${currencyFormatter.format(order.totalAmount)}원',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '상태: ${isCompleted ? '결제완료' : '환불완료'}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (isExpanded && isCompleted) ...[
                                      SizedBox(height: 14.h),
                                      GestureDetector(
                                        onTap: () => _showRefundDialog(order.id),
                                        child: Container(
                                          width: 90.w,
                                          height: 38.h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC4C4C4),
                                            borderRadius: BorderRadius.circular(19.r),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '환불',
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

              // Bottom Search Bar matching mockup
              Container(
                padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: 20.h, top: 6.h),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: const Color(0xFFCCCCCC), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 18.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontSize: 15.sp, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '주문내역 검색하기',
                            hintStyle: TextStyle(
                              fontSize: 15.sp,
                              color: const Color(0xFF9E9E9E),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Icon(Icons.search, size: 24.w, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
