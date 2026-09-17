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
          children: [
            Checkbox(
              value: agreedToContract,
              onChanged: (v) => onContractChanged(v ?? false),
              activeColor: Colors.black,
            ),
            Expanded(
              child: Text(
                '위 계약 내용에 동의합니다.',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: agreedToPrivacy,
              onChanged: (v) => onPrivacyChanged(v ?? false),
              activeColor: Colors.black,
            ),
            Expanded(
              child: Text(
                '팽이 포스 이용약관 및 개인정보수집에 동의합니다.',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(
                  'https://magnetic-sole-873.notion.site/397afcb4acdd8099ad05dccac36185c2?pvs=74',
                );
                // Directly launch without checking canLaunchUrl to avoid Android 11+ queries issue
                await launchUrl(url);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  '전문 보기',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
