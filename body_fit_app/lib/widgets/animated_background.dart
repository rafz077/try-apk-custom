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
  late List<FloatingParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(20, (i) => FloatingParticle());
  }

  @override
  void dispose() {
    _controller.dispose();
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
            painter: ParticlePainter(_particles, _controller.value),
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

  FloatingParticle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 3 + 1;
    speed = random.nextDouble() * 0.3 + 0.1;
    opacity = random.nextDouble() * 0.3 + 0.05;
  }
}

class ParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = AppColors.primary.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final dy = (particle.y + animationValue * particle.speed) % 1.0;
      canvas.drawCircle(
        Offset(particle.x * size.width, dy * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
