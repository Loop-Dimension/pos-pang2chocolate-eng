import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'counter_tab.dart';
import 'order_form_tab.dart';
import 'order_history_tab.dart';

class PosDashboardScreen extends StatefulWidget {
  const PosDashboardScreen({super.key});

  @override
  State<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends State<PosDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Standard light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Tab Bar Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey.shade500,
                      labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(text: '카운터'),
                        Tab(text: '주문서'),
                        Tab(text: '주문내역'),
                      ],
                    ),
                  ),
                  if (kBypassAuthForTesting) ...[
                    SizedBox(width: 8.w),
                    IconButton(
                      tooltip: '회원가입 / 제휴신청 테스트',
                      icon: const Icon(Icons.assignment_ind_outlined, color: Colors.black54),
                      onPressed: () => context.push('/register'),
                    ),
                  ],
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe to change tabs
                children: const [
                  CounterTab(),
                  OrderFormTab(),
                  OrderHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

