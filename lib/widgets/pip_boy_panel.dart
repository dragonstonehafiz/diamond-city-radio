import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';

class PipBoyPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsets padding;
  final bool outlined;
  final double? height;
  final double? width;

  const PipBoyPanel({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(PipBoyConstants.spacingM),
    this.outlined = true,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();
    final borderColor = PipBoyColors.dimmed(notifier.accent, factor: 0.35);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: PipBoyColors.backgroundAlt,
        border: outlined
            ? Border.all(
                color: borderColor,
                width: PipBoyConstants.borderWidthNormal,
              )
            : null,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (title == null) {
      return SizedBox(
        height: height,
        width: width,
        child: content,
      );
    }

    // Title overlays the top-left corner, breaking the border
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          content,
          Positioned(
            top: -1,
            left: 8,
            child: Container(
              color: PipBoyColors.backgroundAlt,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title!,
                style: PipBoyTypography.caption(notifier.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
