import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/terms_and_conditions_checkbox.dart';
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
  String _discountRate = '3%';

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
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('POS Partnership Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Guidelines Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8.r)),
              child: Text(
                'Partnership Guidelines:\n1. 3km radius exclusive items.\n2. Minimum 3% discount rate required.\n3. Settlement happens D+1.',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
            
            _buildSectionTitle('Location & Discount'),
            CustomTextField(labelText: 'Store Link (Naver Map)', controller: _storeLinkController),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Exclusive Items within 3km (Gas, Hotel, etc.)', controller: _exclusionItemsController),
            SizedBox(height: 12.h),
            Text('Discount Rate', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _discountRate,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              items: ['3%', '4%', '5%', '10%'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _discountRate = v!),
            ),

            _buildSectionTitle('Business Authentication'),
            CustomTextField(
              labelText: 'Business Registration Number',
              controller: _bizRegNumController,
              suffixIcon: TextButton(onPressed: () {}, child: const Text('Verify', style: TextStyle(color: Colors.black))),
            ),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Company Name', controller: _companyNameController),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Representative Name', controller: _repNameController),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Business Address', controller: _addressController),
            SizedBox(height: 12.h),
            CustomTextField(
              labelText: 'Mobile Phone Number',
              controller: _phoneController,
              suffixIcon: TextButton(onPressed: () {}, child: const Text('Verify', style: TextStyle(color: Colors.black))),
            ),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Email', controller: _emailController),

            _buildSectionTitle('Settlement Account'),
            CustomTextField(
              labelText: 'Account Number',
              controller: _accountController,
              suffixIcon: TextButton(onPressed: () {}, child: const Text('Verify', style: TextStyle(color: Colors.black))),
            ),

            _buildSectionTitle('Lounge Store Information'),
            ProfileImagePicker(
              selectedImage: _profileImage,
              onImagePicked: (img) => setState(() => _profileImage = img),
            ),
            SizedBox(height: 16.h),
            CustomTextField(labelText: 'Store Name', controller: _storeNameController),
            SizedBox(height: 12.h),
            CustomTextField(labelText: 'Store Phone Number', controller: _storePhoneController),
            SizedBox(height: 16.h),
            BusinessHoursBuilder(onChanged: (hours) => _businessHours = hours),
            SizedBox(height: 16.h),
            CustomTextField(labelText: 'How did you hear about us?', controller: _howDidYouHearController),

            _buildSectionTitle('Account Password & Terms'),
            CustomTextField(
              labelText: 'Password',
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 16.h),
            TermsAndConditionsCheckbox(
              agreedToTerms: _agreedToTerms,
              agreedToPrivacy: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v),
            ),
            
            SizedBox(height: 32.h),
            PrimaryButton(
              text: 'Submit Partnership Request',
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ),
            SizedBox(height: 40.h),
          ],
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
