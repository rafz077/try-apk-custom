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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) => _handleTap(details, context),
          child: CustomPaint(
            size: const Size(250, 450),
            painter: BodyPainter(
              measurement: widget.measurement,
              highlightPart: _selectedPart ?? widget.highlightPart,
              pulseValue: _pulseAnimation.value,
            ),
          ),
        );
      },
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
    if (position.dy < 60) return 'head';
    if (position.dy < 80) return 'neck';
    if (position.dy < 110) return 'shoulder';
    if (position.dy < 200) {
      if (position.dx < 70 || position.dx > 180) return 'arm';
      return 'chest';
    }
    if (position.dy < 260) return 'waist';
    if (position.dy < 300) return 'hips';
    if (position.dy < 420) return 'leg';
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (size.isNotEmpty) Text(size),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class BodyPainter extends CustomPainter {
  final BodyMeasurement? measurement;
  final String? highlightPart;
  final double pulseValue;

  BodyPainter({this.measurement, this.highlightPart, this.pulseValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.height / 450;

    final bodyPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final highlightPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.15 * pulseValue)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

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
      color: AppColors.textSecondary,
      fontSize: 9 * scale,
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
        oldDelegate.pulseValue != pulseValue;
  }
}
