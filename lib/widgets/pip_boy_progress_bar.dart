import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';

class PipBoyProgressBar extends StatefulWidget {
  final double value;
  final String? leftLabel;
  final String? rightLabel;
  final bool interactive;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onSeekEnd;

  const PipBoyProgressBar({
    super.key,
    required this.value,
    this.leftLabel,
    this.rightLabel,
    this.interactive = false,
    this.onSeek,
    this.onSeekEnd,
  });

  @override
  State<PipBoyProgressBar> createState() => _PipBoyProgressBarState();
}

class _PipBoyProgressBarState extends State<PipBoyProgressBar> {
  void _handleHorizontalDragStart(DragStartDetails details) {
    if (!widget.interactive) return;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.interactive || widget.onSeek == null) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final newValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    widget.onSeek!(newValue);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!widget.interactive) return;
    widget.onSeekEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart:
          widget.interactive ? _handleHorizontalDragStart : null,
      onHorizontalDragUpdate:
          widget.interactive ? _handleHorizontalDragUpdate : null,
      onHorizontalDragEnd:
          widget.interactive ? _handleHorizontalDragEnd : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SizedBox(
            height: PipBoyConstants.progressBarHeight,
            child: CustomPaint(
              painter: _ProgressBarPainter(
                value: widget.value,
                accentColor: notifier.accent,
                accentDim: notifier.dim,
              ),
              size: Size.infinite,
            ),
          ),
          // Labels
          if (widget.leftLabel != null || widget.rightLabel != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.leftLabel != null)
                  Text(
                    widget.leftLabel!,
                    style: PipBoyTypography.caption(notifier.accent),
                  )
                else
                  const SizedBox.shrink(),
                if (widget.rightLabel != null)
                  Text(
                    widget.rightLabel!,
                    style: PipBoyTypography.caption(notifier.accent),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double value;
  final Color accentColor;
  final Color accentDim;

  _ProgressBarPainter({
    required this.value,
    required this.accentColor,
    required this.accentDim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const borderWidth = 1.0;
    const cursorWidth = 3.0;
    const bracketWidth = 8.0;

    final height = size.height;
    final width = size.width;

    // Background track with border
    final trackRect = Rect.fromLTWH(bracketWidth, 0, width - 2 * bracketWidth, height);
    canvas.drawRect(
      trackRect,
      Paint()
        ..color = accentDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Filled portion
    final filledWidth = (width - 2 * bracketWidth) * value;
    final filledRect = Rect.fromLTWH(bracketWidth, 0, filledWidth, height);
    canvas.drawRect(
      filledRect,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill,
    );

    // Position cursor (vertical tick)
    final cursorX = bracketWidth + filledWidth;
    canvas.drawRect(
      Rect.fromLTWH(cursorX - cursorWidth / 2, 0, cursorWidth, height),
      Paint()..color = accentColor,
    );

    // Left bracket
    final leftBracketPath = Path()
      ..moveTo(4, 0)
      ..lineTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(4, height);
    canvas.drawPath(
      leftBracketPath,
      Paint()
        ..color = accentDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Right bracket
    final rightBracketPath = Path()
      ..moveTo(width - 4, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..lineTo(width - 4, height);
    canvas.drawPath(
      rightBracketPath,
      Paint()
        ..color = accentDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.accentDim != accentDim;
}
