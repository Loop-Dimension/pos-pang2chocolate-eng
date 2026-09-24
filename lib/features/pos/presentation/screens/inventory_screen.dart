import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/category_repository.dart';
import '../../data/product_repository.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<PosCategory> _categories = [];
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onCategoryChanged(List<PosCategory> newCategories) {
    if (_categories.length != newCategories.length) {
      _tabController?.dispose();
      _tabController = TabController(length: newCategories.length, vsync: this);
      _categories = newCategories;
    }
  }

  void _editStock(PosProduct product) {
    showDialog(
      context: context,
      builder: (context) => _StockEditDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('재고 관리', style: TextStyle(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('카테고리를 먼저 추가해주세요.'));
          }

          _onCategoryChanged(categories);

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: categories.map((c) => Tab(text: c.name)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: categories.map((cat) {
                    return _InventoryGridTab(
                      categoryId: cat.id,
                      onEditStock: _editStock,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryGridTab extends ConsumerWidget {
  final String categoryId;
  final Function(PosProduct) onEditStock;

  const _InventoryGridTab({
    required this.categoryId,
    required this.onEditStock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(categoryId));

    return productsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
      data: (products) {
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.5,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final stockText = product.stockCount == null ? '재고 무제한' : '${product.stockCount}';
            
            return GestureDetector(
              onTap: () => onEditStock(product),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      stockText,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
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
}

class _StockEditDialog extends ConsumerStatefulWidget {
  final PosProduct product;

  const _StockEditDialog({required this.product});

  @override
  ConsumerState<_StockEditDialog> createState() => _StockEditDialogState();
}

class _StockEditDialogState extends ConsumerState<_StockEditDialog> {
  late final TextEditingController _stockController;
  bool _isUnlimited = false;

  @override
  void initState() {
    super.initState();
    _isUnlimited = widget.product.stockCount == null;
    _stockController = TextEditingController(
      text: widget.product.stockCount != null ? '${widget.product.stockCount}' : '',
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _saveStock() async {
    final repo = ref.read(productRepositoryProvider);
    final newStockCount = _isUnlimited ? null : int.tryParse(_stockController.text.trim()) ?? 0;
    await repo.updateProductStock(widget.product.id, newStockCount);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 24.h),
      child: Container(
        width: 340.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Header: Title and Close (X) button
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.w, color: Colors.black54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),

            // Number input / display
            if (_isUnlimited)
              Container(
                height: 56.h,
                alignment: Alignment.center,
                child: Text(
                  '재고 무제한',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              )
            else
              Container(
                height: 56.h,
                alignment: Alignment.center,
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            SizedBox(height: 24.h),

            // "재고 설정 안함" Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isUnlimited = !_isUnlimited;
                  if (!_isUnlimited && _stockController.text.isEmpty) {
                    _stockController.text = '0';
                  }
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isUnlimited ? Colors.grey.shade300 : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8.r),
                  border: _isUnlimited ? Border.all(color: Colors.black87, width: 1.5) : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUnlimited) ...[
                      Icon(Icons.check, size: 16.sp, color: Colors.black87),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      '재고 설정 안함',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // "완료" Button
            GestureDetector(
              onTap: _saveStock,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
