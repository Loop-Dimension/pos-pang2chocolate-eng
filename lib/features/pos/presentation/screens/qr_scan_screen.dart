import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class QrScanScreen extends ConsumerWidget {
  final bool isMembership;
  final int finalPrice;

  const QrScanScreen({
    super.key,
    this.isMembership = true,
    required this.finalPrice,
  });

  void _simulateSuccessfulPayment(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final cartItems = ref.read(cartProvider);
    final hasKitchenItem = cartItems.any((item) => item.showOnKitchenOrderForm);

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
      customerEmail: user.email ?? 'no-email@test.com',
      totalAmount: finalPrice,
      status: hasKitchenItem ? OrderStatus.pending : OrderStatus.completed,
    );

    try {
      // Fire and forget Firestore save to guarantee instant UI update
      ref.read(orderRepositoryProvider).createOrder(user.uid, newOrder);

      // Clear cart and go back to counter
      ref.read(cartProvider.notifier).clearCart();
      // Pop back to the POS dashboard
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결제가 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                '멤버십 QR코드를 인식해주세요',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 32.h),
              
              // Viewfinder frame
              Container(
                width: 250.w,
                height: 250.w,
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
                        width: 200.w,
                        color: Colors.greenAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h),
              
              // Temporary Mock Payment Button since API isn't ready
              ElevatedButton(
                onPressed: () => _simulateSuccessfulPayment(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
                child: Text(
                  '(임시) 스캔 완료 시뮬레이션',
                  style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
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
