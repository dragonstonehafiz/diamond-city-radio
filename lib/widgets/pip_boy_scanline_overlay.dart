import 'package:flutter/material.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_constants.dart';

class PipBoyScanlineOverlay extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const PipBoyScanlineOverlay({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ScanlinePainter(),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PipBoyColors.scanlineColor
      ..strokeWidth = PipBoyConstants.scanlineThickness;

    final spacing = PipBoyConstants.scanlineSpacing;

    // Draw horizontal lines across the entire canvas
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
