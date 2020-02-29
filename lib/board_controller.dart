import 'dart:math';

enum MoveDirection { left, right, up, down }

class BoardController {
  List<List<int>> currentBoard;

  BoardController() {
    currentBoard = List.generate(4, (index) => List.generate(4, (index) => 0));
  }

  List<List<int>> makeMoveAndGetChanges(MoveDirection direction) {
    var prevBoard = currentBoard;
    getCurrentMove(direction)();
    return getUpdatedCells(prevBoard);
  }

  Function getCurrentMove(MoveDirection direction) {
    switch (direction) {
      case MoveDirection.down:
        return downSlideBoard;
        break;
      case MoveDirection.left:
        return leftSlideBoard;
        break;
      case MoveDirection.right:
        return rightSlideBoard;
        break;
      case MoveDirection.up:
        return upSlideBoard;
        break;
    }
    throw ArgumentError("Invalid move");
  }

  bool hasWon() {
    for (int i = 0; i < currentBoard.length; i++) {
      for (int j = 0; j < currentBoard[i].length; j++) {
        if (currentBoard[i][j] == 2048) {
          return true;
        }
      }
    }
    return false;
  }

  bool isGameOver() {
    for (int i = 0; i < currentBoard.length; i++) {
      for (int j = 0; j < currentBoard[i].length; j++) {
        if (currentBoard[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void printBoard(List<List<int>> board) => board.forEach(print);

  List<List<int>> getUpdatedCells(List<List<int>> prevBoard) {
    List<List<int>> updatedCells = [];
    for (int row = 0; row < prevBoard.length; row++) {
      for (int col = 0; col < prevBoard[row].length; col++) {
        if (currentBoard[row][col] != prevBoard[row][col] &&
            currentBoard[row][col] != 0) updatedCells.add([row, col]);
      }
    }
    return updatedCells;
  }

  List<int> leftSlide(List<int> row) {
    int originalLength = row.length;
    row = row.where((val) => val != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      int firstNum = row[i];
      int secondNum = row[i + 1];
      if (firstNum == secondNum) {
        row[i] = firstNum + secondNum;
        row[i + 1] = 0;
      }
    }
    row = row.where((val) => val != 0).toList();
    int zeroesToInsert = originalLength - row.length;
    row.addAll(List.generate(zeroesToInsert, (index) => 0));
    return row;
  }

  List<int> rightSlide(List<int> row) =>
      leftSlide(row.reversed.toList()).reversed.toList();

// Board Operations
  void leftSlideBoard() {
    currentBoard = currentBoard.map((row) => leftSlide(row)).toList();
    addRandomTwo();
  }

  void rightSlideBoard() {
    currentBoard = currentBoard.map((row) => rightSlide(row)).toList();
    addRandomTwo();
  }

  List<List<int>> transposeBoard(List<List<int>> board) {
    List<List<int>> result = [];
    for (int i = 0; i < board.length; i++) {
      result.add(board.map((row) => row[i]).toList());
    }
    return result;
  }

  void upSlideBoard() {
    currentBoard = transposeBoard(
        transposeBoard(currentBoard).map((row) => leftSlide(row)).toList());
    addRandomTwo();
  }

  void downSlideBoard() {
    currentBoard = transposeBoard(
        transposeBoard(currentBoard).map((row) => rightSlide(row)).toList());
    addRandomTwo();
  }

  void addRandomTwo() {
    List<List<int>> locationsOfZero = [];
    for (int i = 0; i < currentBoard.length; i++) {
      for (int j = 0; j < currentBoard[i].length; j++) {
        if (currentBoard[i][j] == 0) {
          locationsOfZero.add([i, j]);
        }
      }
    }
    if (locationsOfZero.length == 0) {
      return;
    }
    List<int> randomIndex =
        locationsOfZero[Random().nextInt(locationsOfZero.length)];
    currentBoard[randomIndex[0]][randomIndex[1]] = 2;
  }
}
