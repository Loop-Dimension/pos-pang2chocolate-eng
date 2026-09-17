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
  final _stockController = TextEditingController();
  bool _isUnlimited = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.stockCount == null) {
      _isUnlimited = true;
    } else {
      _stockController.text = widget.product.stockCount.toString();
    }
  }

  void _saveStock() async {
    final repo = ref.read(productRepositoryProvider);
    final newStockCount = _isUnlimited ? null : int.tryParse(_stockController.text.trim());
    await repo.updateProductStock(widget.product.id, newStockCount);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('재고 관리'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            enabled: !_isUnlimited,
            decoration: InputDecoration(
              hintText: '재고 수량 입력',
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isUnlimited = !_isUnlimited;
                      if (_isUnlimited) _stockController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _isUnlimited ? Colors.black : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: Text('설정 안함', style: TextStyle(color: _isUnlimited ? Colors.white : Colors.black87, fontSize: 12.sp)),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(
          onPressed: _saveStock,
          child: const Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
