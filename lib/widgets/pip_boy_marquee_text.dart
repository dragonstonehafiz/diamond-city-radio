import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class PipBoyMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double height;

  const PipBoyMarqueeText({
    required this.text,
    required this.style,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // If text fits within available width, show static text
        if (textPainter.width <= constraints.maxWidth) {
          return SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
          );
        }

        // Text overflows, use marquee
        return SizedBox(
          height: height,
          child: Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            blankSpace: 64.0,
            velocity: 40.0,
            pauseAfterRound: Duration(seconds: 2),
            startPadding: 0,
            fadingEdgeStartFraction: 0.0,
            fadingEdgeEndFraction: 0.1,
          ),
        );
      },
    );
  }
}
