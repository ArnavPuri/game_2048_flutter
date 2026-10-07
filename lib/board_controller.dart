import 'dart:math';

enum MoveDirection { left, right, up, down }

/// A board position as (row, column).
typedef Cell = (int, int);

/// Describes a single tile travelling from one cell to another during a move.
class TileMovement {
  const TileMovement({
    required this.from,
    required this.to,
    required this.value,
  });

  final Cell from;
  final Cell to;

  /// The tile's value before any merge at [to].
  final int value;
}

class BoardController {
  BoardController({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<List<int>> currentBoard = _emptyBoard();
  int moves = 0;
  int score = 0;

  /// Every tile that moved (or stayed put) during the last successful move.
  List<TileMovement> lastMovements = const [];

  /// Cells that received a merged tile during the last move.
  Set<Cell> lastMerged = const {};

  /// Cells that received a freshly spawned tile since the last move/reset.
  List<Cell> lastSpawned = [];

  static List<List<int>> _emptyBoard() =>
      List.generate(4, (_) => List.filled(4, 0));

  void reset() {
    currentBoard = _emptyBoard();
    moves = 0;
    score = 0;
    lastMovements = const [];
    lastMerged = const {};
    lastSpawned = [];
    addRandomTile();
    addRandomTile();
  }

  bool makeMove(MoveDirection direction) {
    final next = _emptyBoard();
    final movements = <TileMovement>[];
    final merged = <Cell>{};
    var gained = 0;
    var changed = false;

    for (var line = 0; line < 4; line++) {
      // Cells ordered starting from the edge the tiles slide towards.
      final cells = _lineCells(direction, line);
      final tiles = [
        for (final cell in cells)
          if (_valueAt(cell) != 0) cell,
      ];

      var target = 0;
      for (var i = 0; i < tiles.length; i++) {
        final from = tiles[i];
        final value = _valueAt(from);
        final to = cells[target++];

        if (i + 1 < tiles.length && _valueAt(tiles[i + 1]) == value) {
          movements
            ..add(TileMovement(from: from, to: to, value: value))
            ..add(TileMovement(from: tiles[i + 1], to: to, value: value));
          next[to.$1][to.$2] = value * 2;
          gained += value * 2;
          merged.add(to);
          changed = true;
          i++;
        } else {
          movements.add(TileMovement(from: from, to: to, value: value));
          next[to.$1][to.$2] = value;
          if (from != to) changed = true;
        }
      }
    }

    if (!changed) return false;

    currentBoard = next;
    score += gained;
    moves++;
    lastMovements = movements;
    lastMerged = merged;
    lastSpawned = [];
    addRandomTile();
    return true;
  }

  bool hasWon() {
    for (final row in currentBoard) {
      for (final cell in row) {
        if (cell == 2048) return true;
      }
    }
    return false;
  }

  bool isGameOver() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (currentBoard[i][j] == 0) return false;
        if (j < 3 && currentBoard[i][j] == currentBoard[i][j + 1]) {
          return false;
        }
        if (i < 3 && currentBoard[i][j] == currentBoard[i + 1][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void addRandomTile() {
    final emptyLocations = <Cell>[];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (currentBoard[i][j] == 0) {
          emptyLocations.add((i, j));
        }
      }
    }
    if (emptyLocations.isEmpty) return;

    final location = emptyLocations[_random.nextInt(emptyLocations.length)];
    currentBoard[location.$1][location.$2] = _random.nextInt(10) < 9 ? 2 : 4;
    lastSpawned.add(location);
  }

  int _valueAt(Cell cell) => currentBoard[cell.$1][cell.$2];

  List<Cell> _lineCells(MoveDirection direction, int index) {
    return switch (direction) {
      MoveDirection.left => [for (var c = 0; c < 4; c++) (index, c)],
      MoveDirection.right => [for (var c = 3; c >= 0; c--) (index, c)],
      MoveDirection.up => [for (var r = 0; r < 4; r++) (r, index)],
      MoveDirection.down => [for (var r = 3; r >= 0; r--) (r, index)],
    };
  }
}
