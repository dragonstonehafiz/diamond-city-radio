import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';
import '../utils/sfx_player.dart';
import 'pip_boy_icon.dart';

enum PipBoyButtonVariant { filled, outlined, ghost }

class PipBoyButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final PipBoyButtonVariant variant;
  final double? width;

  const PipBoyButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.isActive = false,
    this.variant = PipBoyButtonVariant.filled,
    this.width,
  });

  @override
  State<PipBoyButton> createState() => _PipBoyButtonState();
}

class _PipBoyButtonState extends State<PipBoyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: PipBoyConstants.tapFeedbackDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;

    SfxPlayer().play(PipBoySfx.rotaryHorizontal);
    widget.onPressed!();

    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();
    final isDisabled = widget.onPressed == null;

    Color contentColor;
    Color backgroundColor;
    Color borderColor;

    if (isDisabled) {
      contentColor = notifier.muted;
      backgroundColor = Colors.transparent;
      borderColor = notifier.muted;
    } else {
      contentColor = widget.isActive ? notifier.accent : notifier.dim;
      backgroundColor = widget.isActive
          ? notifier.accent.withValues(alpha: 0.2)
          : Colors.transparent;
      borderColor = contentColor;
    }

    final textStyle = PipBoyTypography.tabLabel(contentColor);

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          PipBoyIcon(
            icon: widget.icon!,
            size: 20,
            disabled: isDisabled,
          ),
          const SizedBox(width: 8),
        ],
        if (widget.label != null)
          Text(
            widget.label!,
            style: textStyle,
          ),
      ],
    );

    return SizedBox(
      height: PipBoyConstants.buttonHeight,
      width: widget.width,
      child: Listener(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.93)
              .animate(_scaleController),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: widget.variant != PipBoyButtonVariant.ghost
                  ? Border.all(
                      color: borderColor,
                      width: PipBoyConstants.borderWidthNormal,
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: buttonContent,
          ),
        ),
        ),
      ),
    );
  }
}
