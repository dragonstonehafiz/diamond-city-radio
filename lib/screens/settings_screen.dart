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
  static const double _desktopBreakpoint = 1000;

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PipBoySettingsNotifier>();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return _buildDesktopLayout(context, settings);
        }
        return _buildMobileLayout(context, settings);
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    PipBoySettingsNotifier settings,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDisplayColorPanel(settings),
            const SizedBox(height: PipBoyConstants.spacingL),
            _buildVisualPanel(settings),
            const SizedBox(height: PipBoyConstants.spacingL),
            _buildAudioPanel(context, settings),
            const SizedBox(height: PipBoyConstants.spacingL),
            _buildAboutPanel(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    PipBoySettingsNotifier settings,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PipBoyConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDisplayColorPanel(settings),
            const SizedBox(height: PipBoyConstants.spacingL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildVisualPanel(settings),
                      const SizedBox(height: PipBoyConstants.spacingL),
                      _buildAboutPanel(settings),
                    ],
                  ),
                ),
                const SizedBox(width: PipBoyConstants.spacingL),
                Expanded(
                  flex: 7,
                  child: _buildAudioPanel(context, settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayColorPanel(PipBoySettingsNotifier settings) {
    return PipBoyPanel(
      title: 'DISPLAY COLOR',
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PipBoyConstants.spacingM),
        child: Row(
          children: [
            for (final color in PipBoySettingsNotifier.presets)
              Expanded(
                child: Center(
                  child: _ColorPreset(
                    color: color,
                    isSelected: color.toARGB32() == settings.accent.toARGB32(),
                    onTap: () => settings.setAccent(color),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualPanel(PipBoySettingsNotifier settings) {
    return PipBoyPanel(
      title: 'VISUAL',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PipBoyConstants.spacingS),
        child: Column(
          children: [
            Row(
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
                  width: 80,
                  onPressed: () {
                    settings.setScanlinesEnabled(!settings.scanlinesEnabled);
                  },
                ),
              ],
            ),
            const SizedBox(height: PipBoyConstants.spacingM),
            _buildScanlineControl(
              label: 'SCANLINE WIDTH',
              accent: settings.accent,
              min: PipBoySettingsNotifier.minScanlineWidth,
              max: PipBoySettingsNotifier.maxScanlineWidth,
              value: settings.scanlineWidth,
              onChanged: settings.setScanlineWidth,
            ),
            const SizedBox(height: PipBoyConstants.spacingM),
            _buildScanlineControl(
              label: 'SCANLINE DISTANCE',
              accent: settings.accent,
              min: PipBoySettingsNotifier.minScanlineDistance,
              max: PipBoySettingsNotifier.maxScanlineDistance,
              value: settings.scanlineDistance,
              onChanged: settings.setScanlineDistance,
            ),
            const SizedBox(height: PipBoyConstants.spacingM),
            _buildScanlineControl(
              label: 'SCAN SPEED',
              accent: settings.accent,
              min: PipBoySettingsNotifier.minScanlineSpeed,
              max: PipBoySettingsNotifier.maxScanlineSpeed,
              value: settings.scanlineSpeed,
              onChanged: settings.setScanlineSpeed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPanel(
    BuildContext context,
    PipBoySettingsNotifier settings,
  ) {
    return PipBoyPanel(
      title: 'AUDIO',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: PipBoyConstants.spacingS),
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
                  width: 80,
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
          _buildVolumeControl(
            label: 'SFX VOLUME',
            accent: settings.accent,
            value: settings.sfxVolume,
            onChanged: (newValue) {
              settings.setSfxVolume(newValue);
              SfxPlayer().setVolume(newValue);
            },
          ),
          const SizedBox(height: PipBoyConstants.spacingM),
          _buildVolumeControl(
            label: 'HUM VOLUME',
            accent: settings.accent,
            value: settings.humVolume,
            onChanged: (newValue) {
              settings.setHumVolume(newValue);
              SfxPlayer().setHumVolume(newValue);
            },
          ),
          const SizedBox(height: PipBoyConstants.spacingM),
          _buildVolumeControl(
            label: 'AUDIO VOLUME',
            accent: settings.accent,
            value: settings.mainVolume,
            onChanged: (newValue) {
              settings.setMainVolume(newValue);
              context.read<RadioPlayerService>().setVolume(newValue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl({
    required String label,
    required Color accent,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: PipBoyTypography.body(accent),
        ),
        const SizedBox(height: PipBoyConstants.spacingS),
        PipBoyProgressBar(
          value: value,
          interactive: true,
          onSeek: onChanged,
          onSeekEnd: () {
            SfxPlayer().play(PipBoySfx.mapRollover);
          },
        ),
      ],
    );
  }

  Widget _buildScanlineControl({
    required String label,
    required Color accent,
    required double min,
    required double max,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final normalizedValue = _normalize(value, min, max);
    return Column(
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: PipBoyTypography.body(accent),
        ),
        const SizedBox(height: PipBoyConstants.spacingS),
        PipBoyProgressBar(
          value: normalizedValue,
          leftLabel: min.toStringAsFixed(1),
          rightLabel: max.toStringAsFixed(1),
          interactive: true,
          onSeek: (seekValue) {
            onChanged(_denormalize(seekValue, min, max));
          },
          onSeekEnd: () {
            SfxPlayer().play(PipBoySfx.mapRollover);
          },
        ),
      ],
    );
  }

  double _normalize(double value, double min, double max) {
    if (max <= min) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  double _denormalize(double normalizedValue, double min, double max) {
    final clamped = normalizedValue.clamp(0.0, 1.0);
    return min + ((max - min) * clamped);
  }

  Widget _buildAboutPanel(PipBoySettingsNotifier settings) {
    return PipBoyPanel(
      title: 'ABOUT',
      width: double.infinity,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
