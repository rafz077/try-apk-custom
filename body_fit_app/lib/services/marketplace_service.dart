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
    int limit = 50,
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

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final matchScore = _calculateMatchScore(measurement, category, size);
      final price = (item['basePrice'] as int) +
          _random.nextInt((item['priceRange'] as int));

      final productName = item['name'] as String;
      final directUrl = _getDirectProductUrl(marketplace, productName, category);

      products.add(ProductModel(
        id: '${marketplace}_${category}_$i',
        name: '$productName - Size $size',
        description: item['description'] as String,
        category: category,
        price: price.toDouble(),
        size: size,
        marketplace: marketplace,
        imageUrl: _getProductImageUrl(category, i),
        productUrl: directUrl,
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

  String _getDirectProductUrl(String marketplace, String productName, String category) {
    final categoryMap = {
      'Atasan': {'tokopedia': 'pakaian-pria/atasan', 'shopee': 'Pakaian-Pria-cat.11041737', 'lazada': 'baju-pria/', 'bukalapak': 'fashion-pria/atasan-142', 'blibli': 'kategori/pakaian-pria/AT-1000002'},
      'Bawahan': {'tokopedia': 'pakaian-pria/bawahan', 'shopee': 'Pakaian-Pria-cat.11041737', 'lazada': 'celana-pria/', 'bukalapak': 'fashion-pria/bawahan-143', 'blibli': 'kategori/celana-pria/CE-1000003'},
      'Sepatu': {'tokopedia': 'sepatu', 'shopee': 'Sepatu-Pria-cat.11041777', 'lazada': 'sepatu-pria/', 'bukalapak': 'sepatu/sepatu-pria-261', 'blibli': 'kategori/sepatu-pria/SE-1000004'},
      'Jaket & Outer': {'tokopedia': 'pakaian-pria/jaket-coat', 'shopee': 'Pakaian-Pria-cat.11041737', 'lazada': 'jaket-pria/', 'bukalapak': 'fashion-pria/jaket-coat-144', 'blibli': 'kategori/jaket-pria/JA-1000005'},
      'Pakaian Olahraga': {'tokopedia': 'olahraga/pakaian-olahraga', 'shopee': 'Olahraga-cat.11041819', 'lazada': 'pakaian-olahraga/', 'bukalapak': 'olahraga/pakaian-olahraga-340', 'blibli': 'kategori/pakaian-olahraga/OL-1000006'},
      'Pakaian Formal': {'tokopedia': 'pakaian-pria/setelan', 'shopee': 'Pakaian-Pria-cat.11041737', 'lazada': 'setelan-pria/', 'bukalapak': 'fashion-pria/setelan-145', 'blibli': 'kategori/setelan-pria/ST-1000007'},
    };

    final query = Uri.encodeComponent(productName);
    final catPaths = categoryMap[category];
    final mpKey = marketplace.toLowerCase();

    switch (marketplace) {
      case 'Tokopedia':
        final catPath = catPaths?['tokopedia'] ?? 'search';
        return 'https://www.tokopedia.com/$catPath?q=$query';
      case 'Shopee':
        final catPath = catPaths?['shopee'] ?? '';
        return 'https://shopee.co.id/search?keyword=$query&$catPath';
      case 'Lazada':
        final catPath = catPaths?['lazada'] ?? 'catalog/';
        return 'https://www.lazada.co.id/$catPath?q=$query';
      case 'Bukalapak':
        final catPath = catPaths?['bukalapak'] ?? 'products';
        return 'https://www.bukalapak.com/$catPath?search%5Bkeywords%5D=$query';
      case 'Blibli':
        return 'https://www.blibli.com/cari/$query';
      default:
        return 'https://www.google.com/search?q=$query+$mpKey';
    }
  }

  String _getProductImageUrl(String category, int index) {
    final imageIds = {
      'Atasan': ['ZVprbBmT1QA', 'FO4yDOqKLuw', 'QA_7TGm4LPA', 'DLKR_x3T_7s', 'B3dYiMEDMc4', 'rDEOVtE7vOs', 'WKSCwEI0E90', 'YVNep4jrSNY'],
      'Bawahan': ['ZV_64LdGoao', 'voc8cpD2-MM', '1k5j0RBISrI', 'p6yH8VmGqxo', 'Xxo3-gFi1Aw', 'HH4WBGNyltc', '8l8Yl2sl9sg', 'bJdhRpMBnXQ'],
      'Sepatu': ['pair-of-gray-white-sneakers', 'TamMbr4okv4', 'fRdKCgLOVBU', 'K1ohCnCMdAg', 'L-cac_MtSqU', 'YkS1yBT_FGo', 'gYVNvRygCUw', 'iippKFVMnbM'],
      'Jaket & Outer': ['_3Q3tsJ01nc', 'OPzZEZ2yEuY', 'iB8GYyFKVOA', 'ZuQnhpFjvHI', 'HvOI4nOY9GE', 'H-LIL57PHCc'],
      'Pakaian Olahraga': ['n6gnCa77Urc', 'WvDYdXDzkhs', 'oGv9xIl7DkY', 'gJtDg6WfMlQ', 'sZINHMeA4dA', '3ckWUnaCxzc'],
      'Pakaian Formal': ['4uxd0-32ePQ', 'tYaccl19A3Q', 'bN5MYhFO0t8', 'mW_k-RfiGQo', 'uF8f-FBEKnc', 'WTiMwJx4kEM'],
    };
    final ids = imageIds[category] ?? imageIds['Atasan']!;
    final id = ids[index % ids.length];
    return 'https://images.unsplash.com/photo-$id?w=400&h=400&fit=crop';
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
    {
      'name': 'Kaos Oversize Streetwear',
      'description': 'Kaos oversize trendy dengan desain streetwear kekinian',
      'basePrice': 55000,
      'priceRange': 35000
    },
    {
      'name': 'Henley Shirt Long Sleeve',
      'description': 'Henley shirt casual lengan panjang bahan katun premium',
      'basePrice': 85000,
      'priceRange': 45000
    },
    {
      'name': 'Tank Top Gym Performance',
      'description': 'Tank top gym bahan dry-fit untuk performa olahraga maksimal',
      'basePrice': 40000,
      'priceRange': 25000
    },
    {
      'name': 'Kemeja Flanel Kotak-Kotak',
      'description': 'Kemeja flanel motif kotak bahan tebal dan hangat',
      'basePrice': 95000,
      'priceRange': 50000
    },
    {
      'name': 'Cardigan Knit Premium',
      'description': 'Cardigan rajut premium dengan kancing depan elegan',
      'basePrice': 130000,
      'priceRange': 70000
    },
    {
      'name': 'T-Shirt Graphic Art Print',
      'description': 'Kaos dengan desain grafis artistik limited edition',
      'basePrice': 65000,
      'priceRange': 40000
    },
    {
      'name': 'Kemeja Linen Summer',
      'description': 'Kemeja linen ringan dan adem untuk musim panas',
      'basePrice': 110000,
      'priceRange': 60000
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
    {
      'name': 'Celana Kulot Wide Leg',
      'description': 'Celana kulot wide leg trendy dengan pinggang elastis',
      'basePrice': 78000,
      'priceRange': 42000
    },
    {
      'name': 'Celana Cargo Tactical',
      'description': 'Celana cargo tactical anti air dengan banyak kantong',
      'basePrice': 135000,
      'priceRange': 65000
    },
    {
      'name': 'Celana Bahan Formal Reguler',
      'description': 'Celana bahan formal reguler fit untuk kerja dan acara resmi',
      'basePrice': 110000,
      'priceRange': 60000
    },
    {
      'name': 'Jeans Skinny Stretch',
      'description': 'Jeans skinny stretch dengan bahan elastis nyaman',
      'basePrice': 125000,
      'priceRange': 75000
    },
    {
      'name': 'Celana Training Jogger Sport',
      'description': 'Celana training jogger dengan side stripe sporty',
      'basePrice': 70000,
      'priceRange': 40000
    },
    {
      'name': 'Celana Pendek Board Shorts',
      'description': 'Celana pendek board shorts untuk pantai dan casual',
      'basePrice': 60000,
      'priceRange': 35000
    },
    {
      'name': 'Celana Corduroy Vintage',
      'description': 'Celana corduroy vintage style retro dengan bahan premium',
      'basePrice': 140000,
      'priceRange': 80000
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
    {
      'name': 'Sepatu Loafer Kulit',
      'description': 'Sepatu loafer kulit sintetis untuk tampilan smart casual',
      'basePrice': 195000,
      'priceRange': 105000
    },
    {
      'name': 'Sneakers Casual Canvas',
      'description': 'Sneakers casual bahan canvas ringan dan nyaman',
      'basePrice': 120000,
      'priceRange': 80000
    },
    {
      'name': 'Sepatu Hiking Outdoor',
      'description': 'Sepatu hiking waterproof untuk petualangan outdoor',
      'basePrice': 320000,
      'priceRange': 180000
    },
    {
      'name': 'Slip On Casual Pria',
      'description': 'Slip on casual nyaman untuk pemakaian sehari-hari',
      'basePrice': 85000,
      'priceRange': 55000
    },
    {
      'name': 'Sepatu Futsal Indoor',
      'description': 'Sepatu futsal indoor dengan sol anti selip premium',
      'basePrice': 175000,
      'priceRange': 125000
    },
    {
      'name': 'Sandal Gunung Adventure',
      'description': 'Sandal gunung adventure dengan tali adjustable',
      'basePrice': 95000,
      'priceRange': 65000
    },
    {
      'name': 'Sepatu Derby Classic',
      'description': 'Sepatu derby classic untuk acara formal dan wedding',
      'basePrice': 280000,
      'priceRange': 170000
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
    {
      'name': 'Parka Jacket Winter',
      'description': 'Jaket parka tebal dengan bulu dalam untuk cuaca dingin',
      'basePrice': 280000,
      'priceRange': 170000
    },
    {
      'name': 'Vest Rompi Outdoor',
      'description': 'Vest rompi outdoor multifungsi dengan banyak kantong',
      'basePrice': 115000,
      'priceRange': 75000
    },
    {
      'name': 'Denim Jacket Classic',
      'description': 'Jaket denim classic washing vintage untuk gaya retro',
      'basePrice': 165000,
      'priceRange': 95000
    },
    {
      'name': 'Leather Jacket Premium',
      'description': 'Jaket kulit sintetis premium dengan detail zipper',
      'basePrice': 350000,
      'priceRange': 200000
    },
    {
      'name': 'Raincoat Poncho',
      'description': 'Jas hujan poncho anti air ringan dan praktis dibawa',
      'basePrice': 65000,
      'priceRange': 45000
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
    {
      'name': 'Running Shorts Quick Dry',
      'description': 'Celana pendek running quick dry dengan inner brief',
      'basePrice': 55000,
      'priceRange': 35000
    },
    {
      'name': 'Sports Bra High Impact',
      'description': 'Sports bra high impact dengan support maksimal',
      'basePrice': 75000,
      'priceRange': 45000
    },
    {
      'name': 'Track Suit Set',
      'description': 'Set track suit jaket dan celana untuk jogging dan gym',
      'basePrice': 180000,
      'priceRange': 100000
    },
    {
      'name': 'Yoga Pants Stretch',
      'description': 'Celana yoga stretch 4 arah untuk fleksibilitas maksimal',
      'basePrice': 90000,
      'priceRange': 50000
    },
    {
      'name': 'Swimming Trunks Board',
      'description': 'Celana renang board shorts quick dry anti chlorine',
      'basePrice': 65000,
      'priceRange': 40000
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
    {
      'name': 'Vest Formal Waistcoat',
      'description': 'Vest formal waistcoat untuk tampilan three-piece suit',
      'basePrice': 160000,
      'priceRange': 100000
    },
    {
      'name': 'Kemeja Formal French Cuff',
      'description': 'Kemeja formal french cuff dengan kancing manset premium',
      'basePrice': 145000,
      'priceRange': 85000
    },
    {
      'name': 'Batik Tulis Premium',
      'description': 'Batik tulis premium buatan tangan dengan motif eksklusif',
      'basePrice': 350000,
      'priceRange': 250000
    },
    {
      'name': 'Blazer Double Breasted',
      'description': 'Blazer double breasted modern untuk tampilan berkelas',
      'basePrice': 280000,
      'priceRange': 170000
    },
    {
      'name': 'Tuxedo Set Premium',
      'description': 'Set tuxedo premium untuk pesta dan acara formal mewah',
      'basePrice': 650000,
      'priceRange': 350000
    },
  ];
}
