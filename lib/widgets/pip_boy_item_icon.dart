import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_colors.dart';
import '../audio/radio_player_service.dart';
import '../data/report_repository.dart';
import '../models/app_config.dart';

class PipBoyItemIcon extends StatelessWidget {
  final RadioQueueItem item;
  final double size;
  final bool dimmed;

  const PipBoyItemIcon({
    super.key,
    required this.item,
    required this.size,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final config = context.read<AppConfig>();
    final accentColor = dimmed
        ? PipBoyColors.dimmed(settings.accent, factor: 0.6)
        : settings.accent;

    if (item.clipType == RadioClipType.report) {
      final reports = context.read<ReportRepository>();
      final report = reports.getById(item.itemId);
      if (report != null && report.image != null) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size,
            maxHeight: size,
          ),
          child: Image.asset(
            report.image!,
            fit: BoxFit.contain,
            color: accentColor,
            colorBlendMode: BlendMode.srcIn,
          ),
        );
      }
    }

    if (item.clipType == RadioClipType.intro ||
        item.clipType == RadioClipType.outro) {
      final iconPath = item.clipType == RadioClipType.intro
          ? config.introIconPath
          : config.outroIconPath;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size,
          maxHeight: size,
        ),
        child: Image.asset(
          iconPath,
          fit: BoxFit.contain,
          color: accentColor,
          colorBlendMode: BlendMode.srcIn,
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
      ),
      child: Image.asset(
        config.songIconPath,
        fit: BoxFit.contain,
        color: accentColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
