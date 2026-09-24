import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.pattern, this.photo, this.dim = 0.55, this.mode = 'dark'});

  final String pattern;
  final String? photo;
  final double dim;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    if (pattern == 'photo') {
      final path = photo;
      if (path == null) return const SizedBox.shrink();
      final media = MediaQuery.of(context);
      final cacheWidth = (media.size.width * media.devicePixelRatio).round();
      return IgnorePointer(
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(path),
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gc.bg.withValues(alpha: dim),
                      gc.bg.withValues(alpha: (dim + 0.18).clamp(0.0, 1.0)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (pattern == 'none') return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BgPainter(pattern: pattern, color: gc.border, mode: mode),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter({required this.pattern, required this.color, required this.mode});

  final String pattern;
  final Color color;
  final String mode;
  static const _gap = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == 'dots') {
      final p = Paint()..color = color.withValues(alpha: 0.5);
      for (double y = _gap; y < size.height; y += _gap) {
        for (double x = _gap; x < size.width; x += _gap) {
          canvas.drawCircle(Offset(x, y), 1.1, p);
        }
      }
    } else if (pattern == 'plaster') {
      _drawPlasterTexture(canvas, size);
    } else {
      final p = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      for (double x = _gap; x < size.width; x += _gap) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (double y = _gap; y < size.height; y += _gap) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
    }
  }

  void _drawPlasterTexture(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Create a subtle plaster-like texture by drawing small, varied strokes
    final randomSeed = color.toARGB32();
    double seed = (size.width + size.height + randomSeed) % 100;
    
    for (double y = 20; y < size.height; y += 30) {
      final noiseX = math.sin(y * 0.1 + seed) * 15 + math.cos(seed * 0.3) * 8;
      final x1 = 15 + noiseX;
      final x2 = size.width - 15 - math.sin(y * 0.15 + seed * 0.7) * 12;
      
      paint.color = color.withValues(alpha: 0.15 + math.sin(seed * 0.5) * 0.1);
      canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
    }
    
    for (double x = 20; x < size.width; x += 35) {
      final noiseY = math.cos(x * 0.08 + seed * 1.2) * 20 + math.sin(seed * 0.9) * 10;
      final y1 = 15 + noiseY;
      final y2 = size.height - 15 - math.cos(x * 0.12 + seed * 0.8) * 15;
      
      paint.color = color.withValues(alpha: 0.12 + math.cos(seed * 0.7) * 0.08);
      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
    
    // Add subtle grain points for texture
    final pointPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    
    for (double i = 0; i < 200; i++) {
      final px = math.sin(i * 0.47 + seed * 0.3) * size.width * 0.4 + size.width * 0.3;
      final py = math.cos(i * 0.53 + seed * 0.7) * size.height * 0.4 + size.height * 0.3;
      canvas.drawCircle(Offset(px, py), 0.3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.pattern != pattern || old.color != color || old.mode != mode;
}
