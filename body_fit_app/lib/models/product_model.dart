class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String size;
  final String marketplace;
  final String imageUrl;
  final String productUrl;
  final double rating;
  final int soldCount;
  final double matchScore;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.size,
    required this.marketplace,
    required this.imageUrl,
    required this.productUrl,
    required this.rating,
    required this.soldCount,
    this.matchScore = 0.0,
  });

  ProductModel copyWith({double? matchScore}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      category: category,
      price: price,
      size: size,
      marketplace: marketplace,
      imageUrl: imageUrl,
      productUrl: productUrl,
      rating: rating,
      soldCount: soldCount,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  String get formattedPrice {
    final parts = <String>[];
    int p = price.toInt();
    while (p > 0) {
      final remainder = p % 1000;
      p = p ~/ 1000;
      if (p > 0) {
        parts.insert(0, remainder.toString().padLeft(3, '0'));
      } else {
        parts.insert(0, remainder.toString());
      }
    }
    if (parts.isEmpty) parts.add('0');
    return 'Rp ${parts.join('.')}';
  }

  String get matchPercentage => '${(matchScore * 100).toInt()}%';
}

class ProductCategory {
  static const String tops = 'Atasan';
  static const String bottoms = 'Bawahan';
  static const String shoes = 'Sepatu';
  static const String outerwear = 'Jaket & Outer';
  static const String underwear = 'Pakaian Dalam';
  static const String accessories = 'Aksesoris';
  static const String sportswear = 'Pakaian Olahraga';
  static const String formal = 'Pakaian Formal';

  static List<String> get all => [
        tops,
        bottoms,
        shoes,
        outerwear,
        underwear,
        accessories,
        sportswear,
        formal,
      ];

  static Map<String, IconInfo> get icons => {
        tops: IconInfo(0xe318, 'Atasan'),
        bottoms: IconInfo(0xe318, 'Bawahan'),
        shoes: IconInfo(0xe318, 'Sepatu'),
        outerwear: IconInfo(0xe318, 'Jaket & Outer'),
        underwear: IconInfo(0xe318, 'Pakaian Dalam'),
        accessories: IconInfo(0xe318, 'Aksesoris'),
        sportswear: IconInfo(0xe318, 'Pakaian Olahraga'),
        formal: IconInfo(0xe318, 'Pakaian Formal'),
      };
}

class IconInfo {
  final int codePoint;
  final String label;
  IconInfo(this.codePoint, this.label);
}
