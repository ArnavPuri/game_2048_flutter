import 'package:flutter/material.dart';
import 'package:game_2048/board_controller.dart';

const Map<int, Color> kTileColors = {
  0: Color(0xFFCDC1B4),
  2: Color(0xFFEEE4DA),
  4: Color(0xFFEDE0C8),
  8: Color(0xFFF2B179),
  16: Color(0xFFF59563),
  32: Color(0xFFF67C5F),
  64: Color(0xFFF65E3B),
  128: Color(0xFFEDCF72),
  256: Color(0xFFEDCC61),
  512: Color(0xFFEDC850),
  1024: Color(0xFFEDC53F),
  2048: Color(0xFFEDC22E),
};

const Map<int, Color> kTextColors = {
  0: Colors.transparent,
  2: Color(0xFF776E65),
  4: Color(0xFF776E65),
};

Color _textColorFor(int value) {
  return kTextColors[value] ?? Colors.white;
}

Color _tileColorFor(int value) {
  return kTileColors[value] ?? const Color(0xFF3C3A32);
}

class GameGrid extends StatefulWidget {
  const GameGrid({super.key});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid>
    with SingleTickerProviderStateMixin {
  final BoardController _boardController = BoardController();
  late final AnimationController _animController;
  MoveDirection? _swipeDirection;
  bool _hasShownWinDialog = false;

  @override
  void initState() {
    super.initState();
    _boardController.addRandomTile();
    _boardController.addRandomTile();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleMove(MoveDirection direction) {
    if (_boardController.isGameOver()) return;

    final moved = _boardController.makeMove(direction);
    if (!moved) return;

    _swipeDirection = direction;
    _animController.forward(from: 0.0);
    setState(() {});

    if (_boardController.hasWon() && !_hasShownWinDialog) {
      _hasShownWinDialog = true;
      _showGameDialog(
        title: 'You Win!',
        message: 'Congratulations! You reached 2048!\n'
            'Score: ${_boardController.score}',
      );
    } else if (_boardController.isGameOver()) {
      _showGameDialog(
        title: 'Game Over',
        message: 'No more moves available.\n'
            'Score: ${_boardController.score}',
      );
    }
  }

  void _showGameDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _boardController.reset();
      _hasShownWinDialog = false;
      _swipeDirection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScoreBox(label: 'Score', value: _boardController.score),
              _ScoreBox(label: 'Moves', value: _boardController.moves),
              IconButton.filled(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh),
                tooltip: 'New Game',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity == 0) return;
            _handleMove(
                velocity < 0 ? MoveDirection.left : MoveDirection.right);
          },
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity == 0) return;
            _handleMove(velocity < 0 ? MoveDirection.up : MoveDirection.down);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (rowIndex) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (colIndex) {
                      final value =
                          _boardController.currentBoard[rowIndex][colIndex];
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: _Tile(
                          value: value,
                          animationController: _animController,
                          direction: _swipeDirection,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFEEE4DA),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  final int value;
  final AnimationController animationController;
  final MoveDirection? direction;

  const _Tile({
    required this.value,
    required this.animationController,
    required this.direction,
  });

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  late CurvedAnimation _curve;
  late int _oldValue;
  late Color _oldColor;

  @override
  void initState() {
    super.initState();
    _curve = CurvedAnimation(
        parent: widget.animationController, curve: Curves.easeOut);
    _oldValue = widget.value;
    _oldColor = _tileColorFor(widget.value);
    widget.animationController.addStatusListener(_updateOldValue);
    widget.animationController.addListener(_refresh);
  }

  void _refresh() {
    setState(() {});
  }

  void _updateOldValue(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _oldValue = widget.value;
      _oldColor = _tileColorFor(widget.value);
    }
  }

  @override
  void dispose() {
    widget.animationController.removeStatusListener(_updateOldValue);
    widget.animationController.removeListener(_refresh);
    _curve.dispose();
    super.dispose();
  }

  Tween<Offset> _enteringOffset() {
    return switch (widget.direction) {
      MoveDirection.down =>
        Tween(begin: const Offset(0, -70), end: Offset.zero),
      MoveDirection.up => Tween(begin: const Offset(0, 70), end: Offset.zero),
      MoveDirection.left =>
        Tween(begin: const Offset(70, 0), end: Offset.zero),
      MoveDirection.right =>
        Tween(begin: const Offset(-70, 0), end: Offset.zero),
      null => Tween(begin: Offset.zero, end: Offset.zero),
    };
  }

  Tween<Offset> _exitingOffset() {
    final entering = _enteringOffset();
    return Tween(
      begin: -entering.end!,
      end: -entering.begin!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _tileColorFor(widget.value);
    return ClipRect(
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              ColorTween(begin: _oldColor, end: currentColor).animate(_curve).value,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: _enteringOffset().animate(_curve).value!,
              child: Center(
                child: Text(
                  widget.value == 0 ? '' : '${widget.value}',
                  style: TextStyle(
                    fontSize: widget.value >= 1000 ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: _textColorFor(widget.value),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: _exitingOffset().animate(_curve).value!,
              child: Center(
                child: Text(
                  _oldValue == 0 ? '' : '$_oldValue',
                  style: TextStyle(
                    fontSize: _oldValue >= 1000 ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: _textColorFor(_oldValue),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
