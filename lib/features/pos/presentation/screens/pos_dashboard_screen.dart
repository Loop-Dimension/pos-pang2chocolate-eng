import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'counter_tab.dart';
import 'order_form_tab.dart';
import 'order_history_tab.dart';
import 'settings_tab.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey.shade500,
                        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: '카운터'),
                          Tab(text: '주문서'),
                          Tab(text: '주문내역'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Settings Icon Tab
                  GestureDetector(
                    onTap: () {
                      _tabController.animateTo(3);
                    },
                    child: Container(
                      width: 44.h,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: _tabController.index == 3 ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: _tabController.index == 3
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: _tabController.index == 3 ? Colors.black87 : Colors.grey.shade500,
                        size: 24.w,
                      ),
                    ),
                  ),
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
                  SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

