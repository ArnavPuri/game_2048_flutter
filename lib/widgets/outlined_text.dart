import 'package:flutter/material.dart';

/// Chunky "cartoon" text: a solid fill over a thick outline, with the outline
/// extruded downwards to give the lettering some depth.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.outlineColor,
    this.fillColor = Colors.white,
    this.fillGradient,
    this.extrude = 0,
    this.letterSpacing = 0,
  });

  final String text;
  final double fontSize;
  final Color outlineColor;
  final Color fillColor;

  /// Optional vertical gradient for the fill; overrides [fillColor].
  final List<Color>? fillGradient;

  /// How far (in logical pixels) the outline is stacked downwards.
  final double extrude;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    final strokeWidth = fontSize * 0.14;
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing,
      height: 1.0,
    );

    final steps = extrude.ceil();
    final outline = Text(
      text,
      style: baseStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round
          ..color = outlineColor,
        shadows: [
          for (var i = 1; i <= steps; i++)
            Shadow(color: outlineColor, offset: Offset(0, i.toDouble())),
          if (steps > 0)
            Shadow(
              color: Colors.black.withAlpha(90),
              offset: Offset(0, extrude + 2),
              blurRadius: extrude + 2,
            ),
        ],
      ),
    );

    Widget fill = Text(text, style: baseStyle.copyWith(color: fillColor));
    final gradient = fillGradient;
    if (gradient != null) {
      fill = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ).createShader(bounds),
        child: fill,
      );
    }

    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2),
      child: Stack(alignment: Alignment.center, children: [outline, fill]),
    );
  }
}
