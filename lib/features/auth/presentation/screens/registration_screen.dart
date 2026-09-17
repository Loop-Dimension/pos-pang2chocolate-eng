import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/registration/business_hours_builder.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  // Store Info & Discount
  final _storeLinkController = TextEditingController();
  final _exclusionItemsController = TextEditingController();
  String _discountRate = '3% ~';

  // Business Auth
  final _bizRegNumController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _repNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Settlement Account
  final _accountController = TextEditingController();

  // Lounge Info
  XFile? _profileImage;
  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  Map<String, dynamic>? _businessHours;
  final _howDidYouHearController = TextEditingController();

  // Terms & Password
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await ref.read(merchantRepositoryProvider).createPendingMerchant(
          user.uid,
          {
            'storeLink': _storeLinkController.text.trim(),
            'exclusionItems': _exclusionItemsController.text.trim(),
            'discountRate': _discountRate,
            'businessRegistrationNumber': _bizRegNumController.text.trim(),
            'companyName': _companyNameController.text.trim(),
            'representativeName': _repNameController.text.trim(),
            'businessAddress': _addressController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'settlementAccount': _accountController.text.trim(),
            'storeName': _storeNameController.text.trim(),
            'storePhone': _storePhoneController.text.trim(),
            'businessHours': _businessHours,
            'howDidYouHear': _howDidYouHearController.text.trim(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 32.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInputBox({
    required String hint,
    required TextEditingController controller,
    Widget? suffix,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  Widget _buildVerifyButton(String text) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '팽이 POS 회원가입',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Goals
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

              // Guide 1
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

              // Guide 2
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
              SizedBox(height: 32.h),

              _buildSectionTitle('좋은 매장 인증'),
              _buildInputBox(
                hint: '예) 네이버 지도 or 플랫폼 링크...',
                controller: _storeLinkController,
              ),

              _buildSectionTitle('반경 3km 내 독점하고 싶은 품목'),
              _buildInputBox(
                hint: '예) 주유소, 호텔, 펜션, 음식점, 카페...',
                controller: _exclusionItemsController,
              ),

              _buildSectionTitle('제공 가능 할인율'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _discountRate,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    items: ['3% ~', '4% ~', '5% ~', '10% ~']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _discountRate = v!),
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

              _buildSectionTitle('사업자 인증'),
              _buildInputBox(
                hint: '사업자등록번호',
                controller: _bizRegNumController,
                suffix: _buildVerifyButton('확인'),
              ),
              _buildInputBox(hint: '상호', controller: _companyNameController),
              _buildInputBox(hint: '대표자명', controller: _repNameController),
              _buildInputBox(hint: '사업장 주소', controller: _addressController),
              _buildInputBox(
                hint: '휴대폰 번호',
                controller: _phoneController,
                suffix: _buildVerifyButton('본인인증'),
              ),
              _buildInputBox(hint: '이메일', controller: _emailController),

              _buildSectionTitle('정산계좌'),
              _buildInputBox(
                hint: '',
                controller: _accountController,
                suffix: _buildVerifyButton('확인'),
              ),

              SizedBox(height: 24.h),
              // Checkboxes
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    activeColor: Colors.black,
                  ),
                  Text(
                    '위 계약 내용에 동의합니다.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    activeColor: Colors.black,
                  ),
                  Text(
                    '팽이 포스 이용약관 및 개인정보수집에 동의합니다.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ],
              ),

              _buildSectionTitle('가게 정보 등록 - 라운지 노출용'),
              ProfileImagePicker(
                selectedImage: _profileImage,
                onImagePicked: (img) => setState(() => _profileImage = img),
              ),
              SizedBox(height: 16.h),
              _buildInputBox(hint: '가게 이름', controller: _storeNameController),
              _buildInputBox(
                hint: '가게 전화번호',
                controller: _storePhoneController,
              ),

              SizedBox(height: 24.h),
              BusinessHoursBuilder(
                onChanged: (hours) => _businessHours = hours,
              ),

              _buildSectionTitle('어떻게 알고 오셨나요?'),
              _buildInputBox(hint: '', controller: _howDidYouHearController),

              SizedBox(height: 32.h),
              InkWell(
                onTap: _isLoading ? null : _handleRegister,
                child: Container(
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '제휴 신청하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storeLinkController.dispose();
    _exclusionItemsController.dispose();
    _bizRegNumController.dispose();
    _companyNameController.dispose();
    _repNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _accountController.dispose();
    _storeNameController.dispose();
    _storePhoneController.dispose();
    _howDidYouHearController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
