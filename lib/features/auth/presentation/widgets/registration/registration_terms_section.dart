import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationTermsSection extends StatelessWidget {
  final bool agreedToContract;
  final bool agreedToPrivacy;
  final ValueChanged<bool> onContractChanged;
  final ValueChanged<bool> onPrivacyChanged;

  const RegistrationTermsSection({
    super.key,
    required this.agreedToContract,
    required this.agreedToPrivacy,
    required this.onContractChanged,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: agreedToContract,
                onChanged: (v) => onContractChanged(v ?? false),
                activeColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: Colors.black54, width: 1.5),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '위 계약 내용에 동의합니다.',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: agreedToPrivacy,
                onChanged: (v) => onPrivacyChanged(v ?? false),
                activeColor: Colors.black,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: Colors.black54, width: 1.5),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '팽이 포스 이용약관 및 개인정보수집에 동의합니다.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(
                        'https://magnetic-sole-873.notion.site/397afcb4acdd8099ad05dccac36185c2?pvs=74',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      '전문 보기',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
