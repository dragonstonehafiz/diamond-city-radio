import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_colors.dart';
import '../theme/pip_boy_typography.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_divider.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();

    final currentSetItems = [
      ('INTRO', 'Intro Clip'),
      ('SONG', 'Accentuate The Positive'),
      ('SONG', 'Ain\'t Misbehavin\''),
      ('OUTRO', 'Outro Clip'),
      ('REPORT', 'News Report'),
    ];

    final nextSetItems = [
      ('SONG', 'Blue Skies'),
      ('SONG', 'Mr. Sandman'),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: Column(
          children: [
            // Current set
            PipBoyPanel(
              title: 'CURRENT SET',
              child: Column(
                children: [
                  for (int i = 0; i < currentSetItems.length; i++) ...[
                    _QueueItem(
                      type: currentSetItems[i].$1,
                      title: currentSetItems[i].$2,
                      isActive: i == 0,
                      accentColor: notifier.accent,
                    ),
                    if (i < currentSetItems.length - 1)
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

            // Next set
            PipBoyPanel(
              title: 'NEXT SET',
              child: Column(
                children: [
                  for (int i = 0; i < nextSetItems.length; i++) ...[
                    _QueueItem(
                      type: nextSetItems[i].$1,
                      title: nextSetItems[i].$2,
                      isActive: false,
                      accentColor: notifier.accent,
                    ),
                    if (i < nextSetItems.length - 1)
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
          ],
        ),
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final String type;
  final String title;
  final bool isActive;
  final Color accentColor;

  const _QueueItem({
    required this.type,
    required this.title,
    required this.isActive,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isActive
        ? accentColor
        : PipBoyColors.dimmed(accentColor, factor: 0.6);

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
                  type,
                  style: PipBoyTypography.caption(displayColor),
                ),
                Text(
                  title,
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
