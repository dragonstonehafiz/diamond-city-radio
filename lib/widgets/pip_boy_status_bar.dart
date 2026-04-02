import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';
import 'pip_boy_divider.dart';

class PipBoyStatusBar extends StatefulWidget {
  final String? customLeftText;
  final String? customRightText;

  const PipBoyStatusBar({
    super.key,
    this.customLeftText,
    this.customRightText,
  });

  @override
  State<PipBoyStatusBar> createState() => _PipBoyStatusBarState();
}

class _PipBoyStatusBarState extends State<PipBoyStatusBar> {
  late Timer _timer;
  late String _timeText;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeText =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();

    final leftText = widget.customLeftText ?? 'DCR v1.0';
    final rightText = widget.customRightText ?? 'PWR: OK';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PipBoyDivider(
          axis: Axis.horizontal,
          thickness: PipBoyConstants.borderWidthThin,
          margin: EdgeInsets.zero,
        ),
        Container(
          height: PipBoyConstants.statusBarHeight,
          color: PipBoyColors.background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftText,
                  style: PipBoyTypography.statusBar(notifier.accent),
                ),
                Text(
                  _timeText,
                  style: PipBoyTypography.statusBar(notifier.accent),
                ),
                Text(
                  rightText,
                  style: PipBoyTypography.statusBar(notifier.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
