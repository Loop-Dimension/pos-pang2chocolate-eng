import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/data/merchant_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/registration/business_hours_builder.dart';

class StoreInfoScreen extends ConsumerStatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  ConsumerState<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends ConsumerState<StoreInfoScreen> {
  final _exclusionItemsController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  
  // Static business info controllers
  final _bizRegNumController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _repNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _accountController = TextEditingController();
  final _pangiAccountController = TextEditingController(text: '팽이');

  bool _isLoading = true;
  String _currentDiscountRate = "3% ~";
  bool _pangiAccountLinked = true;
  String? _profileImageUrl;
  Map<String, dynamic> _businessHours = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId != null) {
      final data = await ref.read(merchantRepositoryProvider).getMerchantData(merchantId).first;
      if (data != null && mounted) {
        setState(() {
          _exclusionItemsController.text = data['exclusionItems'] ?? '';
          _currentDiscountRate = data['discountRate'] ?? '3% ~';
          _pangiAccountLinked = data['pangiAccountLinked'] ?? true;
          _pangiAccountController.text = data['pangiAccountId'] ?? (_pangiAccountLinked ? '팽이' : '');
          _profileImageUrl = data['profileImageUrl'];
          _storeNameController.text = data['storeName'] ?? '';
          _storePhoneController.text = data['storePhone'] ?? '';
          _businessHours = Map<String, dynamic>.from(data['businessHours'] ?? {});

          // Read-only business info
          _bizRegNumController.text = data['businessRegistrationNumber'] ?? '';
          _companyNameController.text = data['companyName'] ?? '';
          _repNameController.text = data['representativeName'] ?? '';
          _addressController.text = data['businessAddress'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          
          _accountController.text = data['settlementAccount'] ?? '';
          
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateField(String field, dynamic value) async {
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId != null) {
      await ref.read(merchantRepositoryProvider).updateMerchantData(merchantId, {field: value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
      }
    }
  }

  void _changeDiscountRate() {
    int currentPercentage = 3;
    final parsed = _currentDiscountRate.replaceAll(RegExp(r'[^0-9]'), '');
    if (parsed.isNotEmpty) {
      currentPercentage = int.parse(parsed);
    }

    int selectedPercentage = currentPercentage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: Text(
                '제휴 할인율 변경',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '제휴 할인율은 기존 할인율($currentPercentage%) 이상으로만\n상향 조정 가능합니다.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrease button (disabled if <= currentPercentage)
                      IconButton(
                        onPressed: selectedPercentage > currentPercentage
                            ? () {
                                setModalState(() => selectedPercentage--);
                              }
                            : null,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          size: 32.sp,
                          color: selectedPercentage > currentPercentage ? Colors.black87 : Colors.grey.shade300,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$selectedPercentage%',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      // Increase button
                      IconButton(
                        onPressed: selectedPercentage < 30
                            ? () {
                                setModalState(() => selectedPercentage++);
                              }
                            : null,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 32.sp,
                          color: selectedPercentage < 30 ? Colors.black87 : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentDiscountRate = '$selectedPercentage%';
                    });
                    _updateField('discountRate', _currentDiscountRate);
                  },
                  child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _unlinkPangiAccount() async {
    setState(() {
      _pangiAccountLinked = false;
      _pangiAccountController.clear();
    });
    await _updateField('pangiAccountLinked', false);
    await _updateField('pangiAccountId', '');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팽이초콜릿 계정 연동이 해제되었습니다.')),
      );
    }
  }

  void _requestPangiLink() async {
    final accountId = _pangiAccountController.text.trim();
    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팽이초콜릿 계정 아이디를 입력해주세요.')),
      );
      return;
    }

    // Verify account format / simulation matching sign-up logic
    setState(() {
      _pangiAccountLinked = true;
    });
    await _updateField('pangiAccountLinked', true);
    await _updateField('pangiAccountId', accountId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팽이초콜릿 계정($accountId)과 연동되었습니다.')),
      );
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final merchantId = ref.read(activeMerchantIdProvider);
      if (merchantId != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final url = await ref.read(merchantRepositoryProvider).uploadProfileImage(image, merchantId);
          await ref.read(merchantRepositoryProvider).updateMerchantData(merchantId, {'profileImageUrl': url});
          if (mounted) {
            Navigator.pop(context); // Close dialog
            setState(() => _profileImageUrl = url);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 이미지가 변경되었습니다.')));
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
          }
        }
      }
    }
  }

  void _changeSettlementAccount() {
    final repName = _repNameController.text.trim();
    String selectedBank = 'KB국민은행';
    final accountNumController = TextEditingController();
    final holderController = TextEditingController(text: repName);
    bool isVerified = false;
    String? verificationMessage;

    final bankList = ['KB국민은행', '신한은행', '우리은행', '하나은행', 'NH농협은행', 'IBK기업은행', '카카오뱅크', '토스뱅크'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: Text(
                '정산계좌 변경',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '등록된 사업자 정보의 대표자명($repName)과 일치하는 계좌만 등록 가능합니다.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.4),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('은행 선택', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBank,
                      items: bankList.map((b) => DropdownMenuItem(value: b, child: Text(b, style: TextStyle(fontSize: 14.sp)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedBank = val;
                            isVerified = false;
                            verificationMessage = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text('계좌번호', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: accountNumController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setModalState(() {
                          isVerified = false;
                          verificationMessage = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '숫자만 입력',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text('예금주', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: holderController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isVerified ? Colors.green : Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          ),
                          onPressed: () {
                            final accNum = accountNumController.text.trim();
                            if (accNum.length < 7) {
                              setModalState(() {
                                isVerified = false;
                                verificationMessage = '올바른 계좌번호를 입력해주세요.';
                              });
                              return;
                            }
                            final holder = holderController.text.trim();
                            if (holder == repName && repName.isNotEmpty) {
                              setModalState(() {
                                isVerified = true;
                                verificationMessage = '✔ 대표자명과 예금주가 일치합니다.';
                              });
                            } else {
                              setModalState(() {
                                isVerified = false;
                                verificationMessage = '사업자 정보의 대표자명과 불일치합니다.';
                              });
                            }
                          },
                          child: Text(
                            isVerified ? '인증완료' : '실명확인',
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (verificationMessage != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        verificationMessage!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isVerified ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.black : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: isVerified
                      ? () {
                          final newAccountStr = '$selectedBank ${accountNumController.text.trim()} $repName';
                          Navigator.pop(context);
                          setState(() => _accountController.text = newAccountStr);
                          _updateField('settlementAccount', newAccountStr);
                        }
                      : null,
                  child: const Text('변경', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildStaticText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700, height: 1.5),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, String fieldKey, {bool readOnly = false, String? hint, Widget? suffix}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  style: TextStyle(color: readOnly ? Colors.grey.shade700 : Colors.black),
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: readOnly ? Colors.transparent : Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: readOnly ? Colors.transparent : Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...[
                SizedBox(width: 8.w),
                suffix,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlackButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F0F0),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '가게 정보',
          style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Static Text Blocks
            _buildSectionTitle('목표'),
            _buildStaticText('팽이초콜릿은 단기적 빠른 성장보다,\n회원제를 기반으로 꾸준한 재구매와 점진적 성장을 목표로 합니다.\n함께 단단히 성장할 수 있는 장기적 파트너십을 원합니다.'),
            SizedBox(height: 32.h),

            _buildSectionTitle('제휴 입점 안내'),
            _buildStaticText('(1)3km 반경내 동일 품목 입점 불가능합니다\n(2)기본가 대비 3% 이상 할인 가격 제공 시 입점 가능합니다\n(3)입점 후 우회·편법 운영이 확인될 경우 통보 없이 퇴점됩니다.'),
            SizedBox(height: 32.h),

            _buildSectionTitle('정산 및 환불 안내'),
            _buildStaticText('(1)정산일: 결제 후 D+1\n(2)환불\n- 정산전 환불: 정산 예정 금액에서 차감\n- 정산 후 환불: 다음 정산 예정 금액에서 차감\n*다음 정산 예정금액이 환불금액보다 적을 경우\n등록된 계좌에서 자동 출금, 실패시 그 다음 정산금으로 이월.'),
            SizedBox(height: 48.h),

            // 2. Editable Fields
            _buildEditableField('반경 3km 내 독점 품목', _exclusionItemsController, 'exclusionItems', readOnly: true),
            
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('제휴 할인율', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                          child: Text(_currentDiscountRate, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildBlackButton('수정', _changeDiscountRate),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '*우회·편법 운영이 확인될 경우 통보 없이 퇴점되며 블랙리스트로 등록되어 재입점은 불가능합니다.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 48.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('연동된 팽이초콜릿 계정', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _pangiAccountLinked
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                                child: Text(
                                  _pangiAccountController.text.isNotEmpty ? _pangiAccountController.text : '팽이',
                                  style: TextStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              )
                            : TextField(
                                controller: _pangiAccountController,
                                decoration: InputDecoration(
                                  hintText: '팽이초콜릿 아이디 입력',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 8.w),
                      _buildBlackButton(
                        _pangiAccountLinked ? '연동 해제' : '연동 요청',
                        _pangiAccountLinked ? _unlinkPangiAccount : _requestPangiLink,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Store Info for Lounge
            Center(child: _buildSectionTitle('가게 정보 등록 - 라운지 노출용')),
            SizedBox(height: 16.h),
            Center(
              child: GestureDetector(
                onTap: _updateProfileImage,
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    image: _profileImageUrl != null 
                        ? DecorationImage(image: NetworkImage(_profileImageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _profileImageUrl == null ? Icon(Icons.store, size: 48.w, color: Colors.grey.shade500) : null,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            _buildEditableField('가게 이름', _storeNameController, 'storeName', suffix: _buildBlackButton('수정', () => _updateField('storeName', _storeNameController.text))),
            _buildEditableField('가게 전화번호', _storePhoneController, 'storePhone', suffix: _buildBlackButton('수정', () => _updateField('storePhone', _storePhoneController.text))),
            
            // 4. Business Hours
            BusinessHoursBuilder(
              initialValue: _businessHours,
              onChanged: (hours) {
                _businessHours = hours;
              },
            ),
            SizedBox(height: 16.h),
            Center(child: _buildBlackButton('영업시간 저장', () => _updateField('businessHours', _businessHours))),
            SizedBox(height: 48.h),

            // 5. Read-only Business Information
            Center(child: _buildSectionTitle('사업자 정보')),
            SizedBox(height: 16.h),
            _buildEditableField('사업자등록번호', _bizRegNumController, '', readOnly: true),
            _buildEditableField('상호', _companyNameController, '', readOnly: true),
            _buildEditableField('대표자명', _repNameController, '', readOnly: true),
            _buildEditableField('사업장 주소', _addressController, '', readOnly: true),
            _buildEditableField('담당자 전화번호', _phoneController, '', readOnly: true),
            _buildEditableField('이메일', _emailController, '', readOnly: true),

            // 6. Settlement Account
            Center(child: _buildSectionTitle('정산계좌')),
            SizedBox(height: 16.h),
            _buildEditableField('계좌 정보', _accountController, 'settlementAccount', readOnly: true, suffix: _buildBlackButton('변경', _changeSettlementAccount)),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
