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

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();

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
                '♪  SONG',
                style: PipBoyTypography.body(notifier.accent),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Vault Boy graphic placeholder
            PipBoyPanel(
              outlined: true,
              height: 180,
              padding: EdgeInsets.zero,
              child: Center(
                child: PipBoyIcon(
                  icon: Icons.radio,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Track name
            Text(
              'Accentuate The Positive',
              style: PipBoyTypography.heading(notifier.accent),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: PipBoyConstants.spacingS),

            // Artist
            Text(
              'Bing Crosby',
              style: PipBoyTypography.subheading(
                PipBoyColors.dimmed(notifier.accent, factor: 0.7),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // Progress bar
            PipBoyProgressBar(
              value: 0.35,
              leftLabel: '0:24',
              rightLabel: '1:08',
              interactive: false,
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
                  onPressed: () {},
                ),
                PipBoyButton(
                  icon: Icons.play_arrow,
                  variant: PipBoyButtonVariant.ghost,
                  isActive: true,
                  onPressed: () {},
                ),
                PipBoyButton(
                  icon: Icons.skip_next,
                  variant: PipBoyButtonVariant.ghost,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
