import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_typography.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_divider.dart';
import '../audio/radio_player_service.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  Widget _buildSetPanel({
    required String title,
    required List<RadioQueueItem> items,
    required Color accentColor,
    required RadioPlayerService playerService,
    int activeIndex = -1,
  }) {
    return Column(
      children: [
        PipBoyPanel(
          title: title,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _QueueItem(
                  item: items[i],
                  isActive: i == activeIndex,
                  accentColor: accentColor,
                  playerService: playerService,
                ),
                if (i < items.length - 1)
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
        const SizedBox(height: PipBoyConstants.spacingL),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final player = context.watch<RadioPlayerService>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: Column(
          children: [
            _buildSetPanel(
              title: 'CURRENT SET',
              items: player.sets[0],
              accentColor: settings.accent,
              playerService: player,
              activeIndex: player.currentIndex,
            ),
            _buildSetPanel(
              title: 'NEXT SET',
              items: player.sets[1],
              accentColor: settings.accent,
              playerService: player,
            ),
            _buildSetPanel(
              title: 'NEXT SET',
              items: player.sets[2],
              accentColor: settings.accent,
              playerService: player,
            ),
          ],
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
          Text(
            isActive ? '>' : ' ',
            style: PipBoyTypography.body(displayColor),
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
