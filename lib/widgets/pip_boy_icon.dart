import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';

class PipBoyIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool dimmed;
  final bool disabled;

  const PipBoyIcon({
    super.key,
    required this.icon,
    this.size = 20.0,
    this.dimmed = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();
    Color color;

    if (disabled) {
      color = notifier.muted;
    } else if (dimmed) {
      color = notifier.dim;
    } else {
      color = notifier.accent;
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
