class BodyMeasurement {
  final int? id;
  final int userId;
  final double height;
  final double weight;
  final double chest;
  final double waist;
  final double hips;
  final double shoulder;
  final double armLength;
  final double legLength;
  final double neck;
  final double footLength;
  final String? bodyType;
  final DateTime createdAt;

  BodyMeasurement({
    this.id,
    required this.userId,
    required this.height,
    required this.weight,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.shoulder,
    required this.armLength,
    required this.legLength,
    required this.neck,
    required this.footLength,
    this.bodyType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'shoulder': shoulder,
      'arm_length': armLength,
      'leg_length': legLength,
      'neck': neck,
      'foot_length': footLength,
      'body_type': bodyType ?? calculateBodyType(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      chest: (map['chest'] as num).toDouble(),
      waist: (map['waist'] as num).toDouble(),
      hips: (map['hips'] as num).toDouble(),
      shoulder: (map['shoulder'] as num).toDouble(),
      armLength: (map['arm_length'] as num).toDouble(),
      legLength: (map['leg_length'] as num).toDouble(),
      neck: (map['neck'] as num).toDouble(),
      footLength: (map['foot_length'] as num).toDouble(),
      bodyType: map['body_type'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String calculateBodyType() {
    final ratio = waist / hips;
    if (ratio < 0.75) return 'Pear';
    if (ratio < 0.80) return 'Hourglass';
    if (ratio < 0.85) return 'Rectangle';
    return 'Apple';
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String getTopSize() {
    if (chest < 82) return 'XS';
    if (chest < 90) return 'S';
    if (chest < 98) return 'M';
    if (chest < 106) return 'L';
    if (chest < 114) return 'XL';
    return 'XXL';
  }

  String getBottomSize() {
    if (waist < 66) return 'XS';
    if (waist < 74) return 'S';
    if (waist < 82) return 'M';
    if (waist < 90) return 'L';
    if (waist < 98) return 'XL';
    return 'XXL';
  }

  String getShoeSize() {
    if (footLength < 24) return '38';
    if (footLength < 25) return '39';
    if (footLength < 26) return '40';
    if (footLength < 27) return '41';
    if (footLength < 28) return '42';
    if (footLength < 29) return '43';
    return '44';
  }
}
