import 'package:flutter/material.dart';
import 'registration_ui_helpers.dart';

class RegistrationBusinessAuthSection extends StatelessWidget {
  final TextEditingController bizRegNumController;
  final TextEditingController companyNameController;
  final TextEditingController repNameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onVerifyBizReg;
  final VoidCallback onVerifyPhone;
  final bool showPasswordField;
  final bool isBizRegVerified;
  final bool isPhoneVerified;

  const RegistrationBusinessAuthSection({
    super.key,
    required this.bizRegNumController,
    required this.companyNameController,
    required this.repNameController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.onVerifyBizReg,
    required this.onVerifyPhone,
    this.showPasswordField = true,
    this.isBizRegVerified = false,
    this.isPhoneVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RegistrationSectionTitle(title: '사업자 인증'),
        RegistrationInputBox(
          hint: '사업자등록번호',
          controller: bizRegNumController,
          suffix: RegistrationVerifyButton(
            text: '확인',
            isVerified: isBizRegVerified,
            onPressed: onVerifyBizReg,
          ),
          validator: (val) => val == null || val.isEmpty ? '필수 입력 항목입니다.' : null,
        ),
        RegistrationInputBox(
          hint: '상호',
          controller: companyNameController,
          validator: (val) => val == null || val.isEmpty ? '필수 입력 항목입니다.' : null,
        ),
        RegistrationInputBox(
          hint: '대표자명',
          controller: repNameController,
          validator: (val) => val == null || val.isEmpty ? '필수 입력 항목입니다.' : null,
        ),
        RegistrationInputBox(
          hint: '사업장 주소',
          controller: addressController,
          validator: (val) => val == null || val.isEmpty ? '필수 입력 항목입니다.' : null,
        ),
        RegistrationInputBox(
          hint: '휴대폰 번호',
          controller: phoneController,
          suffix: RegistrationVerifyButton(
            text: '본인인증',
            isVerified: isPhoneVerified,
            onPressed: onVerifyPhone,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) return '필수 입력 항목입니다.';
            return null;
          },
        ),
        RegistrationInputBox(
          hint: '이메일',
          controller: emailController,
          validator: (val) {
            if (val == null || val.isEmpty) return '이메일을 입력해 주세요.';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
              return '올바른 이메일 형식을 입력해 주세요.';
            }
            return null;
          },
        ),
        if (showPasswordField)
          RegistrationInputBox(
            hint: '비밀번호',
            controller: passwordController,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return '비밀번호를 입력해 주세요.';
              if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(val)) {
                return '영문, 숫자 포함 8자리 이상 입력해 주세요.';
              }
              return null;
            },
          ),
      ],
    );
  }
}
