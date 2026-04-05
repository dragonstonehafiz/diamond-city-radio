import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_typography.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_divider.dart';
import '../widgets/pip_boy_item_icon.dart';
import '../audio/radio_player_service.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final player = context.watch<RadioPlayerService>();

    final allItems = player.queue;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: PipBoyPanel(
          child: Column(
            children: [
              for (int i = 0; i < allItems.length; i++) ...[
                _QueueItem(
                  item: allItems[i],
                  isActive: i == player.currentIndex,
                  accentColor: settings.accent,
                  playerService: player,
                ),
                if (i < allItems.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: PipBoyConstants.spacingS,
                    ),
                    child: PipBoyDivider(
                      margin: EdgeInsets.zero,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final RadioQueueItem item;
  final bool isActive;
  final Color accentColor;
  final RadioPlayerService playerService;

  const _QueueItem({
    required this.item,
    required this.isActive,
    required this.accentColor,
    required this.playerService,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isActive
        ? accentColor
        : PipBoyColors.dimmed(accentColor, factor: 0.6);
    final trackName = playerService.getTrackName(item);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PipBoyConstants.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: PipBoyItemIcon(item: item, size: 32, dimmed: !isActive),
          ),
          const SizedBox(width: PipBoyConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.clipType.label,
                  style: PipBoyTypography.caption(displayColor),
                ),
                Text(
                  trackName,
                  style: PipBoyTypography.body(displayColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
