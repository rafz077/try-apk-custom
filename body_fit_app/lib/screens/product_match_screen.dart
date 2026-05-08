import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/body_measurement.dart';
import '../models/product_model.dart';
import '../services/marketplace_service.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';

class ProductMatchScreen extends StatefulWidget {
  final BodyMeasurement? measurement;

  const ProductMatchScreen({super.key, this.measurement});

  @override
  State<ProductMatchScreen> createState() => _ProductMatchScreenState();
}

class _ProductMatchScreenState extends State<ProductMatchScreen> {
  String? _selectedCategory;
  String? _selectedMarketplace;
  List<ProductModel> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.measurement != null) {
      _loadProducts();
    }
  }

  @override
  void didUpdateWidget(ProductMatchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.measurement != oldWidget.measurement &&
        widget.measurement != null) {
      _loadProducts();
    }
  }

  void _loadProducts() {
    if (widget.measurement == null) return;

    setState(() => _isLoading = true);

    final products = MarketplaceService().getMatchedProducts(
      widget.measurement!,
      category: _selectedCategory,
      marketplace: _selectedMarketplace,
      limit: 30,
    );

    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.measurement == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data pengukuran',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ukur tubuh terlebih dahulu untuk mendapatkan\nrekomendasi produk',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Produk Cocok Untuk Anda',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 4),
              Text(
                'Size Atas: ${widget.measurement!.getTopSize()} | Bawah: ${widget.measurement!.getBottomSize()} | Sepatu: ${widget.measurement!.getShoeSize()}',
                style: TextStyle(
                  color: AppColors.accent.withOpacity(0.9),
                  fontSize: 13,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Category filter
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Semua', null, isCategory: true),
              ...ProductCategory.all.map(
                  (cat) => _buildFilterChip(cat, cat, isCategory: true)),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 8),

        // Marketplace filter
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Semua', null, isCategory: false),
              ...AppStrings.marketplaces.map(
                  (mp) => _buildFilterChip(mp, mp, isCategory: false)),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

        const SizedBox(height: 8),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '${_products.length} produk ditemukan',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Icon(Icons.sort,
                  color: AppColors.textSecondary.withOpacity(0.5), size: 18),
              const SizedBox(width: 4),
              Text(
                'Kesesuaian tertinggi',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Product list
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _products.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada produk ditemukan',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: _products[index],
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 50 * index),
                              duration: 400.ms,
                            )
                            .slideX(begin: 0.05, end: 0);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value,
      {required bool isCategory}) {
    final isSelected = isCategory
        ? _selectedCategory == value
        : _selectedMarketplace == value;

    Color chipColor = AppColors.primary;
    if (!isCategory && value != null) {
      chipColor = AppStrings.marketplaceColors[value] ?? AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isCategory) {
              _selectedCategory = value;
            } else {
              _selectedMarketplace = value;
            }
          });
          _loadProducts();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withOpacity(0.3)
                : AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? chipColor
                  : AppColors.surface,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? chipColor : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
