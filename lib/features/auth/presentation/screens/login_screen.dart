import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../data/auth_repository.dart';
import '../widgets/forgot_password_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial deep link if app opened via URL
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {}

    // Listen to incoming deep links while running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) {},
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'pangi-pos' && uri.host == 'login-callback') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        setState(() => _isLoading = true);
        try {
          await ref.read(authRepositoryProvider).signInWithCustomToken(token);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _onPangiLoginPressed() {
    _showPangiLoginModal();
  }

  void _showPangiLoginModal() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool modalLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo.png', width: 28.w, height: 28.w),
                        SizedBox(width: 8.w),
                        Text(
                          '팽이초콜릿 통합 로그인',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Pang2 ID(이메일)로 로그인해주세요',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      labelText: '이메일',
                      controller: emailController,
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
                      controller: passwordController,
                      isPassword: true,
                      hintText: '비밀번호를 입력해 주세요',
                      validator: (val) {
                        if (val == null || val.isEmpty) return '비밀번호를 입력해 주세요.';
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: modalLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => modalLoading = true);
                                try {
                                  await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
                                        emailController.text.trim(),
                                        passwordController.text,
                                      );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (ctx.mounted) setModalState(() => modalLoading = false);
                                }
                              },
                        child: modalLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                '로그인',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            showForgotPasswordDialog(context);
                          },
                          child: Text(
                            '비밀번호 찾기',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                          ),
                        ),
                        Text('  |  ', style: TextStyle(color: Colors.grey.shade400)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/register');
                          },
                          child: Text(
                            '제휴 신청하기',
                            style: TextStyle(color: Colors.black87, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Title matching client mockup (로그인.jpg)
            Positioned(
              top: 36.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '팽이 POS',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Center Content matching client mockup (로그인.jpg)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GestureDetector(
                  onTap: _isLoading ? null : _onPangiLoginPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/pangi_login_btn_cropped.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      if (_isLoading)
                        Positioned(
                          top: 22.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom subtle link to Sign-Up / Partnership Application
            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(
                    '아직 제휴 가맹점이 아니신가요? 제휴 신청하기',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
