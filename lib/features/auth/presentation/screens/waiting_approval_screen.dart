import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/auth_repository.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 64.w, color: Colors.grey.shade600),
                SizedBox(height: 24.h),
                Text(
                  '제휴 신청이 완료되었습니다.',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  '관리자 승인 후 팽이 POS를\n이용하실 수 있습니다.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

