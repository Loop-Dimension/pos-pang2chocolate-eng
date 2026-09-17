import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationInfoSection extends StatelessWidget {
  const RegistrationInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '목표',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '팽이초콜릿은 단기적 빠른 성장보다,\n회원제를 기반으로 꾸준한 재구매와 점진적 성장을 목표로 합니다.\n함께 단단히 성장할 수 있는 장기적 파트너십을 원합니다.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          '제휴 입점 안내',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '(1) 3km 반경내 동일 품목 입점 불가능합니다\n(2) 기본가 대비 3% 이상 할인 가격 제공 시 입점 가능합니다\n(3) 입점 후 우회·편법 운영이 확인될 경우 통보 없이 퇴점됩니다.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          '정산 및 환불 안내',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '(1) 정산일: 결제 후 D+1\n(2) 환불\n- 정산전 환불: 정산 예정 금액에서 차감\n- 정산 후 환불: 다음 정산 예정 금액에서 차감\n*다음 정산 예정금액이 환불금액보다 적을 경우\n등록된 계좌에서 자동 출금, 실패시 그 다음 정산금으로 이월.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
