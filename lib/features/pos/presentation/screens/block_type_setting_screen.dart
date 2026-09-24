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
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId != null) {
      final data = await ref.read(merchantRepositoryProvider).getMerchantData(merchantId).first;
      if (mounted) {
        setState(() {
          _selectedColumns = data?['posGridColumns'] ?? 4;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await ref.read(merchantRepositoryProvider).updateMerchantData(merchantId, {'posGridColumns': _selectedColumns});
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      border: isSelected ? null : Border.all(color: Colors.black87, width: 1.5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(columns, (index) {
                final double blockHeight = columns == 1
                    ? 220.h
                    : (columns == 2 ? 110.h : (columns == 3 ? 75.h : 56.h));
                final double fontSize = columns == 1
                    ? 52.sp
                    : (columns == 2 ? 24.sp : (columns == 3 ? 18.sp : 16.sp));

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < columns - 1 ? 8.w : 0),
                    height: blockHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.black,
                        fontWeight: columns == 1 ? FontWeight.w500 : FontWeight.normal,
                      ),
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
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                _buildOption(4, '가로 4칸'),
                _buildOption(3, '가로 3칸'),
                _buildOption(2, '가로 2칸'),
                _buildOption(1, '가로 1칸'),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            onPressed: _saveData,
            child: Text(
              '완료',
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
