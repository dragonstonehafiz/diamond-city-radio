import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';
import '../audio/sfx_player.dart';
import '../audio/radio_player_service.dart';
import '../widgets/pip_boy_button.dart';
import '../widgets/pip_boy_panel.dart';
import '../widgets/pip_boy_progress_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();

    return Listener(
      child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: Column(
          children: [
            // Display color panel
            PipBoyPanel(
              title: 'DISPLAY COLOR',
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PipBoyConstants.spacingM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final color in PipBoySettingsNotifier.presets)
                      _ColorPreset(
                        color: color,
                        isSelected: color.toARGB32() == settings.accent.toARGB32(),
                        onTap: () {
                          settings.setAccent(color);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // UI options panel
            PipBoyPanel(
              title: 'UI OPTIONS',
              child: Column(
                children: [
                  // Scanlines toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: PipBoyConstants.spacingS,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SCANLINES',
                            style: PipBoyTypography.body(settings.accent),
                          ),
                        ),
                        PipBoyButton(
                          label: settings.scanlinesEnabled ? 'ON' : 'OFF',
                          isActive: settings.scanlinesEnabled,
                          variant: PipBoyButtonVariant.outlined,
                          width: 60,
                          onPressed: () {
                            settings.setScanlinesEnabled(!settings.scanlinesEnabled);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingM),

                  // Ambient hum toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: PipBoyConstants.spacingS,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'AMBIENT HUM',
                            style: PipBoyTypography.body(settings.accent),
                          ),
                        ),
                        PipBoyButton(
                          label: settings.humEnabled ? 'ON' : 'OFF',
                          isActive: settings.humEnabled,
                          variant: PipBoyButtonVariant.outlined,
                          width: 60,
                          onPressed: () async {
                            await settings.setHumEnabled(!settings.humEnabled);
                            if (settings.humEnabled) {
                              await SfxPlayer().playLoop();
                            } else {
                              await SfxPlayer().stopLoop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingM),

                  // SFX volume
                  Text(
                    'SFX VOLUME',
                    style: PipBoyTypography.body(settings.accent),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingS),
                  PipBoyProgressBar(
                    value: settings.sfxVolume,
                    interactive: true,
                    onSeek: (newValue) {
                      settings.setSfxVolume(newValue);
                      SfxPlayer().setVolume(newValue);
                    },
                    onSeekEnd: () {
                      SfxPlayer().play(PipBoySfx.mapRollover);
                    },
                  ),
                  const SizedBox(height: PipBoyConstants.spacingM),

                  // Hum volume
                  Text(
                    'HUM VOLUME',
                    style: PipBoyTypography.body(settings.accent),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingS),
                  PipBoyProgressBar(
                    value: settings.humVolume,
                    interactive: true,
                    onSeek: (newValue) {
                      settings.setHumVolume(newValue);
                      SfxPlayer().setHumVolume(newValue);
                    },
                    onSeekEnd: () {
                      SfxPlayer().play(PipBoySfx.mapRollover);
                    },
                  ),
                  const SizedBox(height: PipBoyConstants.spacingM),

                  // Main audio volume
                  Text(
                    'AUDIO VOLUME',
                    style: PipBoyTypography.body(settings.accent),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingS),
                  PipBoyProgressBar(
                    value: settings.mainVolume,
                    interactive: true,
                    onSeek: (newValue) {
                      settings.setMainVolume(newValue);
                      context.read<RadioPlayerService>().setVolume(newValue);
                    },
                    onSeekEnd: () {
                      SfxPlayer().play(PipBoySfx.mapRollover);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: PipBoyConstants.spacingL),

            // About panel
            PipBoyPanel(
              title: 'ABOUT',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DIAMOND CITY RADIO',
                    style: PipBoyTypography.body(settings.accent),
                  ),
                  const SizedBox(height: PipBoyConstants.spacingS),
                  Text(
                    'Version 1.0.0',
                    style: PipBoyTypography.body(settings.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ColorPreset extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorPreset({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SfxPlayer().play(PipBoySfx.rotaryHorizontal);
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected
              ? Border.all(
                  color: color,
                  width: PipBoyConstants.borderWidthNormal,
                )
              : null,
        ),
      ),
    );
  }
}
