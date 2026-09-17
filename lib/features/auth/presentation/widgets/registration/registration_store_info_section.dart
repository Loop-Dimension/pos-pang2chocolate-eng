import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_image_picker.dart';
import 'business_hours_builder.dart';
import 'registration_ui_helpers.dart';

class RegistrationStoreInfoSection extends StatelessWidget {
  final XFile? profileImage;
  final ValueChanged<XFile?> onImagePicked;
  final TextEditingController storeNameController;
  final TextEditingController storePhoneController;
  final TextEditingController howDidYouHearController;
  final ValueChanged<Map<String, dynamic>> onBusinessHoursChanged;

  const RegistrationStoreInfoSection({
    super.key,
    required this.profileImage,
    required this.onImagePicked,
    required this.storeNameController,
    required this.storePhoneController,
    required this.howDidYouHearController,
    required this.onBusinessHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RegistrationSectionTitle(title: '가게 정보 등록 - 라운지 노출용'),
        ProfileImagePicker(
          selectedImage: profileImage,
          onImagePicked: onImagePicked,
        ),
        SizedBox(height: 16.h),
        RegistrationInputBox(hint: '가게 이름', controller: storeNameController),
        RegistrationInputBox(hint: '가게 전화번호', controller: storePhoneController),
        SizedBox(height: 24.h),
        BusinessHoursBuilder(onChanged: onBusinessHoursChanged),
        const RegistrationSectionTitle(title: '어떻게 알고 오셨나요?'),
        RegistrationInputBox(hint: '', controller: howDidYouHearController),
      ],
    );
  }
}
