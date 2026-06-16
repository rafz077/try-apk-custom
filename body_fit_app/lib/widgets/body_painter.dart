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
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A3A2A), Color(0xFF0D2818)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.threed_rotation, color: AppColors.primary, size: 15),
              SizedBox(width: 6),
              Text('3D Body Scan',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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
                  painter: HumanBodyPainter(
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

class HumanBodyPainter extends CustomPainter {
  final BodyMeasurement? measurement;
  final String? highlightPart;
  final double pulseValue;
  final double rotationY;

  HumanBodyPainter({this.measurement, this.highlightPart, this.pulseValue = 1.0, this.rotationY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.height / 480;
    final depthOffset = sin(rotationY) * 12;

    double shoulderW = 70 * scale;
    double chestW = 60 * scale;
    double waistW = 48 * scale;
    double hipW = 56 * scale;

    if (measurement != null) {
      shoulderW = (measurement!.shoulder / 2.5) * scale;
      chestW = (measurement!.chest / 3.5) * scale;
      waistW = (measurement!.waist / 3.5) * scale;
      hipW = (measurement!.hips / 3.5) * scale;
    }

    // Background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.06 * pulseValue),
          AppColors.primary.withOpacity(0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, size.height * 0.45),
        width: size.width,
        height: size.height,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.height * 0.45), width: shoulderW * 3, height: size.height * 0.75),
      glowPaint,
    );

    // 3D depth shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + depthOffset * 1.5, size.height * 0.48), width: shoulderW * 1.6, height: size.height * 0.55),
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Skin gradient
    final skinGradient = LinearGradient(
      colors: [
        AppColors.primary.withOpacity(0.35),
        AppColors.primary.withOpacity(0.18),
        const Color(0xFF00806A).withOpacity(0.25),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final bodyFill = Paint()..shader = skinGradient;
    final bodyOutline = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final highlightFill = Paint()
      ..color = AppColors.gold.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final contourPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // --- HEAD ---
    _drawPart(canvas, 'head', () {
      final headCx = centerX;
      final headCy = 32 * scale;
      final headRx = 22 * scale;
      final headRy = 26 * scale;

      canvas.drawOval(Rect.fromCenter(center: Offset(headCx, headCy - 3 * scale), width: headRx * 2.15, height: headRy * 2.1),
          Paint()..color = AppColors.primary.withOpacity(0.12));

      canvas.drawOval(Rect.fromCenter(center: Offset(headCx, headCy), width: headRx * 2, height: headRy * 2), bodyFill);
      canvas.drawOval(Rect.fromCenter(center: Offset(headCx, headCy), width: headRx * 2, height: headRy * 2), bodyOutline);

      final facePaint = Paint()..color = AppColors.primary.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(headCx - 7 * scale, headCy - 2 * scale), width: 5 * scale, height: 3 * scale), facePaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(headCx + 7 * scale, headCy - 2 * scale), width: 5 * scale, height: 3 * scale), facePaint);
      canvas.drawLine(Offset(headCx, headCy + 2 * scale), Offset(headCx, headCy + 7 * scale), facePaint);
      final mouthPath = Path()
        ..moveTo(headCx - 5 * scale, headCy + 11 * scale)
        ..quadraticBezierTo(headCx, headCy + 14 * scale, headCx + 5 * scale, headCy + 11 * scale);
      canvas.drawPath(mouthPath, facePaint);
    }, highlightFill);

    // --- NECK ---
    _drawPart(canvas, 'neck', () {
      final neckPath = Path()
        ..moveTo(centerX - 9 * scale, 58 * scale)
        ..quadraticBezierTo(centerX - 10 * scale, 72 * scale, centerX - 12 * scale, 82 * scale)
        ..lineTo(centerX + 12 * scale, 82 * scale)
        ..quadraticBezierTo(centerX + 10 * scale, 72 * scale, centerX + 9 * scale, 58 * scale)
        ..close();
      canvas.drawPath(neckPath, bodyFill);
      canvas.drawPath(neckPath, bodyOutline);
      canvas.drawLine(Offset(centerX - 4 * scale, 62 * scale), Offset(centerX - 6 * scale, 78 * scale), contourPaint);
      canvas.drawLine(Offset(centerX + 4 * scale, 62 * scale), Offset(centerX + 6 * scale, 78 * scale), contourPaint);
    }, highlightFill);

    // --- TORSO ---
    _drawPart(canvas, 'chest', () {
      final torsoPath = Path()
        ..moveTo(centerX - 12 * scale, 82 * scale)
        ..quadraticBezierTo(centerX - shoulderW * 0.7, 78 * scale, centerX - shoulderW, 88 * scale)
        ..quadraticBezierTo(centerX - shoulderW * 0.95, 110 * scale, centerX - chestW, 145 * scale)
        ..quadraticBezierTo(centerX - chestW * 0.95, 175 * scale, centerX - waistW, 215 * scale)
        ..lineTo(centerX + waistW, 215 * scale)
        ..quadraticBezierTo(centerX + chestW * 0.95, 175 * scale, centerX + chestW, 145 * scale)
        ..quadraticBezierTo(centerX + shoulderW * 0.95, 110 * scale, centerX + shoulderW, 88 * scale)
        ..quadraticBezierTo(centerX + shoulderW * 0.7, 78 * scale, centerX + 12 * scale, 82 * scale)
        ..close();
      canvas.drawPath(torsoPath, bodyFill);
      canvas.drawPath(torsoPath, bodyOutline);

      final pecLeftPath = Path()
        ..moveTo(centerX - 5 * scale, 95 * scale)
        ..quadraticBezierTo(centerX - chestW * 0.6, 105 * scale, centerX - chestW * 0.7, 120 * scale);
      canvas.drawPath(pecLeftPath, contourPaint);

      final pecRightPath = Path()
        ..moveTo(centerX + 5 * scale, 95 * scale)
        ..quadraticBezierTo(centerX + chestW * 0.6, 105 * scale, centerX + chestW * 0.7, 120 * scale);
      canvas.drawPath(pecRightPath, contourPaint);

      canvas.drawLine(Offset(centerX, 92 * scale), Offset(centerX, 210 * scale), contourPaint);

      for (var y = 140.0; y < 200; y += 20) {
        canvas.drawLine(
          Offset(centerX - waistW * 0.5, y * scale),
          Offset(centerX + waistW * 0.5, y * scale),
          contourPaint,
        );
      }
    }, highlightFill);

    // --- HIPS ---
    _drawPart(canvas, 'hips', () {
      final hipsPath = Path()
        ..moveTo(centerX - waistW, 215 * scale)
        ..quadraticBezierTo(centerX - hipW * 1.05, 235 * scale, centerX - hipW, 260 * scale)
        ..lineTo(centerX - hipW * 0.55, 275 * scale)
        ..lineTo(centerX + hipW * 0.55, 275 * scale)
        ..lineTo(centerX + hipW, 260 * scale)
        ..quadraticBezierTo(centerX + hipW * 1.05, 235 * scale, centerX + waistW, 215 * scale)
        ..close();
      canvas.drawPath(hipsPath, bodyFill);
      canvas.drawPath(hipsPath, bodyOutline);
      canvas.drawLine(Offset(centerX, 218 * scale), Offset(centerX, 270 * scale), contourPaint);
    }, highlightFill);

    // --- ARMS ---
    _drawPart(canvas, 'arm', () {
      final leftArmPath = Path()
        ..moveTo(centerX - shoulderW, 88 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 12 * scale, 95 * scale, centerX - shoulderW - 16 * scale, 130 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 18 * scale, 160 * scale, centerX - shoulderW - 14 * scale, 195 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 12 * scale, 210 * scale, centerX - shoulderW - 10 * scale, 215 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 4 * scale, 210 * scale, centerX - shoulderW - 2 * scale, 195 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 1 * scale, 160 * scale, centerX - shoulderW + 2 * scale, 130 * scale)
        ..quadraticBezierTo(centerX - shoulderW + 1 * scale, 100 * scale, centerX - shoulderW + 5 * scale, 92 * scale)
        ..close();
      canvas.drawPath(leftArmPath, bodyFill);
      canvas.drawPath(leftArmPath, bodyOutline);

      final lBicep = Path()
        ..moveTo(centerX - shoulderW - 6 * scale, 110 * scale)
        ..quadraticBezierTo(centerX - shoulderW - 10 * scale, 135 * scale, centerX - shoulderW - 8 * scale, 155 * scale);
      canvas.drawPath(lBicep, contourPaint);

      final rightArmPath = Path()
        ..moveTo(centerX + shoulderW, 88 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 12 * scale, 95 * scale, centerX + shoulderW + 16 * scale, 130 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 18 * scale, 160 * scale, centerX + shoulderW + 14 * scale, 195 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 12 * scale, 210 * scale, centerX + shoulderW + 10 * scale, 215 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 4 * scale, 210 * scale, centerX + shoulderW + 2 * scale, 195 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 1 * scale, 160 * scale, centerX + shoulderW - 2 * scale, 130 * scale)
        ..quadraticBezierTo(centerX + shoulderW - 1 * scale, 100 * scale, centerX + shoulderW - 5 * scale, 92 * scale)
        ..close();
      canvas.drawPath(rightArmPath, bodyFill);
      canvas.drawPath(rightArmPath, bodyOutline);

      final rBicep = Path()
        ..moveTo(centerX + shoulderW + 6 * scale, 110 * scale)
        ..quadraticBezierTo(centerX + shoulderW + 10 * scale, 135 * scale, centerX + shoulderW + 8 * scale, 155 * scale);
      canvas.drawPath(rBicep, contourPaint);
    }, highlightFill);

    // --- LEGS ---
    _drawPart(canvas, 'leg', () {
      final legInnerX = hipW * 0.55;
      final legOuterX = hipW * 0.95;

      final leftLegPath = Path()
        ..moveTo(centerX - legInnerX, 275 * scale)
        ..lineTo(centerX - legOuterX, 275 * scale)
        ..quadraticBezierTo(centerX - legOuterX * 1.05, 320 * scale, centerX - legOuterX * 0.85, 360 * scale)
        ..quadraticBezierTo(centerX - legOuterX * 0.8, 375 * scale, centerX - legOuterX * 0.75, 390 * scale)
        ..quadraticBezierTo(centerX - legOuterX * 0.7, 410 * scale, centerX - legOuterX * 0.55, 430 * scale)
        ..lineTo(centerX - legInnerX * 0.6, 430 * scale)
        ..quadraticBezierTo(centerX - legInnerX * 0.65, 410 * scale, centerX - legInnerX * 0.7, 390 * scale)
        ..quadraticBezierTo(centerX - legInnerX * 0.75, 370 * scale, centerX - legInnerX * 0.7, 350 * scale)
        ..quadraticBezierTo(centerX - legInnerX * 0.65, 320 * scale, centerX - legInnerX, 275 * scale)
        ..close();
      canvas.drawPath(leftLegPath, bodyFill);
      canvas.drawPath(leftLegPath, bodyOutline);

      final lKnee = Path()
        ..moveTo(centerX - legOuterX * 0.9, 365 * scale)
        ..quadraticBezierTo(centerX - legInnerX * 0.85, 375 * scale, centerX - legInnerX * 0.68, 368 * scale);
      canvas.drawPath(lKnee, contourPaint);

      final rightLegPath = Path()
        ..moveTo(centerX + legInnerX, 275 * scale)
        ..lineTo(centerX + legOuterX, 275 * scale)
        ..quadraticBezierTo(centerX + legOuterX * 1.05, 320 * scale, centerX + legOuterX * 0.85, 360 * scale)
        ..quadraticBezierTo(centerX + legOuterX * 0.8, 375 * scale, centerX + legOuterX * 0.75, 390 * scale)
        ..quadraticBezierTo(centerX + legOuterX * 0.7, 410 * scale, centerX + legOuterX * 0.55, 430 * scale)
        ..lineTo(centerX + legInnerX * 0.6, 430 * scale)
        ..quadraticBezierTo(centerX + legInnerX * 0.65, 410 * scale, centerX + legInnerX * 0.7, 390 * scale)
        ..quadraticBezierTo(centerX + legInnerX * 0.75, 370 * scale, centerX + legInnerX * 0.7, 350 * scale)
        ..quadraticBezierTo(centerX + legInnerX * 0.65, 320 * scale, centerX + legInnerX, 275 * scale)
        ..close();
      canvas.drawPath(rightLegPath, bodyFill);
      canvas.drawPath(rightLegPath, bodyOutline);

      final rKnee = Path()
        ..moveTo(centerX + legOuterX * 0.9, 365 * scale)
        ..quadraticBezierTo(centerX + legInnerX * 0.85, 375 * scale, centerX + legInnerX * 0.68, 368 * scale);
      canvas.drawPath(rKnee, contourPaint);
    }, highlightFill);

    // --- FEET ---
    _drawPart(canvas, 'foot', () {
      final leftFootPath = Path()
        ..moveTo(centerX - hipW * 0.55, 430 * scale)
        ..lineTo(centerX - hipW * 0.75, 430 * scale)
        ..quadraticBezierTo(centerX - hipW * 0.85, 432 * scale, centerX - hipW * 0.85, 438 * scale)
        ..quadraticBezierTo(centerX - hipW * 0.85, 445 * scale, centerX - hipW * 0.6, 446 * scale)
        ..lineTo(centerX - hipW * 0.35, 446 * scale)
        ..quadraticBezierTo(centerX - hipW * 0.3, 440 * scale, centerX - hipW * 0.35, 434 * scale)
        ..close();
      canvas.drawPath(leftFootPath, bodyFill);
      canvas.drawPath(leftFootPath, bodyOutline);

      final rightFootPath = Path()
        ..moveTo(centerX + hipW * 0.55, 430 * scale)
        ..lineTo(centerX + hipW * 0.75, 430 * scale)
        ..quadraticBezierTo(centerX + hipW * 0.85, 432 * scale, centerX + hipW * 0.85, 438 * scale)
        ..quadraticBezierTo(centerX + hipW * 0.85, 445 * scale, centerX + hipW * 0.6, 446 * scale)
        ..lineTo(centerX + hipW * 0.35, 446 * scale)
        ..quadraticBezierTo(centerX + hipW * 0.3, 440 * scale, centerX + hipW * 0.35, 434 * scale)
        ..close();
      canvas.drawPath(rightFootPath, bodyFill);
      canvas.drawPath(rightFootPath, bodyOutline);
    }, highlightFill);

    if (measurement != null) {
      _drawMeasurementLabels(canvas, size, centerX, scale, shoulderW, chestW, waistW, hipW);
    }
  }

  void _drawPart(Canvas canvas, String partName, VoidCallback drawFunc, Paint highlightPaint) {
    if (highlightPart == partName) {
      drawFunc();
      canvas.saveLayer(null, highlightPaint);
      drawFunc();
      canvas.restore();
    } else {
      drawFunc();
    }
  }

  void _drawMeasurementLabels(Canvas canvas, Size size, double centerX,
      double scale, double sw, double cw, double ww, double hw) {
    final labelBg = Paint()
      ..color = const Color(0xFF1A1A2E).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    void drawLabel(String text, Offset position) {
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(color: AppColors.gold, fontSize: 9 * scale, fontWeight: FontWeight.w600),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx - 3, position.dy - 2, textPainter.width + 6, textPainter.height + 4),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, labelBg);

      final lineStart = Offset(position.dx - 3, position.dy + textPainter.height / 2);
      final lineEnd = Offset(centerX + sw - 5, position.dy + textPainter.height / 2);
      canvas.drawLine(lineStart, lineEnd, Paint()
        ..color = AppColors.gold.withOpacity(0.3)
        ..strokeWidth = 0.8);

      textPainter.paint(canvas, position);
    }

    if (measurement != null) {
      drawLabel('${measurement!.shoulder}cm', Offset(centerX + sw + 8 * scale, 85 * scale));
      drawLabel('${measurement!.chest}cm', Offset(centerX + cw + 8 * scale, 140 * scale));
      drawLabel('${measurement!.waist}cm', Offset(centerX + ww + 8 * scale, 215 * scale));
      drawLabel('${measurement!.hips}cm', Offset(centerX + hw + 8 * scale, 260 * scale));
    }
  }

  @override
  bool shouldRepaint(covariant HumanBodyPainter oldDelegate) {
    return oldDelegate.highlightPart != highlightPart ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotationY != rotationY;
  }
}
