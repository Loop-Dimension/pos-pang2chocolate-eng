import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/category_repository.dart';
import '../providers/inventory_provider.dart';

class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({super.key});

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  void _addCategory() async {
    final merchantId = ref.read(activeMerchantIdProvider);
    if (merchantId == null) return;

    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('카테고리 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '카테고리명 입력'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('추가', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );

    if (newName != null) {
      final currentCategories = ref.read(categoriesStreamProvider).value ?? [];
      final maxOrderIndex = currentCategories.isEmpty
          ? 0
          : currentCategories
                .map((e) => e.orderIndex)
                .reduce((a, b) => a > b ? a : b);

      final newCat = PosCategory(
        id: '',
        merchantId: merchantId,
        name: newName,
        orderIndex: maxOrderIndex + 1,
        showInSelfOrder: false,
      );

      await ref.read(categoryRepositoryProvider).createCategory(newCat);
    }
  }

  void _deleteCategory(PosCategory category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"${category.name}" 카테고리를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
    }
  }

  void _toggleSelfOrder(PosCategory category, bool? value) async {
    if (value == null) return;
    final updatedCat = category.copyWith(showInSelfOrder: value);
    await ref.read(categoryRepositoryProvider).updateCategory(updatedCat);
  }

  void _onReorder(
    int oldIndex,
    int newIndex,
    List<PosCategory> currentCategories,
  ) {
    // Create a mutable copy of the list
    final List<PosCategory> updatedList = List.from(currentCategories);

    // Remove the item from oldIndex
    final PosCategory item = updatedList.removeAt(oldIndex);

    // Insert the item at newIndex (already adjusted by onReorderItem)
    updatedList.insert(newIndex, item);

    // Update orderIndex for all items
    final List<PosCategory> newlyOrdered = updatedList.asMap().entries.map((
      entry,
    ) {
      return entry.value.copyWith(orderIndex: entry.key);
    }).toList();

    // Batch update in Firestore
    ref.read(categoryRepositoryProvider).updateCategoriesOrder(newlyOrdered);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          '카테고리 편집',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (categories) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, top: 12.h, bottom: 8.h),
                child: Text(
                  '셀프주문\n노출',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: categories.length,
                  onReorderItem: (oldIndex, newIndex) {
                    _onReorder(oldIndex, newIndex, categories);
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(color: Colors.transparent, child: child);
                  },
                  footer: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    child: Row(
                      children: [
                        SizedBox(width: 48.w), // Offset checkbox width
                        GestureDetector(
                          onTap: _addCategory,
                          child: Container(
                            constraints: BoxConstraints(minWidth: 100.w),
                            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBCBCBC),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 32.sp,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(category.id),
                      index: index,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: category.showInSelfOrder,
                              onChanged: (val) => _toggleSelfOrder(category, val),
                              activeColor: Colors.black,
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.black87, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 100.w),
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBCBCBC),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -8.w,
                                  top: -8.h,
                                  child: GestureDetector(
                                    onTap: () => _deleteCategory(category),
                                    child: Container(
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFBCBCBC),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.close,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
