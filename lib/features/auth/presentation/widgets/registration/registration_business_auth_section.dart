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
          suffix: RegistrationVerifyButton(text: '확인', onPressed: onVerifyBizReg),
        ),
        RegistrationInputBox(hint: '상호', controller: companyNameController),
        RegistrationInputBox(hint: '대표자명', controller: repNameController),
        RegistrationInputBox(hint: '사업장 주소', controller: addressController),
        RegistrationInputBox(
          hint: '휴대폰 번호',
          controller: phoneController,
          suffix: RegistrationVerifyButton(text: '본인인증', onPressed: onVerifyPhone),
        ),
        RegistrationInputBox(hint: '이메일', controller: emailController),
        RegistrationInputBox(hint: '비밀번호', controller: passwordController, obscureText: true),
      ],
    );
  }
}
