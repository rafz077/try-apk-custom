import 'dart:math';
import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../utils/constants.dart';

class BodyVisualizationWidget extends StatefulWidget {
  final BodyMeasurement? measurement;
  final String? highlightPart;

  const BodyVisualizationWidget({
    super.key,
    this.measurement,
    this.highlightPart,
  });

  @override
  State<BodyVisualizationWidget> createState() =>
      _BodyVisualizationWidgetState();
}

class _BodyVisualizationWidgetState extends State<BodyVisualizationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  String? _selectedPart;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _prevDx = 0.0;
  double _prevDy = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.threed_rotation, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('3D View - Geser untuk rotasi',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onPanStart: (details) {
            _prevDx = details.localPosition.dx;
            _prevDy = details.localPosition.dy;
          },
          onPanUpdate: (details) {
            setState(() {
              _rotationY += (details.localPosition.dx - _prevDx) * 0.01;
              _rotationX += (details.localPosition.dy - _prevDy) * 0.005;
              _rotationX = _rotationX.clamp(-0.3, 0.3);
              _rotationY = _rotationY.clamp(-0.8, 0.8);
              _prevDx = details.localPosition.dx;
              _prevDy = details.localPosition.dy;
            });
          },
          onTapDown: (details) => _handleTap(details, context),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotationX)
                  ..rotateY(_rotationY),
                child: CustomPaint(
                  size: const Size(280, 480),
                  painter: BodyPainter(
                    measurement: widget.measurement,
                    highlightPart: _selectedPart ?? widget.highlightPart,
                    pulseValue: _pulseAnimation.value,
                    rotationY: _rotationY,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleTap(TapDownDetails details, BuildContext context) {
    final localPosition = details.localPosition;
    final part = _getBodyPart(localPosition);
    if (part != null) {
      setState(() => _selectedPart = part);
      _showPartInfo(context, part);
    }
  }

  String? _getBodyPart(Offset position) {
    if (position.dy < 70) return 'head';
    if (position.dy < 95) return 'neck';
    if (position.dy < 130) return 'shoulder';
    if (position.dy < 230) {
      if (position.dx < 80 || position.dx > 200) return 'arm';
      return 'chest';
    }
    if (position.dy < 290) return 'waist';
    if (position.dy < 330) return 'hips';
    if (position.dy < 450) return 'leg';
    return 'foot';
  }

  void _showPartInfo(BuildContext context, String part) {
    if (widget.measurement == null) return;

    final m = widget.measurement!;
    String info;
    String size;

    switch (part) {
      case 'head':
        info = 'Lingkar Leher: ${m.neck} cm';
        size = '';
        break;
      case 'neck':
        info = 'Lingkar Leher: ${m.neck} cm';
        size = '';
        break;
      case 'shoulder':
        info = 'Lebar Bahu: ${m.shoulder} cm';
        size = 'Size Atasan: ${m.getTopSize()}';
        break;
      case 'chest':
        info = 'Lingkar Dada: ${m.chest} cm';
        size = 'Size Atasan: ${m.getTopSize()}';
        break;
      case 'arm':
        info = 'Panjang Lengan: ${m.armLength} cm';
        size = 'Size Atasan: ${m.getTopSize()}';
        break;
      case 'waist':
        info = 'Lingkar Pinggang: ${m.waist} cm';
        size = 'Size Bawahan: ${m.getBottomSize()}';
        break;
      case 'hips':
        info = 'Lingkar Pinggul: ${m.hips} cm';
        size = 'Size Bawahan: ${m.getBottomSize()}';
        break;
      case 'leg':
        info = 'Panjang Kaki: ${m.legLength} cm';
        size = 'Size Bawahan: ${m.getBottomSize()}';
        break;
      case 'foot':
        info = 'Panjang Kaki: ${m.footLength} cm';
        size = 'Size Sepatu: ${m.getShoeSize()}';
        break;
      default:
        info = '';
        size = '';
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.straighten, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (size.isNotEmpty) Text(size, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class BodyPainter extends CustomPainter {
  final BodyMeasurement? measurement;
  final String? highlightPart;
  final double pulseValue;
  final double rotationY;

  BodyPainter({this.measurement, this.highlightPart, this.pulseValue = 1.0, this.rotationY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.height / 480;
    // Apply depth offset based on rotation for 3D effect
    final depthOffset = sin(rotationY) * 15;

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.4),
          AppColors.primary.withOpacity(0.2),
          AppColors.emerald.withOpacity(0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final outlinePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final highlightPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.08 * pulseValue)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // 3D depth shadow for side-facing elements
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Calculate proportions based on measurements
    double shoulderWidth = 70 * scale;
    double chestWidth = 60 * scale;
    double waistWidth = 50 * scale;
    double hipWidth = 55 * scale;

    if (measurement != null) {
      shoulderWidth = (measurement!.shoulder / 2.5) * scale;
      chestWidth = (measurement!.chest / 3.5) * scale;
      waistWidth = (measurement!.waist / 3.5) * scale;
      hipWidth = (measurement!.hips / 3.5) * scale;
    }

    // Draw glow behind body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.45),
        width: shoulderWidth * 2.5 * pulseValue,
        height: size.height * 0.7 * pulseValue,
      ),
      glowPaint,
    );

    // Draw 3D depth shadow behind body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + depthOffset, size.height * 0.45),
        width: shoulderWidth * 1.8,
        height: size.height * 0.6,
      ),
      shadowPaint,
    );

    // Head
    final headRadius = 25 * scale;
    final headCenter = Offset(centerX, 35 * scale);
    _drawPart(canvas, 'head', () {
      canvas.drawCircle(headCenter, headRadius, bodyPaint);
      canvas.drawCircle(headCenter, headRadius, outlinePaint);
    }, highlightPaint);

    // Neck
    _drawPart(canvas, 'neck', () {
      final neckRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, 70 * scale),
            width: 18 * scale,
            height: 20 * scale),
        Radius.circular(5 * scale),
      );
      canvas.drawRRect(neckRect, bodyPaint);
      canvas.drawRRect(neckRect, outlinePaint);
    }, highlightPaint);

    // Torso (shoulders to waist)
    _drawPart(canvas, 'chest', () {
      final torsoPath = Path()
        ..moveTo(centerX - shoulderWidth, 85 * scale)
        ..lineTo(centerX + shoulderWidth, 85 * scale)
        ..lineTo(centerX + chestWidth, 150 * scale)
        ..lineTo(centerX + waistWidth, 220 * scale)
        ..lineTo(centerX - waistWidth, 220 * scale)
        ..lineTo(centerX - chestWidth, 150 * scale)
        ..close();
      canvas.drawPath(torsoPath, bodyPaint);
      canvas.drawPath(torsoPath, outlinePaint);
    }, highlightPaint);

    // Hips
    _drawPart(canvas, 'hips', () {
      final hipsPath = Path()
        ..moveTo(centerX - waistWidth, 220 * scale)
        ..lineTo(centerX + waistWidth, 220 * scale)
        ..quadraticBezierTo(
            centerX + hipWidth, 250 * scale, centerX + hipWidth, 270 * scale)
        ..lineTo(centerX - hipWidth, 270 * scale)
        ..quadraticBezierTo(
            centerX - hipWidth, 250 * scale, centerX - waistWidth, 220 * scale)
        ..close();
      canvas.drawPath(hipsPath, bodyPaint);
      canvas.drawPath(hipsPath, outlinePaint);
    }, highlightPaint);

    // Left Arm
    _drawPart(canvas, 'arm', () {
      final leftArmPath = Path()
        ..moveTo(centerX - shoulderWidth, 90 * scale)
        ..lineTo(centerX - shoulderWidth - 15 * scale, 90 * scale)
        ..lineTo(centerX - shoulderWidth - 20 * scale, 200 * scale)
        ..lineTo(centerX - shoulderWidth - 5 * scale, 200 * scale)
        ..close();
      canvas.drawPath(leftArmPath, bodyPaint);
      canvas.drawPath(leftArmPath, outlinePaint);

      // Right Arm
      final rightArmPath = Path()
        ..moveTo(centerX + shoulderWidth, 90 * scale)
        ..lineTo(centerX + shoulderWidth + 15 * scale, 90 * scale)
        ..lineTo(centerX + shoulderWidth + 20 * scale, 200 * scale)
        ..lineTo(centerX + shoulderWidth + 5 * scale, 200 * scale)
        ..close();
      canvas.drawPath(rightArmPath, bodyPaint);
      canvas.drawPath(rightArmPath, outlinePaint);
    }, highlightPaint);

    // Left Leg
    _drawPart(canvas, 'leg', () {
      final leftLegPath = Path()
        ..moveTo(centerX - hipWidth + 5 * scale, 270 * scale)
        ..lineTo(centerX - 5 * scale, 270 * scale)
        ..lineTo(centerX - 8 * scale, 400 * scale)
        ..lineTo(centerX - hipWidth + 8 * scale, 400 * scale)
        ..close();
      canvas.drawPath(leftLegPath, bodyPaint);
      canvas.drawPath(leftLegPath, outlinePaint);

      // Right Leg
      final rightLegPath = Path()
        ..moveTo(centerX + 5 * scale, 270 * scale)
        ..lineTo(centerX + hipWidth - 5 * scale, 270 * scale)
        ..lineTo(centerX + hipWidth - 8 * scale, 400 * scale)
        ..lineTo(centerX + 8 * scale, 400 * scale)
        ..close();
      canvas.drawPath(rightLegPath, bodyPaint);
      canvas.drawPath(rightLegPath, outlinePaint);
    }, highlightPaint);

    // Feet
    _drawPart(canvas, 'foot', () {
      final leftFoot = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - hipWidth / 2 + 3 * scale, 415 * scale),
          width: hipWidth * 0.6,
          height: 18 * scale,
        ),
        Radius.circular(8 * scale),
      );
      canvas.drawRRect(leftFoot, bodyPaint);
      canvas.drawRRect(leftFoot, outlinePaint);

      final rightFoot = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + hipWidth / 2 - 3 * scale, 415 * scale),
          width: hipWidth * 0.6,
          height: 18 * scale,
        ),
        Radius.circular(8 * scale),
      );
      canvas.drawRRect(rightFoot, bodyPaint);
      canvas.drawRRect(rightFoot, outlinePaint);
    }, highlightPaint);

    // Draw measurement labels if measurements exist
    if (measurement != null) {
      _drawMeasurementLabels(canvas, size, centerX, scale, shoulderWidth,
          chestWidth, waistWidth, hipWidth);
    }
  }

  void _drawPart(Canvas canvas, String partName, VoidCallback drawFunc,
      Paint highlightPaint) {
    if (highlightPart == partName) {
      final savedPaint = Paint()..color = highlightPaint.color;
      canvas.save();
      drawFunc();
      canvas.restore();
      // Draw highlight overlay
      canvas.saveLayer(null, savedPaint);
      drawFunc();
      canvas.restore();
    } else {
      drawFunc();
    }
  }

  void _drawMeasurementLabels(Canvas canvas, Size size, double centerX,
      double scale, double sw, double cw, double ww, double hw) {
    final textStyle = TextStyle(
      color: AppColors.gold,
      fontSize: 9 * scale,
      fontWeight: FontWeight.w600,
    );

    void drawLabel(String text, Offset position) {
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, position);
    }

    if (measurement != null) {
      drawLabel('${measurement!.shoulder}cm',
          Offset(centerX + sw + 5 * scale, 85 * scale));
      drawLabel('${measurement!.chest}cm',
          Offset(centerX + cw + 5 * scale, 140 * scale));
      drawLabel('${measurement!.waist}cm',
          Offset(centerX + ww + 5 * scale, 215 * scale));
      drawLabel('${measurement!.hips}cm',
          Offset(centerX + hw + 5 * scale, 265 * scale));
    }
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return oldDelegate.highlightPart != highlightPart ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotationY != rotationY;
  }
}
