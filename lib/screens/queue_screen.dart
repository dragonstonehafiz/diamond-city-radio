import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_typography.dart';
import '../widgets/pip_boy_now_playing_view.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_divider.dart';
import '../widgets/pip_boy_item_icon.dart';
import '../audio/radio_player_service.dart';
import '../audio/sfx_player.dart';

class QueueScreen extends StatelessWidget {
  static const double _desktopBreakpoint = 900;

  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final player = context.watch<RadioPlayerService>();
    final allItems = player.queue;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return _buildDesktopLayout(settings, player, allItems);
        }
        return _buildMobileLayout(settings, player, allItems);
      },
    );
  }

  Widget _buildMobileLayout(
    PipBoySettingsNotifier settings,
    RadioPlayerService player,
    List<RadioQueueItem> allItems,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: PipBoyPanel(
          child: Column(
            children: [
              for (int i = 0; i < allItems.length; i++) ...[
                _QueueItem(
                  index: i,
                  item: allItems[i],
                  isActive: i == player.currentIndex,
                  accentColor: settings.accent,
                  playerService: player,
                ),
                if (i < allItems.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: PipBoyConstants.spacingS),
                    child: PipBoyDivider(margin: EdgeInsets.zero),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    PipBoySettingsNotifier settings,
    RadioPlayerService player,
    List<RadioQueueItem> allItems,
  ) {
    final int activeIndex = player.currentIndex;
    final RadioQueueItem? activeItem =
        activeIndex >= 0 && activeIndex < allItems.length ? allItems[activeIndex] : null;

    return Padding(
      padding: const EdgeInsets.all(PipBoyConstants.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 360,
            child: Align(
              alignment: Alignment.topLeft,
              child: activeItem == null
                  ? Text('NO ITEM', style: PipBoyTypography.body(settings.dim))
                  : PipBoyNowPlayingView(
                      player: player,
                      item: activeItem,
                      showClipBadge: false,
                      showProgressBar: true,
                      showTransportControls: true,
                      framedDisplay: true,
                      squareDisplay: true,
                      displayHeight: 250,
                    ),
            ),
          ),
          const SizedBox(width: PipBoyConstants.spacingL),
          Expanded(
            flex: 8,
            child: PipBoyPanel(
              title: 'FULL QUEUE',
              child: allItems.isEmpty
                  ? Text('QUEUE EMPTY', style: PipBoyTypography.body(settings.dim))
                  : ListView.separated(
                      itemCount: allItems.length,
                      separatorBuilder: (_, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: PipBoyConstants.spacingS),
                        child: PipBoyDivider(margin: EdgeInsets.zero),
                      ),
                      itemBuilder: (context, i) {
                        return _QueueItem(
                          index: i,
                          item: allItems[i],
                          isActive: i == player.currentIndex,
                          accentColor: settings.accent,
                          playerService: player,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final int index;
  final RadioQueueItem item;
  final bool isActive;
  final Color accentColor;
  final RadioPlayerService playerService;
  const _QueueItem({
    required this.index,
    required this.item,
    required this.isActive,
    required this.accentColor,
    required this.playerService,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor =
        isActive ? accentColor : PipBoyColors.dimmed(accentColor, factor: 0.6);
    final trackName = playerService.getTrackName(item);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isActive
          ? null
          : () {
              SfxPlayer().play(PipBoySfx.rotaryHorizontal);
              playerService.playQueueItem(index);
            },
      child: Padding(
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
      ),
    );
  }
}
