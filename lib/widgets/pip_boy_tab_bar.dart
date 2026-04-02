import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/pip_boy_settings_notifier.dart';
import '../theme/pip_boy_constants.dart';
import '../theme/pip_boy_typography.dart';
import '../audio/sfx_player.dart';
import 'pip_boy_divider.dart';

class PipBoyTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isSubBar;

  const PipBoyTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTabSelected,
    this.isSubBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PipBoySettingsNotifier>();
    final height =
        isSubBar ? PipBoyConstants.subTabBarHeight : PipBoyConstants.tabBarHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < labels.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (i != selectedIndex) {
                        SfxPlayer().play(PipBoySfx.rotaryVertical);
                      }
                      onTabSelected(i);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            labels[i],
                            style: PipBoyTypography.tabLabel(
                              i == selectedIndex ? notifier.accent : notifier.dim,
                            ),
                          ),
                          if (i == selectedIndex)
                            Container(
                              height: PipBoyConstants.borderWidthNormal,
                              width: 60,
                              color: notifier.accent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        PipBoyDivider(
          axis: Axis.horizontal,
          thickness: PipBoyConstants.borderWidthThin,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}
