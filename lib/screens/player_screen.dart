import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/radio_player_service.dart';
import '../theme/pip_boy_constants.dart';
import '../widgets/pip_boy_now_playing_view.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<RadioPlayerService>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;
        final double horizontalPadding =
            isDesktop ? PipBoyConstants.spacingL : PipBoyConstants.spacingM;
        final double displayHeight = isDesktop
            ? (constraints.maxWidth * 0.33).clamp(240.0, 420.0)
            : 180.0;
        final double iconSize = isDesktop
            ? (displayHeight * 0.78).clamp(170.0, 320.0)
            : 150.0;
        final double fallbackIconSize = isDesktop ? 110.0 : 80.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: PipBoyNowPlayingView(
              player: player,
              displayHeight: displayHeight,
              iconSize: iconSize,
              fallbackIconSize: fallbackIconSize,
              showClipBadge: true,
              showProgressBar: true,
              showTransportControls: true,
              framedDisplay: true,
            ),
          ),
        );
      },
    );
  }
}
