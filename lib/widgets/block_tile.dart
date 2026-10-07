import 'package:flutter/material.dart';

import '../game_theme.dart';
import 'outlined_text.dart';

/// A numbered tile drawn as a glossy 3D block.
class BlockTile extends StatelessWidget {
  const BlockTile({super.key, required this.value, required this.size});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = tileColorFor(value);
    final glow = tileGlowFor(value);
    final depth = size * 0.09;
    final radius = BorderRadius.circular(size * 0.16);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Side of the block, peeking out below the face.
          Positioned.fill(
            top: depth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: shade(base, 0.22),
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    offset: Offset(0, depth * 0.7),
                    blurRadius: depth * 1.5,
                  ),
                  if (glow > 0)
                    BoxShadow(
                      color: base.withAlpha((90 + 120 * glow).round()),
                      blurRadius: size * 0.4 * glow,
                      spreadRadius: size * 0.03 * glow,
                    ),
                ],
              ),
            ),
          ),
          // Top face.
          Positioned.fill(
            bottom: depth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: tint(base, 0.18),
                  width: size * 0.02,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tint(base, 0.12), base, shade(base, 0.06)],
                  stops: const [0, 0.55, 1],
                ),
              ),
              child: Stack(
                children: [
                  // Glossy highlight across the top of the face.
                  Positioned(
                    left: size * 0.09,
                    right: size * 0.09,
                    top: size * 0.05,
                    height: size * 0.3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withAlpha(120),
                            Colors.white.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size * 0.08),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          '$value',
                          fontSize: _fontSize,
                          outlineColor: shade(base, 0.32),
                          extrude: size * 0.035,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _fontSize {
    final digits = '$value'.length;
    final scale = switch (digits) {
      1 || 2 => 0.42,
      3 => 0.34,
      4 => 0.27,
      _ => 0.22,
    };
    return size * scale;
  }
}

/// An empty, recessed slot on the board that tiles sit in.
class TileSocket extends StatelessWidget {
  const TileSocket({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.16);
    // A thin lighter lip along the bottom edge sells the inset look.
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.only(bottom: size * 0.025),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: radius,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GamePalette.socketTop, GamePalette.socketBottom],
          ),
        ),
      ),
    );
  }
}
