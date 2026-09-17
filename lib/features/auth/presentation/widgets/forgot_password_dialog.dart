import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/auth_repository.dart';
import '../../../../core/widgets/custom_text_field.dart';

Future<void> showForgotPasswordDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return const ForgotPasswordDialog();
    },
  );
}

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final resetEmailController = TextEditingController();
  String dialogError = '';
  bool _isLoading = false;

  @override
  void dispose() {
    resetEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      title: Text(
        '비밀번호 찾기',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '가입하신 이메일을 입력해주세요. 비밀번호 재설정 링크를 보내드립니다.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            labelText: '이메일',
            controller: resetEmailController,
            hintText: '이메일',
          ),
          if (dialogError.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              dialogError,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (!_isLoading) {
              Navigator.pop(context);
            }
          },
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final email = resetEmailController.text.trim();
                  if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                    setState(() {
                      dialogError = '올바른 이메일 형식을 입력해 주세요.';
                    });
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                    dialogError = '';
                  });

                  try {
                    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호 재설정 이메일이 전송되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      dialogError = e.toString().replaceAll('Exception: ', '');
                    });
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          child: _isLoading
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text(
                  '전송',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
