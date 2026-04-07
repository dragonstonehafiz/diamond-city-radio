import 'package:flutter/material.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_constants.dart';

class PipBoyScanlineOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double lineWidth;
  final double lineSpacing;
  final double scanSpeed;

  const PipBoyScanlineOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.lineWidth = PipBoyConstants.scanlineThickness,
    this.lineSpacing = PipBoyConstants.scanlineSpacing,
    this.scanSpeed = 24.0,
  });

  @override
  State<PipBoyScanlineOverlay> createState() => _PipBoyScanlineOverlayState();
}

class _PipBoyScanlineOverlayState extends State<PipBoyScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PipBoyScanlineOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.lineSpacing != widget.lineSpacing ||
        oldWidget.scanSpeed != widget.scanSpeed) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (!widget.enabled) {
      _controller.stop();
      return;
    }

    final speed = widget.scanSpeed.clamp(0.0, 1000.0);
    if (speed <= 0.0) {
      _controller.stop();
      _controller.value = 0.0;
      return;
    }

    final spacing = widget.lineSpacing.clamp(1.0, 200.0);
    final durationMs = ((spacing / speed) * 1000)
        .clamp(120.0, 2500.0)
        .round();
    _controller.repeat(
      period: Duration(milliseconds: durationMs),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _ScanlinePainter(
                  lineWidth: widget.lineWidth,
                  lineSpacing: widget.lineSpacing,
                  phase: _controller.value * widget.lineSpacing,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double lineWidth;
  final double lineSpacing;
  final double phase;

  const _ScanlinePainter({
    required this.lineWidth,
    required this.lineSpacing,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PipBoyColors.scanlineColor
      ..strokeWidth = lineWidth;

    // Draw horizontal lines across the entire canvas with animated offset.
    for (double y = -lineSpacing + phase; y < size.height + lineSpacing; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.lineWidth != lineWidth ||
      oldDelegate.lineSpacing != lineSpacing ||
      oldDelegate.phase != phase;
}
