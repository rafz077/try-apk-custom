import 'dart:math';
import '../models/product_model.dart';
import '../models/body_measurement.dart';
import '../utils/constants.dart';

class MarketplaceService {
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  final Random _random = Random(42);

  List<ProductModel> getMatchedProducts(
    BodyMeasurement measurement, {
    String? category,
    String? marketplace,
    int limit = 20,
  }) {
    List<ProductModel> products = _generateProducts(measurement);

    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }
    if (marketplace != null) {
      products = products.where((p) => p.marketplace == marketplace).toList();
    }

    products.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return products.take(limit).toList();
  }

  List<ProductModel> _generateProducts(BodyMeasurement measurement) {
    final products = <ProductModel>[];
    final topSize = measurement.getTopSize();
    final bottomSize = measurement.getBottomSize();
    final shoeSize = measurement.getShoeSize();

    // Generate products for each marketplace
    for (final mp in AppStrings.marketplaces) {
      // Tops
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.tops,
        size: topSize,
        measurement: measurement,
        items: _topItems,
      ));

      // Bottoms
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.bottoms,
        size: bottomSize,
        measurement: measurement,
        items: _bottomItems,
      ));

      // Shoes
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.shoes,
        size: shoeSize,
        measurement: measurement,
        items: _shoeItems,
      ));

      // Outerwear
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.outerwear,
        size: topSize,
        measurement: measurement,
        items: _outerwearItems,
      ));

      // Sportswear
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.sportswear,
        size: topSize,
        measurement: measurement,
        items: _sportswearItems,
      ));

      // Formal
      products.addAll(_generateCategoryProducts(
        marketplace: mp,
        category: ProductCategory.formal,
        size: topSize,
        measurement: measurement,
        items: _formalItems,
      ));
    }

    return products;
  }

  List<ProductModel> _generateCategoryProducts({
    required String marketplace,
    required String category,
    required String size,
    required BodyMeasurement measurement,
    required List<Map<String, dynamic>> items,
  }) {
    final products = <ProductModel>[];
    final baseUrl = AppStrings.marketplaceBaseUrls[marketplace] ?? '';

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final matchScore = _calculateMatchScore(measurement, category, size);
      final price = (item['basePrice'] as int) +
          _random.nextInt((item['priceRange'] as int));

      products.add(ProductModel(
        id: '${marketplace}_${category}_$i',
        name: '${item['name']} - Size $size',
        description: item['description'] as String,
        category: category,
        price: price.toDouble(),
        size: size,
        marketplace: marketplace,
        imageUrl: '',
        productUrl:
            '$baseUrl${Uri.encodeComponent('${item['name']} size $size')}',
        rating: 3.5 + _random.nextDouble() * 1.5,
        soldCount: _random.nextInt(5000) + 100,
        matchScore: matchScore,
      ));
    }

    return products;
  }

  double _calculateMatchScore(
      BodyMeasurement measurement, String category, String size) {
    double baseScore = 0.7 + _random.nextDouble() * 0.25;

    // Adjust based on BMI category
    if (measurement.bmiCategory == 'Normal') {
      baseScore += 0.05;
    }

    // Category-specific adjustments
    switch (category) {
      case ProductCategory.tops:
        if (measurement.chest >= 86 && measurement.chest <= 102) {
          baseScore += 0.03;
        }
        break;
      case ProductCategory.bottoms:
        if (measurement.waist >= 70 && measurement.waist <= 90) {
          baseScore += 0.03;
        }
        break;
      case ProductCategory.shoes:
        if (measurement.footLength >= 24 && measurement.footLength <= 28) {
          baseScore += 0.03;
        }
        break;
      default:
        break;
    }

    return baseScore.clamp(0.0, 1.0);
  }

  String getProductUrl(String marketplace, String searchQuery) {
    final baseUrl = AppStrings.marketplaceBaseUrls[marketplace] ?? '';
    return '$baseUrl${Uri.encodeComponent(searchQuery)}';
  }

  static final List<Map<String, dynamic>> _topItems = [
    {
      'name': 'Kaos Polos Premium Cotton Combed 30s',
      'description':
          'Kaos polos bahan cotton combed 30s, nyaman dan adem untuk sehari-hari',
      'basePrice': 45000,
      'priceRange': 30000
    },
    {
      'name': 'Kemeja Slim Fit Lengan Panjang',
      'description':
          'Kemeja slim fit modern, cocok untuk kerja dan acara formal',
      'basePrice': 89000,
      'priceRange': 60000
    },
    {
      'name': 'Polo Shirt Pria Casual',
      'description': 'Polo shirt casual dengan bahan lacoste premium',
      'basePrice': 75000,
      'priceRange': 45000
    },
    {
      'name': 'Hoodie Oversize Fleece',
      'description': 'Hoodie oversize bahan fleece tebal, hangat dan stylish',
      'basePrice': 95000,
      'priceRange': 55000
    },
    {
      'name': 'Sweater Rajut V-Neck',
      'description': 'Sweater rajut premium dengan desain V-neck elegan',
      'basePrice': 120000,
      'priceRange': 80000
    },
  ];

  static final List<Map<String, dynamic>> _bottomItems = [
    {
      'name': 'Celana Chino Slim Fit',
      'description':
          'Celana chino slim fit bahan stretch, nyaman untuk aktivitas harian',
      'basePrice': 89000,
      'priceRange': 60000
    },
    {
      'name': 'Jeans Denim Straight Cut',
      'description': 'Jeans denim premium dengan potongan straight classic',
      'basePrice': 120000,
      'priceRange': 80000
    },
    {
      'name': 'Celana Jogger Sporty',
      'description': 'Celana jogger bahan parasut, cocok untuk olahraga',
      'basePrice': 65000,
      'priceRange': 40000
    },
    {
      'name': 'Celana Pendek Cargo',
      'description': 'Celana pendek cargo dengan banyak kantong fungsional',
      'basePrice': 55000,
      'priceRange': 35000
    },
  ];

  static final List<Map<String, dynamic>> _shoeItems = [
    {
      'name': 'Sneakers Running Breathable',
      'description': 'Sneakers running dengan teknologi breathable mesh',
      'basePrice': 180000,
      'priceRange': 120000
    },
    {
      'name': 'Sepatu Formal Oxford',
      'description': 'Sepatu formal oxford kulit sintetis premium',
      'basePrice': 220000,
      'priceRange': 150000
    },
    {
      'name': 'Sandal Slide Comfort',
      'description': 'Sandal slide dengan insole empuk anti selip',
      'basePrice': 45000,
      'priceRange': 30000
    },
    {
      'name': 'Boots Casual Ankle',
      'description': 'Boots ankle casual untuk tampilan edgy',
      'basePrice': 250000,
      'priceRange': 150000
    },
  ];

  static final List<Map<String, dynamic>> _outerwearItems = [
    {
      'name': 'Jaket Bomber Premium',
      'description':
          'Jaket bomber bahan parasut waterproof dengan hoodie detachable',
      'basePrice': 150000,
      'priceRange': 100000
    },
    {
      'name': 'Blazer Casual Pria',
      'description': 'Blazer casual slim fit untuk tampilan semi-formal',
      'basePrice': 200000,
      'priceRange': 130000
    },
    {
      'name': 'Windbreaker Waterproof',
      'description': 'Jaket windbreaker anti air dan anti angin',
      'basePrice': 135000,
      'priceRange': 90000
    },
  ];

  static final List<Map<String, dynamic>> _sportswearItems = [
    {
      'name': 'Jersey Olahraga Dri-Fit',
      'description': 'Jersey olahraga dengan teknologi dri-fit quick dry',
      'basePrice': 65000,
      'priceRange': 45000
    },
    {
      'name': 'Celana Training Stretch',
      'description': 'Celana training bahan stretch 4 arah untuk gym',
      'basePrice': 75000,
      'priceRange': 50000
    },
    {
      'name': 'Compression Shirt Long Sleeve',
      'description': 'Baju kompresi lengan panjang untuk performa maksimal',
      'basePrice': 85000,
      'priceRange': 55000
    },
  ];

  static final List<Map<String, dynamic>> _formalItems = [
    {
      'name': 'Setelan Jas Premium',
      'description': 'Setelan jas premium dengan potongan modern',
      'basePrice': 450000,
      'priceRange': 300000
    },
    {
      'name': 'Kemeja Batik Modern',
      'description': 'Kemeja batik dengan motif modern kontemporer',
      'basePrice': 120000,
      'priceRange': 80000
    },
    {
      'name': 'Celana Bahan Slim Fit Formal',
      'description': 'Celana bahan formal slim fit untuk acara resmi',
      'basePrice': 130000,
      'priceRange': 90000
    },
  ];
}
