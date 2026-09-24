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

  void _showContractDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          '제휴 계약 내용',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1. 제휴 입점 안내\n'
                  '- 3km 반경 내 동일 품목 입점이 제한될 수 있습니다.\n'
                  '- 기본가 대비 3% 이상의 할인 가격을 제공하는 매장에 한해 입점이 승인됩니다.\n'
                  '- 입점 후 우회·편법 운영이 확인될 경우 사전 통보 없이 퇴점 조치 및 재입점이 불가합니다.\n\n'
                  '2. 정산 및 환불 안내\n'
                  '- 정산 주기: 결제일 기준 D+1일에 정산 계좌로 입금됩니다.\n'
                  '- 정산 전 환불: 당일 정산 예정 금액에서 차감됩니다.\n'
                  '- 정산 후 환불: 익일 정산 예정 금액에서 차감되며, 잔액 부족 시 등록된 계좌에서 자동 출금 처리됩니다.\n\n'
                  '3. 가맹점 준수사항\n'
                  '- 회원의 팽이페이 결제 및 멤버십 혜택을 성실히 이행해야 합니다.',
                  style: TextStyle(fontSize: 13.sp, height: 1.6, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onContractChanged(true);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('동의하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          '이용약관 및 개인정보수집 동의',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1. 수집하는 개인정보 항목\n'
                  '- 필수항목: 대표자명, 상호명, 사업자등록번호, 휴대폰번호, 이메일, 정산계좌번호, 사업장 주소\n\n'
                  '2. 수집 및 이용 목적\n'
                  '- 팽이 POS 가맹점 입점 심사 및 제휴 계약 체결\n'
                  '- 주문 대금 정산, 결제 내역 확인 및 세금계산서 발행\n'
                  '- 고객 분쟁 해결 및 공지사항 전달\n\n'
                  '3. 보유 및 이용 기간\n'
                  '- 가맹점 해지 시까지 (단, 전자상거래법 등 관계 법령에 따라 최대 5년간 보관)',
                  style: TextStyle(fontSize: 13.sp, height: 1.6, color: Colors.black87),
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(
                      'https://magnetic-sole-873.notion.site/397afcb4acdd8099ad05dccac36185c2?pvs=74',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 16.w, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Text(
                        '공식 노션 약관 전문 보기',
                        style: TextStyle(fontSize: 12.sp, color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onPrivacyChanged(true);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('동의하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
                side: const BorderSide(color: Colors.black54, width: 1.5),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '위 계약 내용에 동의합니다.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => _showContractDialog(context),
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
                side: const BorderSide(color: Colors.black54, width: 1.5),
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
                    onTap: () => _showPrivacyDialog(context),
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
