import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late List<FloatingParticle> _particles;
  late List<GeometricShape> _shapes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _particles = List.generate(25, (i) => FloatingParticle());
    _shapes = List.generate(8, (i) => GeometricShape());
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: PremiumBackgroundPainter(
              _particles, _shapes, _controller.value, _shimmerController.value,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class FloatingParticle {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double opacity;
  late int colorType;

  FloatingParticle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 3 + 1;
    speed = random.nextDouble() * 0.3 + 0.1;
    opacity = random.nextDouble() * 0.25 + 0.05;
    colorType = random.nextInt(3);
  }
}

class GeometricShape {
  late double x;
  late double y;
  late double size;
  late double rotation;
  late double speed;
  late double opacity;
  late int type;

  GeometricShape() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 40 + 20;
    rotation = random.nextDouble() * pi * 2;
    speed = random.nextDouble() * 0.15 + 0.05;
    opacity = random.nextDouble() * 0.08 + 0.02;
    type = random.nextInt(3);
  }
}

class PremiumBackgroundPainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final List<GeometricShape> shapes;
  final double animationValue;
  final double shimmerValue;

  PremiumBackgroundPainter(
    this.particles, this.shapes, this.animationValue, this.shimmerValue,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final dy = (shape.y + animationValue * shape.speed) % 1.2 - 0.1;
      final center = Offset(shape.x * size.width, dy * size.height);
      final rotation = shape.rotation + animationValue * pi * 2;

      switch (shape.type) {
        case 0:
          paint.color = AppColors.primary.withOpacity(shape.opacity);
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(rotation);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: shape.size, height: shape.size),
            paint,
          );
          canvas.restore();
          break;
        case 1:
          paint.color = AppColors.secondary.withOpacity(shape.opacity);
          canvas.drawCircle(center, shape.size / 2, paint);
          break;
        case 2:
          paint.color = AppColors.gold.withOpacity(shape.opacity);
          final path = Path();
          for (int i = 0; i < 6; i++) {
            final angle = (pi / 3) * i + rotation;
            final point = Offset(
              center.dx + cos(angle) * shape.size / 2,
              center.dy + sin(angle) * shape.size / 2,
            );
            if (i == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }

    for (final particle in particles) {
      Color particleColor;
      switch (particle.colorType) {
        case 0:
          particleColor = AppColors.primary;
          break;
        case 1:
          particleColor = AppColors.secondary;
          break;
        default:
          particleColor = AppColors.gold;
      }

      final paint = Paint()
        ..color = particleColor.withOpacity(particle.opacity * (0.7 + shimmerValue * 0.3))
        ..style = PaintingStyle.fill;

      final dy = (particle.y + animationValue * particle.speed) % 1.0;
      canvas.drawCircle(
        Offset(particle.x * size.width, dy * size.height),
        particle.radius,
        paint,
      );
    }

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withOpacity(0.03 * shimmerValue),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
