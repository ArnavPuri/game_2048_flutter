import 'dart:math';

enum MoveDirection { left, right, up, down }

class BoardController {
  List<List<int>> currentBoard =
      List.generate(4, (_) => List.generate(4, (_) => 0));
  int moves = 0;
  int score = 0;

  void reset() {
    currentBoard = List.generate(4, (_) => List.generate(4, (_) => 0));
    moves = 0;
    score = 0;
    addRandomTile();
    addRandomTile();
  }

  bool makeMove(MoveDirection direction) {
    final previousBoard =
        currentBoard.map((row) => List<int>.from(row)).toList();

    switch (direction) {
      case MoveDirection.left:
        _leftSlideBoard();
      case MoveDirection.right:
        _rightSlideBoard();
      case MoveDirection.up:
        _upSlideBoard();
      case MoveDirection.down:
        _downSlideBoard();
    }

    final boardChanged = !_boardsEqual(previousBoard, currentBoard);
    if (boardChanged) {
      addRandomTile();
      moves++;
    }
    return boardChanged;
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

  List<int> _leftSlide(List<int> row) {
    final filtered = row.where((val) => val != 0).toList();
    for (int i = 0; i < filtered.length - 1; i++) {
      if (filtered[i] == filtered[i + 1]) {
        filtered[i] *= 2;
        score += filtered[i];
        filtered[i + 1] = 0;
      }
    }
    final result = filtered.where((val) => val != 0).toList();
    while (result.length < 4) {
      result.add(0);
    }
    return result;
  }

  List<int> _rightSlide(List<int> row) =>
      _leftSlide(row.reversed.toList()).reversed.toList();

  void _leftSlideBoard() {
    currentBoard = currentBoard.map((row) => _leftSlide(row)).toList();
  }

  void _rightSlideBoard() {
    currentBoard = currentBoard.map((row) => _rightSlide(row)).toList();
  }

  List<List<int>> _transposeBoard(List<List<int>> board) {
    return List.generate(4, (i) => List.generate(4, (j) => board[j][i]));
  }

  void _upSlideBoard() {
    currentBoard = _transposeBoard(
        _transposeBoard(currentBoard).map((row) => _leftSlide(row)).toList());
  }

  void _downSlideBoard() {
    currentBoard = _transposeBoard(
        _transposeBoard(currentBoard).map((row) => _rightSlide(row)).toList());
  }

  void addRandomTile() {
    final emptyLocations = <List<int>>[];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (currentBoard[i][j] == 0) {
          emptyLocations.add([i, j]);
        }
      }
    }
    if (emptyLocations.isEmpty) return;

    final random = Random();
    final location = emptyLocations[random.nextInt(emptyLocations.length)];
    currentBoard[location[0]][location[1]] = random.nextInt(10) < 9 ? 2 : 4;
  }

  bool _boardsEqual(List<List<int>> a, List<List<int>> b) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (a[i][j] != b[i][j]) return false;
      }
    }
    return true;
  }
}
