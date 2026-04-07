import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/radio_player_service.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_typography.dart';
import 'pip_boy_button.dart';
import 'pip_boy_divider.dart';
import 'pip_boy_icon.dart';
import 'pip_boy_item_icon.dart';
import 'pip_boy_marquee_text.dart';
import 'pip_boy_panel.dart';
import 'pip_boy_progress_bar.dart';

class PipBoyNowPlayingView extends StatelessWidget {
  final RadioPlayerService player;
  final RadioQueueItem? item;
  final bool showClipBadge;
  final bool showProgressBar;
  final bool showTransportControls;
  final bool framedDisplay;
  final bool squareDisplay;
  final double displayHeight;
  final double? iconSize;
  final double? fallbackIconSize;

  const PipBoyNowPlayingView({
    super.key,
    required this.player,
    this.item,
    this.showClipBadge = true,
    this.showProgressBar = true,
    this.showTransportControls = true,
    this.framedDisplay = true,
    this.squareDisplay = false,
    this.displayHeight = 180,
    this.iconSize,
    this.fallbackIconSize,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final currentItem = item ?? player.currentItem;
    final resolvedIconSize =
        iconSize ?? (displayHeight * 0.78).clamp(120.0, 320.0).toDouble();
    final resolvedFallbackIconSize = fallbackIconSize ?? resolvedIconSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showClipBadge) ...[
          PipBoyPanel(
            outlined: true,
            padding: const EdgeInsets.symmetric(
              horizontal: PipBoyConstants.spacingS,
              vertical: PipBoyConstants.spacingXS,
            ),
            child: Text(
              currentItem?.clipType.label ?? 'SONG',
              style: PipBoyTypography.body(settings.accent),
            ),
          ),
          const SizedBox(height: PipBoyConstants.spacingL),
        ],
        _buildDisplayArea(
          settings: settings,
          item: currentItem,
          resolvedIconSize: resolvedIconSize,
          resolvedFallbackIconSize: resolvedFallbackIconSize,
        ),
        const SizedBox(height: PipBoyConstants.spacingL),
        _buildTrackInfo(settings, currentItem),
        if (showProgressBar) ...[
          const SizedBox(height: PipBoyConstants.spacingL),
          _buildProgress(),
        ],
        if (showTransportControls) ...[
          const SizedBox(height: PipBoyConstants.spacingL),
          const PipBoyDivider(),
          const SizedBox(height: PipBoyConstants.spacingL),
          _buildTransportControls(),
        ],
      ],
    );
  }

  Widget _buildDisplayArea({
    required PipBoySettingsNotifier settings,
    required RadioQueueItem? item,
    required double resolvedIconSize,
    required double resolvedFallbackIconSize,
  }) {
    Widget iconContent = Center(
      child: item != null
          ? PipBoyItemIcon(item: item, size: resolvedIconSize)
          : PipBoyIcon(icon: Icons.music_note, size: resolvedFallbackIconSize),
    );

    if (squareDisplay) {
      iconContent = LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth.clamp(120.0, displayHeight).toDouble();
          final squareIconSize = (side * 0.82).clamp(96.0, resolvedIconSize).toDouble();
          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: Center(
                child: item != null
                    ? PipBoyItemIcon(item: item, size: squareIconSize)
                    : PipBoyIcon(icon: Icons.music_note, size: resolvedFallbackIconSize),
              ),
            ),
          );
        },
      );
    }

    if (framedDisplay) {
      return PipBoyPanel(
        outlined: true,
        height: displayHeight,
        padding: EdgeInsets.zero,
        child: iconContent,
      );
    }

    return Container(
      height: displayHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: PipBoyColors.dimmed(settings.accent, factor: 0.35),
          width: PipBoyConstants.borderWidthNormal,
        ),
      ),
      child: iconContent,
    );
  }

  Widget _buildTrackInfo(PipBoySettingsNotifier settings, RadioQueueItem? currentItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PipBoyMarqueeText(
          text: currentItem != null ? player.getTrackName(currentItem) : '-',
          style: PipBoyTypography.heading(settings.accent),
          height: 32,
        ),
        const SizedBox(height: PipBoyConstants.spacingS),
        PipBoyMarqueeText(
          text: currentItem != null ? player.getArtist(currentItem) : '-',
          style: PipBoyTypography.subheading(
            PipBoyColors.dimmed(settings.accent, factor: 0.7),
          ),
          height: 24,
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durSnapshot) {
        final duration = durSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnapshot) {
            final position = posSnapshot.data ?? Duration.zero;
            final value = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return PipBoyProgressBar(
              value: value.clamp(0.0, 1.0),
              leftLabel: _formatDuration(position),
              rightLabel: _formatDuration(duration),
              interactive: true,
              onSeek: (seekValue) {
                final seekPosition = Duration(
                  milliseconds: (seekValue * duration.inMilliseconds).toInt(),
                );
                player.seek(seekPosition);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTransportControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PipBoyButton(
          icon: Icons.skip_previous,
          variant: PipBoyButtonVariant.ghost,
          onPressed: player.prev,
        ),
        PipBoyButton(
          icon: player.isPlaying ? Icons.pause : Icons.play_arrow,
          variant: PipBoyButtonVariant.ghost,
          isActive: player.isPlaying,
          onPressed: player.togglePlayPause,
        ),
        PipBoyButton(
          icon: Icons.skip_next,
          variant: PipBoyButtonVariant.ghost,
          onPressed: player.next,
        ),
      ],
    );
  }
}
