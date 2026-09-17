import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/data/merchant_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BlockTypeSettingScreen extends ConsumerStatefulWidget {
  const BlockTypeSettingScreen({super.key});

  @override
  ConsumerState<BlockTypeSettingScreen> createState() => _BlockTypeSettingScreenState();
}

class _BlockTypeSettingScreenState extends ConsumerState<BlockTypeSettingScreen> {
  int _selectedColumns = 4;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final data = await ref.read(merchantRepositoryProvider).getMerchantData(user.uid).first;
      if (mounted) {
        setState(() {
          _selectedColumns = data?['posGridColumns'] ?? 4;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await ref.read(merchantRepositoryProvider).updateMerchantData(user.uid, {'posGridColumns': _selectedColumns});
        if (mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('블록 타입이 저장되었습니다.')));
          Navigator.pop(context); // Go back
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
        }
      }
    }
  }

  Widget _buildOption(int columns, String title) {
    final isSelected = _selectedColumns == columns;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedColumns = columns),
      child: Container(
        color: Colors.transparent, // Ensure gesture detector captures the whole area
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  size: 24.w,
                ),
                SizedBox(width: 8.w), // Padding on the right
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(columns, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < columns - 1 ? 8.w : 0),
                    height: columns == 1 ? 250.h : (columns == 2 ? 120.h : (columns == 3 ? 90.h : 60.h)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: columns == 1 ? 48.sp : 18.sp, color: Colors.black),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          '블록 타입 설정',
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    children: [
                      _buildOption(4, '가로 4칸'),
                      _buildOption(3, '가로 3칸'),
                      _buildOption(2, '가로 2칸'),
                      _buildOption(1, '가로 1칸'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: _saveData,
                      child: Text(
                        '완료',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
