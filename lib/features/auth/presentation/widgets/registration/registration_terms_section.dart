import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationTermsSection extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool> onChanged;

  const RegistrationTermsSection({
    super.key,
    required this.agreedToTerms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: agreedToTerms,
              onChanged: (v) => onChanged(v ?? false),
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
              value: agreedToTerms,
              onChanged: (v) => onChanged(v ?? false),
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
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.inAppWebView);
                }
              },
              child: Text(
                '전문 보기',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
