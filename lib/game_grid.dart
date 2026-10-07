import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_2048/board_controller.dart';

import 'game_theme.dart';
import 'widgets/block_tile.dart';
import 'widgets/hud.dart';
import 'widgets/outlined_text.dart';

/// Fraction of the move animation spent sliding; the rest is the pop.
const double _kSlidePortion = 0.45;

enum _Overlay { none, won, lost }

class GameGrid extends StatefulWidget {
  const GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid>
    with SingleTickerProviderStateMixin {
  final BoardController _boardController = BoardController();
  late final AnimationController _animController;
  _Overlay _overlay = _Overlay.none;
  bool _keepPlaying = false;
  int _best = 0;
  Offset _totalDrag = Offset.zero;

  @override
  void initState() {
    super.initState();
    _boardController.reset();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleMove(MoveDirection direction) {
    if (_overlay != _Overlay.none || _boardController.isGameOver()) return;

    final moved = _boardController.makeMove(direction);
    if (!moved) return;

    if (_boardController.lastMerged.isNotEmpty) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _best = max(_best, _boardController.score);
      if (_boardController.hasWon() && !_keepPlaying) {
        _overlay = _Overlay.won;
      } else if (_boardController.isGameOver()) {
        _overlay = _Overlay.lost;
      }
    });
    _animController.forward(from: 0);
  }

  void _resetGame() {
    setState(() {
      _boardController.reset();
      _overlay = _Overlay.none;
      _keepPlaying = false;
    });
    _animController.forward(from: 0);
  }

  void _continuePlaying() {
    setState(() {
      _keepPlaying = true;
      _overlay = _Overlay.none;
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA =>
        MoveDirection.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD =>
        MoveDirection.right,
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => MoveDirection.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS =>
        MoveDirection.down,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    _handleMove(direction);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = min(constraints.maxWidth, 440.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: boardSize,
                child: Row(
                  children: [
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: GameLogo(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ScorePanel(
                      label: 'Score',
                      value: _boardController.score,
                      showGain: true,
                    ),
                    const SizedBox(width: 10),
                    ScorePanel(label: 'Best', value: _best),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: boardSize,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Moves: ${_boardController.moves}',
                        style: const TextStyle(
                          color: GamePalette.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PushButton(
                      onPressed: _resetGame,
                      semanticLabel: 'New Game',
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              color: Color(0xFF6B3A00), size: 20),
                          SizedBox(width: 4),
                          Text(
                            'NEW GAME',
                            style: TextStyle(
                              color: Color(0xFF6B3A00),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onPanStart: (_) {
                  _totalDrag = Offset.zero;
                },
                onPanUpdate: (details) {
                  _totalDrag += details.delta;
                },
                onPanEnd: (_) {
                  if (_totalDrag.dx.abs() < 10 && _totalDrag.dy.abs() < 10) {
                    return;
                  }
                  if (_totalDrag.dx.abs() > _totalDrag.dy.abs()) {
                    _handleMove(_totalDrag.dx < 0
                        ? MoveDirection.left
                        : MoveDirection.right);
                  } else {
                    _handleMove(_totalDrag.dy < 0
                        ? MoveDirection.up
                        : MoveDirection.down);
                  }
                },
                child: _Board(
                  size: boardSize,
                  controller: _boardController,
                  animation: _animController,
                  overlay: switch (_overlay) {
                    _Overlay.none => null,
                    _Overlay.won => _ResultOverlay(
                        title: 'YOU WIN!',
                        subtitle: 'Score ${_boardController.score}',
                        color: GamePalette.gold,
                        primaryLabel: 'KEEP GOING',
                        onPrimary: _continuePlaying,
                        secondaryLabel: 'NEW GAME',
                        onSecondary: _resetGame,
                      ),
                    _Overlay.lost => _ResultOverlay(
                        title: 'GAME OVER',
                        subtitle: 'Score ${_boardController.score}',
                        color: const Color(0xFFFF5E7A),
                        primaryLabel: 'TRY AGAIN',
                        onPrimary: _resetGame,
                      ),
                  },
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Swipe or use the arrow keys to merge tiles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GamePalette.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The raised tray holding the 4x4 sockets and the animated tiles.
class _Board extends StatelessWidget {
  const _Board({
    required this.size,
    required this.controller,
    required this.animation,
    this.overlay,
  });

  final double size;
  final BoardController controller;
  final Animation<double> animation;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    const border = 2.0;
    final inner = size - border * 2;
    final padding = inner * 0.035;
    final gap = inner * 0.03;
    final cell = (inner - padding * 2 - gap * 3) / 4;
    final radius = BorderRadius.circular(size * 0.06);

    Offset positionOf(Cell c) =>
        Offset(c.$2 * (cell + gap), c.$1 * (cell + gap));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white.withAlpha(45), width: border),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GamePalette.tray, GamePalette.trayDeep],
        ),
        boxShadow: [
          // Solid slab edge underneath the tray.
          const BoxShadow(color: GamePalette.trayEdge, offset: Offset(0, 12)),
          BoxShadow(
            color: Colors.black.withAlpha(140),
            offset: const Offset(0, 22),
            blurRadius: 30,
          ),
          BoxShadow(
            color: const Color(0xFF7B5CFF).withAlpha(60),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var r = 0; r < 4; r++)
                  for (var c = 0; c < 4; c++)
                    Positioned(
                      left: positionOf((r, c)).dx,
                      top: positionOf((r, c)).dy,
                      child: TileSocket(size: cell),
                    ),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: _buildTiles(cell, positionOf),
                  ),
                ),
              ],
            ),
          ),
          if (overlay != null)
            Positioned.fill(
              child: ClipRRect(borderRadius: radius, child: overlay),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles(double cell, Offset Function(Cell) positionOf) {
    final t = animation.value;
    final movements = controller.lastMovements;

    // Phase 1: tiles glide from their old cells to their new ones.
    if (t < _kSlidePortion && movements.isNotEmpty) {
      final p = Curves.easeOutCubic.transform(t / _kSlidePortion);
      return [
        for (final m in movements)
          _positioned(
            Offset.lerp(positionOf(m.from), positionOf(m.to), p)!,
            BlockTile(value: m.value, size: cell),
          ),
      ];
    }

    // Phase 2: settled board; merged tiles bounce, new tiles spring in.
    final p = ((t - _kSlidePortion) / (1 - _kSlidePortion)).clamp(0.0, 1.0);
    final board = controller.currentBoard;
    final tiles = <Widget>[];
    final bursts = <Widget>[];
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final value = board[r][c];
        if (value == 0) continue;
        final cellPos = (r, c);
        final pos = positionOf(cellPos);

        var scale = 1.0;
        if (controller.lastSpawned.contains(cellPos)) {
          scale = Curves.easeOutBack.transform(p);
        } else if (controller.lastMerged.contains(cellPos)) {
          scale = 1 + 0.2 * sin(pi * p);
          if (p < 1) {
            bursts.add(_positioned(
              pos,
              _MergeBurst(progress: p, color: tileColorFor(value), size: cell),
            ));
          }
        }

        tiles.add(_positioned(
          pos,
          Transform.scale(
            scale: scale,
            child: BlockTile(value: value, size: cell),
          ),
        ));
      }
    }
    return [...bursts, ...tiles];
  }

  Widget _positioned(Offset offset, Widget child) {
    return Positioned(left: offset.dx, top: offset.dy, child: child);
  }
}

/// An expanding, fading ring of light behind a freshly merged tile.
class _MergeBurst extends StatelessWidget {
  const _MergeBurst({
    required this.progress,
    required this.color,
    required this.size,
  });

  final double progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress).clamp(0.0, 1.0);
    return IgnorePointer(
      child: Transform.scale(
        scale: 0.8 + 0.7 * Curves.easeOut.transform(progress),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.24),
            border: Border.all(
              color: tint(color, 0.2).withAlpha((220 * opacity).round()),
              width: size * 0.06,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((160 * opacity).round()),
                blurRadius: size * 0.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted panel shown over the board when the game is won or lost.
class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
      builder: (context, t, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6 * t, sigmaY: 6 * t),
          child: ColoredBox(
            color: GamePalette.backgroundBottom.withAlpha((170 * t).round()),
            child: Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.7 + 0.3 * Curves.easeOutBack.transform(t),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: OutlinedText(
                title,
                fontSize: 48,
                fillColor: Colors.white,
                outlineColor: shade(color, 0.35),
                extrude: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                PushButton(
                  onPressed: onPrimary,
                  color: color,
                  child: _buttonLabel(primaryLabel),
                ),
                if (secondaryLabel != null && onSecondary != null)
                  PushButton(
                    onPressed: onSecondary!,
                    color: GamePalette.panel,
                    child: _buttonLabel(secondaryLabel!, light: true),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonLabel(String text, {bool light = false}) {
    return Text(
      text,
      style: TextStyle(
        color: light ? Colors.white : const Color(0xFF3A1E00),
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}
