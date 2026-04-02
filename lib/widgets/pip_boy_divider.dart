import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';

class PipBoyDivider extends StatelessWidget {
  final Axis axis;
  final double? extent;
  final double thickness;
  final EdgeInsets margin;

  const PipBoyDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.extent,
    this.thickness = PipBoyConstants.borderWidthThin,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();
    final borderColor = PipBoyColors.dimmed(notifier.accent, factor: 0.35);

    if (axis == Axis.horizontal) {
      return Padding(
        padding: margin,
        child: Container(
          height: thickness,
          width: extent,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: thickness,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: margin,
        child: Container(
          width: thickness,
          height: extent,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: borderColor,
                width: thickness,
              ),
            ),
          ),
        ),
      );
    }
  }
}
