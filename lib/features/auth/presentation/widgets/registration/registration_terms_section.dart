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

  void _showTermsPopup(BuildContext context) {
    bool tempAgreedContract = agreedToTerms;
    bool tempAgreedPrivacy = agreedToTerms;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              title: Text(
                '약관 동의',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '서비스 이용을 위해 아래 약관 및 계약 내용에 동의해 주세요.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('https://magnetic-sole-873.notion.site/397afcb4acdd8099ad05dccac36185c2?pvs=74');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '이용약관 및 개인정보 처리방침 보기',
                              style: TextStyle(fontSize: 12.sp, color: Colors.black87, decoration: TextDecoration.underline),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: tempAgreedContract,
                        onChanged: (v) => setPopupState(() => tempAgreedContract = v ?? false),
                        activeColor: Colors.black,
                      ),
                      Expanded(
                        child: Text('위 계약 내용에 동의합니다.', style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: tempAgreedPrivacy,
                        onChanged: (v) => setPopupState(() => tempAgreedPrivacy = v ?? false),
                        activeColor: Colors.black,
                      ),
                      Expanded(
                        child: Text('팽이 포스 이용약관 및 개인정보수집에 동의합니다.', style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (tempAgreedContract && tempAgreedPrivacy) {
                      onChanged(true);
                      Navigator.pop(context);
                    } else {
                      onChanged(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('모든 약관에 동의해야 합니다.')),
                      );
                    }
                  },
                  child: Text('확인 및 동의', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!agreedToTerms)
          InkWell(
            onTap: () => _showTermsPopup(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Text(
                  '약관 확인 및 동의하기',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '모든 약관에 동의했습니다.',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _showTermsPopup(context),
                  child: Text('다시 보기', style: TextStyle(fontSize: 12.sp, decoration: TextDecoration.underline)),
                )
              ],
            ),
          ),
      ],
    );
  }
}
