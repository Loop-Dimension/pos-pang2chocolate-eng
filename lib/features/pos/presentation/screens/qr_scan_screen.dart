import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  final int generalPrice;
  final int membershipPrice;
  final double discountPercentage;

  const QrScanScreen({
    super.key,
    required this.generalPrice,
    required this.membershipPrice,
    this.discountPercentage = 0.03,
  });

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  bool _isMembershipSelected = true;

  void _executePayment({required bool isMembership}) async {
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가맹점 정보가 없습니다.')),
      );
      return;
    }

    final cartItems = ref.read(cartProvider);
    final hasKitchenItem = cartItems.any((item) => item.showOnKitchenOrderForm);
    final chargeAmount = isMembership ? widget.membershipPrice : widget.generalPrice;
    final formatter = NumberFormat('#,###');

    // Construct the PosOrder
    final newOrder = PosOrder(
      id: '', // Firestore will generate this
      items: cartItems.map((ci) => OrderItem(
        name: ci.name,
        quantity: ci.quantity,
        isKitchen: ci.showOnKitchenOrderForm,
      )).toList(),
      paymentTime: DateTime.now(),
      contact: '01012345678', // Mock phone for now
      customerName: isMembership ? '멤버십 회원' : '일반 회원',
      customerEmail: 'test@pangi.com',
      totalAmount: chargeAmount,
      status: hasKitchenItem ? OrderStatus.pending : OrderStatus.completed,
    );

    try {
      // Fire and forget Firestore save to guarantee instant UI update
      ref.read(orderRepositoryProvider).createOrder(merchantId, newOrder);

      // Clear cart and go back to counter
      ref.read(cartProvider.notifier).clearCart();
      // Pop back to the POS dashboard
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isMembership ? "멤버십 회원" : "일반 회원"} 결제 완료: ${formatter.format(chargeAmount)}원',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final discountPercentInt = (widget.discountPercentage * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Color (simulating camera)
          Container(
            color: const Color(0xFF1E1E1E),
          ),

          // Viewfinder Cutout Simulation
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '회원 QR코드를 인식해주세요',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),

              // Active price summary banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isMembershipSelected
                          ? '멤버십 회원 ($discountPercentInt% 할인): '
                          : '일반 회원가: ',
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 13.sp),
                    ),
                    Text(
                      _isMembershipSelected
                          ? '${formatter.format(widget.membershipPrice)}원'
                          : '${formatter.format(widget.generalPrice)}원',
                      style: TextStyle(
                        color: _isMembershipSelected ? Colors.greenAccent : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Viewfinder frame
              Container(
                width: 240.w,
                height: 240.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    // Corner markers
                    Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true)),
                    Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false)),
                    Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true)),
                    Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false)),

                    // Scanning line animation placeholder
                    Center(
                      child: Container(
                        height: 2.h,
                        width: 190.w,
                        color: Colors.greenAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 36.h),

              // Simulation trigger buttons for both Member Rates
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isMembershipSelected = true);
                        _executePayment(isMembership: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      ),
                      child: Text(
                        '멤버십 회원 결제 (${formatter.format(widget.membershipPrice)}원)',
                        style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _isMembershipSelected = false);
                        _executePayment(isMembership: false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        minimumSize: Size(double.infinity, 44.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      ),
                      child: Text(
                        '일반회원 결제 (${formatter.format(widget.generalPrice)}원)',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: Colors.white, width: 4.w) : BorderSide.none,
          bottom: !top ? BorderSide(color: Colors.white, width: 4.w) : BorderSide.none,
          left: left ? BorderSide(color: Colors.white, width: 4.w) : BorderSide.none,
          right: !left ? BorderSide(color: Colors.white, width: 4.w) : BorderSide.none,
        ),
      ),
    );
  }
}
