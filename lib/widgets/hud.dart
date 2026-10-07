import 'package:flutter/material.dart';

import '../game_theme.dart';
import 'outlined_text.dart';

/// A chunky button that physically sinks into its base when pressed.
class PushButton extends StatefulWidget {
  const PushButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = GamePalette.gold,
    this.depth = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    this.semanticLabel,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double depth;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  State<PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    final depth = widget.depth;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) {
            _setPressed(false);
            widget.onPressed();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: shade(widget.color, 0.25),
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_pressed ? 60 : 110),
                  offset: Offset(0, _pressed ? 2 : 6),
                  blurRadius: _pressed ? 4 : 10,
                ),
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              margin: EdgeInsets.only(
                top: _pressed ? depth : 0,
                bottom: _pressed ? 0 : depth,
              ),
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: tint(widget.color, 0.2), width: 1.5),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tint(widget.color, 0.12), widget.color],
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A raised HUD panel showing a labelled number. When the value goes up, a
/// "+N" bubble floats out of the panel.
class ScorePanel extends StatefulWidget {
  const ScorePanel({
    super.key,
    required this.label,
    required this.value,
    this.showGain = false,
  });

  final String label;
  final int value;
  final bool showGain;

  @override
  State<ScorePanel> createState() => _ScorePanelState();
}

class _ScorePanelState extends State<ScorePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gainController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  int _gain = 0;

  @override
  void didUpdateWidget(covariant ScorePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showGain && widget.value > oldWidget.value) {
      _gain = widget.value - oldWidget.value;
      _gainController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _gainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 84),
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tint(GamePalette.panel, 0.08), GamePalette.panel],
            ),
            boxShadow: [
              const BoxShadow(
                color: GamePalette.panelEdge,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(100),
                offset: const Offset(0, 9),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: const TextStyle(
                  color: GamePalette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: GamePalette.panelEdge, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _gainController,
          builder: (context, child) {
            final t = _gainController.value;
            if (!_gainController.isAnimating) return const SizedBox.shrink();
            return Positioned(
              top: -6 - 34 * Curves.easeOut.transform(t),
              child: IgnorePointer(
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: OutlinedText(
                    '+$_gain',
                    fontSize: 20,
                    fillColor: GamePalette.gold,
                    outlineColor: const Color(0xFF7A4A00),
                    extrude: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The big extruded "2048" logo.
class GameLogo extends StatelessWidget {
  const GameLogo({super.key, this.fontSize = 56});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return OutlinedText(
      '2048',
      fontSize: fontSize,
      outlineColor: const Color(0xFF8A3B00),
      fillGradient: const [Color(0xFFFFF3A8), Color(0xFFFFC93C), Color(0xFFFF8A00)],
      extrude: fontSize * 0.1,
      letterSpacing: 1,
    );
  }
}

/// Night-sky gradient backdrop with a few soft glowing orbs.
class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GamePalette.backgroundTop, GamePalette.backgroundBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _Orb(alignment: Alignment(-1.2, -0.9), color: Color(0xFF7B5CFF), size: 340),
          const _Orb(alignment: Alignment(1.3, -0.2), color: Color(0xFFFF4FA3), size: 280),
          const _Orb(alignment: Alignment(-0.6, 1.2), color: Color(0xFF2BC4E8), size: 320),
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withAlpha(70), color.withAlpha(0)],
            ),
          ),
        ),
      ),
    );
  }
}
