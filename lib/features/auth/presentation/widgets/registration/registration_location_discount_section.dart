import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'registration_ui_helpers.dart';

class RegistrationLocationDiscountSection extends StatelessWidget {
  final TextEditingController storeLinkController;
  final TextEditingController exclusionItemsController;
  final String discountRate;
  final ValueChanged<String?> onDiscountChanged;

  const RegistrationLocationDiscountSection({
    super.key,
    required this.storeLinkController,
    required this.exclusionItemsController,
    required this.discountRate,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RegistrationSectionTitle(title: '좋은 매장 인증'),
        RegistrationInputBox(
          hint: '예) 네이버 지도 or 플랫폼 링크...',
          controller: storeLinkController,
        ),
        const RegistrationSectionTitle(title: '반경 3km 내 독점하고 싶은 품목'),
        RegistrationInputBox(
          hint: '예) 주유소, 호텔, 펜션, 음식점, 카페...',
          controller: exclusionItemsController,
        ),
        const RegistrationSectionTitle(title: '제공 가능 할인율'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: discountRate,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              items: ['3% ~', '4% ~', '5% ~', '10% ~']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: onDiscountChanged,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '*우회·편법 운영이 확인될 경우 통보 없이 퇴점되며 블랙리스트로 등록되어 재입점은 불가능합니다.',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
