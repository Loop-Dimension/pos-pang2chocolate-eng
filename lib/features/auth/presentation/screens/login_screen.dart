import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/auth_repository.dart';
import '../widgets/forgot_password_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // Router will automatically redirect based on AuthStatus changes
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo placeholder or text
              Text(
                '팽이 POS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 64.h),
              
              // Email / Password Form (Assuming direct login for now)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        labelText: '이메일',
                        controller: _emailController,
                        hintText: '이메일을 입력해 주세요',
                        validator: (val) {
                          if (val == null || val.isEmpty) return '이메일을 입력해 주세요.';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return '올바른 이메일 형식을 입력해 주세요.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        labelText: '비밀번호',
                        controller: _passwordController,
                        isPassword: true,
                        hintText: '비밀번호를 입력해 주세요',
                        validator: (val) {
                          if (val == null || val.isEmpty) return '비밀번호를 입력해 주세요.';
                          return null; // Login usually just checks empty
                        },
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        text: '로그인',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: TextButton(
                          onPressed: () => showForgotPasswordDialog(context),
                          child: Text(
                            '비밀번호 찾기',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(
                  '아직 회원이 아니신가요? 제휴 신청하기',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
