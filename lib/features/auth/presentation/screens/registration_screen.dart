import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/auth_repository.dart';
import '../../data/merchant_repository.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bizRegNumController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _repNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create User in Firebase Auth
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
          
      // 2. Get UID
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // 3. Save Merchant Data to Firestore with status 'pending'
        await ref.read(merchantRepositoryProvider).createPendingMerchant(
          user.uid,
          {
            'email': _emailController.text.trim(),
            'businessRegistrationNumber': _bizRegNumController.text.trim(),
            'companyName': _companyNameController.text.trim(),
            'representativeName': _repNameController.text.trim(),
            'address': _addressController.text.trim(),
            'phone': _phoneController.text.trim(),
            'settlementAccount': _accountController.text.trim(),
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
      appBar: AppBar(
        title: const Text('POS Partnership Registration'),
      ),
      body: Center(
        child: Container(
          width: 600.w, // Wider for tablet form
          margin: EdgeInsets.symmetric(vertical: 24.h),
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Information',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Business Registration Number',
                  controller: _bizRegNumController,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Company Name',
                  controller: _companyNameController,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Representative Name',
                  controller: _repNameController,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Business Address',
                  controller: _addressController,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Mobile Phone Number',
                  controller: _phoneController,
                ),
                SizedBox(height: 32.h),
                Text(
                  'Account Information',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Settlement Account',
                  controller: _accountController,
                ),
                SizedBox(height: 32.h),
                Text(
                  'Login Credentials',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Email',
                  controller: _emailController,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  labelText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 32.h),
                PrimaryButton(
                  text: 'Submit Partnership Request',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bizRegNumController.dispose();
    _companyNameController.dispose();
    _repNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    super.dispose();
  }
}
