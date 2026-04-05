import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_typography.dart';
import '../widgets/pip_boy_button.dart';
import '../widgets/pip_boy_icon.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_progress_bar.dart';
import '../widgets/pip_boy_divider.dart';
import '../widgets/pip_boy_marquee_text.dart';
import '../widgets/pip_boy_item_icon.dart';
import '../audio/radio_player_service.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();
    final player = context.watch<RadioPlayerService>();
    final currentItem = player.currentItem;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clip type badge
            PipBoyPanel(
              outlined: true,
              padding: const EdgeInsets.symmetric(
                horizontal: PipBoyConstants.spacingS,
                vertical: PipBoyConstants.spacingXS,
              ),
              child: Text(
                currentItem?.clipType.label ?? '♪ SONG',
                style: PipBoyTypography.body(settings.accent),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Display image or default icon
            PipBoyPanel(
              outlined: true,
              height: 180,
              padding: EdgeInsets.zero,
              child: Center(
                child: currentItem != null
                    ? PipBoyItemIcon(item: currentItem, size: 150)
                    : PipBoyIcon(icon: Icons.music_note, size: 80),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Track name
            PipBoyMarqueeText(
              text: currentItem != null ? player.getTrackName(currentItem) : '—',
              style: PipBoyTypography.heading(settings.accent),
              height: 32.0,
            ),
            const SizedBox(height: PipBoyConstants.spacingS),

            // Artist
            PipBoyMarqueeText(
              text: currentItem != null ? player.getArtist(currentItem) : '—',
              style: PipBoyTypography.subheading(
                PipBoyColors.dimmed(settings.accent, factor: 0.7),
              ),
              height: 24.0,
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Progress bar
            StreamBuilder<Duration?>(
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
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Divider
            const PipBoyDivider(),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PipBoyButton(
                  icon: Icons.skip_previous,
                  variant: PipBoyButtonVariant.ghost,
                  onPressed: () => player.prev(),
                ),
                PipBoyButton(
                  icon: player.isPlaying ? Icons.pause : Icons.play_arrow,
                  variant: PipBoyButtonVariant.ghost,
                  isActive: player.isPlaying,
                  onPressed: () => player.togglePlayPause(),
                ),
                PipBoyButton(
                  icon: Icons.skip_next,
                  variant: PipBoyButtonVariant.ghost,
                  onPressed: () => player.next(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
