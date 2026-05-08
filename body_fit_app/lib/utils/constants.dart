import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF00D2FF);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundMedium = Color(0xFF16213E);
  static const Color backgroundLight = Color(0xFF0F3460);
  static const Color surface = Color(0xFF232946);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D4);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
  static const Color cardGradientStart = Color(0xFF2D2D5E);
  static const Color cardGradientEnd = Color(0xFF1A1A3E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundMedium, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardGradientStart, cardGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStrings {
  static const String appName = 'BodyFit Market';
  static const String appTagline = 'Find Your Perfect Fit';
  static const String trialDays = '7';
  static const String subscriptionPrice = 'Rp 49.000/bulan';

  static const List<String> marketplaces = [
    'Tokopedia',
    'Shopee',
    'Lazada',
    'Bukalapak',
    'Blibli',
  ];

  static const Map<String, String> marketplaceBaseUrls = {
    'Tokopedia': 'https://www.tokopedia.com/search?q=',
    'Shopee': 'https://shopee.co.id/search?keyword=',
    'Lazada': 'https://www.lazada.co.id/catalog/?q=',
    'Bukalapak': 'https://www.bukalapak.com/products?search%5Bkeywords%5D=',
    'Blibli': 'https://www.blibli.com/cari/',
  };

  static const Map<String, IconData> marketplaceIcons = {
    'Tokopedia': Icons.shopping_bag,
    'Shopee': Icons.store,
    'Lazada': Icons.local_mall,
    'Bukalapak': Icons.storefront,
    'Blibli': Icons.shopping_cart,
  };

  static const Map<String, Color> marketplaceColors = {
    'Tokopedia': Color(0xFF42B549),
    'Shopee': Color(0xFFEE4D2D),
    'Lazada': Color(0xFF0F146D),
    'Bukalapak': Color(0xFFE31E52),
    'Blibli': Color(0xFF0095DA),
  };
}

class BodyPartLabels {
  static const Map<String, String> labels = {
    'height': 'Tinggi Badan (cm)',
    'weight': 'Berat Badan (kg)',
    'chest': 'Lingkar Dada (cm)',
    'waist': 'Lingkar Pinggang (cm)',
    'hips': 'Lingkar Pinggul (cm)',
    'shoulder': 'Lebar Bahu (cm)',
    'armLength': 'Panjang Lengan (cm)',
    'legLength': 'Panjang Kaki (cm)',
    'neck': 'Lingkar Leher (cm)',
    'footLength': 'Panjang Kaki (cm)',
  };

  static const Map<String, String> sizeGuide = {
    'XS': 'Extra Small',
    'S': 'Small',
    'M': 'Medium',
    'L': 'Large',
    'XL': 'Extra Large',
    'XXL': 'Double Extra Large',
  };
}
