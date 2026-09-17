import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';

import '../widgets/registration/registration_ui_helpers.dart';
import '../widgets/registration/registration_info_section.dart';
import '../widgets/registration/registration_location_discount_section.dart';
import '../widgets/registration/registration_business_auth_section.dart';
import '../widgets/registration/registration_store_info_section.dart';
import '../widgets/registration/registration_terms_section.dart';

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
  bool _agreedToContract = false;
  bool _agreedToPrivacy = false;

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_agreedToContract || !_agreedToPrivacy) {
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

              const RegistrationInfoSection(),

              RegistrationLocationDiscountSection(
                storeLinkController: _storeLinkController,
                exclusionItemsController: _exclusionItemsController,
                discountRate: _discountRate,
                onDiscountChanged: (v) => setState(() => _discountRate = v!),
              ),

              RegistrationBusinessAuthSection(
                bizRegNumController: _bizRegNumController,
                companyNameController: _companyNameController,
                repNameController: _repNameController,
                addressController: _addressController,
                phoneController: _phoneController,
                emailController: _emailController,
                onVerifyBizReg: () {},
                onVerifyPhone: () {},
              ),

              const RegistrationSectionTitle(title: '정산계좌'),
              RegistrationInputBox(
                hint: '',
                controller: _accountController,
                suffix: RegistrationVerifyButton(text: '확인', onPressed: () {}),
              ),

              SizedBox(height: 24.h),
              RegistrationTermsSection(
                agreedToContract: _agreedToContract,
                agreedToPrivacy: _agreedToPrivacy,
                onContractChanged: (val) => setState(() => _agreedToContract = val),
                onPrivacyChanged: (val) => setState(() => _agreedToPrivacy = val),
              ),
              SizedBox(height: 32.h),

              RegistrationStoreInfoSection(
                profileImage: _profileImage,
                onImagePicked: (img) => setState(() => _profileImage = img),
                storeNameController: _storeNameController,
                storePhoneController: _storePhoneController,
                howDidYouHearController: _howDidYouHearController,
                onBusinessHoursChanged: (hours) => _businessHours = hours,
              ),

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
