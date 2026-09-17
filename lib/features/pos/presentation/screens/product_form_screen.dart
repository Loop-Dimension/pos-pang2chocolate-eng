import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/product_repository.dart';
import '../providers/inventory_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? initialCategoryId;

  const ProductFormScreen({super.key, this.productId, this.initialCategoryId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  String? _selectedCategoryId;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _memoController = TextEditingController();

  bool _isUnlimitedStock = false;
  bool _showOnKitchen = true;
  bool _showInSelfOrder = true;

  List<String> _existingImages = [];
  String? _draftProductId;
  bool _isUploadingImage = false;
  
  PosProduct? _editingProduct;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadProductData();
  }

  void _loadProductData() async {
    if (widget.productId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    // In a real app, we'd fetch the specific product from Firestore or a local provider list
    // For now, we will simulate finding it from the existing productsStreamProvider.
    // However, since productsStreamProvider is family-based on categoryId, we might not have it loaded unless we know the category.
    // If initialCategoryId is provided, we can find it.
    if (widget.initialCategoryId != null) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final products = await ref.read(productRepositoryProvider).streamProducts(user.uid, widget.initialCategoryId!).first;
        final product = products.where((p) => p.id == widget.productId).firstOrNull;
        
        if (product != null) {
          _editingProduct = product;
          _selectedCategoryId = product.categoryId;
          _nameController.text = product.name;
          _priceController.text = product.price.toString();
          _descController.text = product.description;
          _memoController.text = product.memo;
          _showOnKitchen = product.showOnKitchenOrderForm;
          _showInSelfOrder = product.showInSelfOrder;
          
          if (product.stockCount == null) {
            _isUnlimitedStock = true;
          } else {
            _stockController.text = product.stockCount.toString();
          }
          _existingImages = List.from(product.imageUrls);
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    if (_existingImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('최대 5개의 이미지만 등록 가능합니다.')));
      return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isUploadingImage = true);
        final user = ref.read(authStateProvider).value;
        if (user != null) {
          final repo = ref.read(productRepositoryProvider);
          final prodId = _editingProduct?.id ?? _draftProductId ?? repo.getNewProductId();
          if (_editingProduct == null && _draftProductId == null) {
             _draftProductId = prodId;
          }
          final url = await repo.uploadProductImage(image, user.uid, prodId);
          setState(() {
            _existingImages.add(url);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _saveProduct() async {
    final user = ref.read(authStateProvider).value;
    if (user == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('상품명을 입력해주세요.')));
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가격을 입력해주세요.')));
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    int? stockCount;
    if (!_isUnlimitedStock) {
      stockCount = int.tryParse(_stockController.text.trim());
    }

    final repo = ref.read(productRepositoryProvider);

    setState(() => _isLoading = true);
    try {
      String prodId = _editingProduct?.id ?? _draftProductId ?? repo.getNewProductId();
      List<String> finalImageUrls = List.from(_existingImages);
      
      if (_editingProduct == null) {
        // Find max grid index for this category
        final existingProducts = await repo.streamProducts(user.uid, _selectedCategoryId!).first;
        final maxGrid = existingProducts.isEmpty ? 0 : existingProducts.map((p) => p.gridIndex).reduce((a, b) => a > b ? a : b);
        
        final newProduct = PosProduct(
          id: prodId,
          merchantId: user.uid,
          categoryId: _selectedCategoryId!,
          name: _nameController.text.trim(),
          price: price,
          description: _descController.text.trim(),
          memo: _memoController.text.trim(),
          stockCount: stockCount,
          showOnKitchenOrderForm: _showOnKitchen,
          showInSelfOrder: _showInSelfOrder,
          imageUrls: finalImageUrls,
          gridIndex: maxGrid + 1,
        );
        
        await repo.createProduct(newProduct);
      } else {
        // Update
        final updatedProduct = _editingProduct!.copyWith(
          categoryId: _selectedCategoryId,
          name: _nameController.text.trim(),
          price: price,
          description: _descController.text.trim(),
          memo: _memoController.text.trim(),
          stockCount: stockCount,
          clearStockCount: _isUnlimitedStock,
          showOnKitchenOrderForm: _showOnKitchen,
          showInSelfOrder: _showInSelfOrder,
          imageUrls: finalImageUrls,
        );
        await repo.updateProduct(updatedProduct);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {bool isNumber = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTogglePair(String title, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        _buildSectionTitle(title),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: value ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
                    border: Border.all(color: value ? Colors.black : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text('O', style: TextStyle(color: value ? Colors.white : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: !value ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(8.r)),
                    border: Border.all(color: !value ? Colors.black : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text('X', style: TextStyle(color: !value ? Colors.white : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumb({required String url, required VoidCallback onRemove}) {
    return Container(
      width: 56.w,
      height: 56.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(url, fit: BoxFit.cover),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(widget.productId == null ? '상품 추가' : '상품 수정', style: TextStyle(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            _buildSectionTitle('카테고리 선택'),
            categoriesAsync.when(
              data: (categories) {
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey.shade400 : Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error loading categories'),
            ),
            
            SizedBox(height: 16.h),
            _buildSectionTitle('상품명'),
            _buildTextField(_nameController),

            _buildSectionTitle('기본 가격'),
            _buildTextField(_priceController, isNumber: true),

            _buildSectionTitle('한줄 설명'),
            _buildTextField(_descController),

            _buildSectionTitle('재고'),
            _buildTextField(
              _stockController,
              isNumber: true,
              suffix: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isUnlimitedStock = !_isUnlimitedStock;
                      if (_isUnlimitedStock) {
                        _stockController.clear();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _isUnlimitedStock ? Colors.black : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: Text('설정 안함', style: TextStyle(color: _isUnlimitedStock ? Colors.white : Colors.black87, fontSize: 12.sp)),
                ),
              ),
            ),

            _buildSectionTitle('관리용 메모'),
            _buildTextField(_memoController),

            _buildTogglePair('주방 주문서 연동', _showOnKitchen, (val) => setState(() => _showOnKitchen = val)),
            _buildTogglePair('셀프 주문 노출', _showInSelfOrder, (val) => setState(() => _showInSelfOrder = val)),

            _buildSectionTitle('상품 사진'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Add button or Loading Indicator
                  if (_existingImages.length < 5)
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: _isUploadingImage ? Colors.grey.shade200 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: _isUploadingImage 
                          ? Center(child: SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))) 
                          : Icon(Icons.add_photo_alternate_outlined, size: 32.w),
                      ),
                    ),
                  // Existing images
                  ..._existingImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return _buildImageThumb(
                      url: url,
                      onRemove: _isUploadingImage ? () {} : () => setState(() => _existingImages.removeAt(index)),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('1개 ~ 5개 (업로드 완료 전까지 저장 불가)', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                onPressed: _isUploadingImage ? null : _saveProduct,
                child: Text(
                  widget.productId == null ? '추가하기' : '수정하기',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
