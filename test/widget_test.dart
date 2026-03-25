import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/board_controller.dart';

void main() {
  group('BoardController', () {
    late BoardController controller;

    setUp(() {
      controller = BoardController();
    });

    test('initializes with empty 4x4 board', () {
      for (final row in controller.currentBoard) {
        for (final cell in row) {
          expect(cell, 0);
        }
      }
      expect(controller.moves, 0);
      expect(controller.score, 0);
    });

    test('addRandomTile places a tile on an empty cell', () {
      controller.addRandomTile();
      int nonZeroCount = 0;
      for (final row in controller.currentBoard) {
        for (final cell in row) {
          if (cell != 0) nonZeroCount++;
        }
      }
      expect(nonZeroCount, 1);
    });

    test('reset clears board and adds two tiles', () {
      controller.reset();
      int nonZeroCount = 0;
      for (final row in controller.currentBoard) {
        for (final cell in row) {
          if (cell != 0) nonZeroCount++;
        }
      }
      expect(nonZeroCount, 2);
      expect(controller.moves, 0);
      expect(controller.score, 0);
    });

    test('left slide merges matching adjacent tiles', () {
      controller.currentBoard = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.left);
      expect(controller.currentBoard[0][0], 4);
      expect(controller.score, 4);
    });

    test('right slide merges matching tiles', () {
      controller.currentBoard = [
        [0, 0, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.right);
      expect(controller.currentBoard[0][3], 4);
    });

    test('up slide merges matching tiles', () {
      controller.currentBoard = [
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.up);
      expect(controller.currentBoard[0][0], 4);
    });

    test('down slide merges matching tiles', () {
      controller.currentBoard = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.down);
      expect(controller.currentBoard[3][0], 4);
    });

    test('hasWon returns true when 2048 tile exists', () {
      controller.currentBoard[0][0] = 2048;
      expect(controller.hasWon(), true);
    });

    test('hasWon returns false when no 2048 tile', () {
      controller.currentBoard[0][0] = 1024;
      expect(controller.hasWon(), false);
    });

    test('isGameOver returns false when empty cells exist', () {
      expect(controller.isGameOver(), false);
    });

    test('isGameOver returns false when merges are possible', () {
      controller.currentBoard = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2, 4],
        [8, 16, 32, 32],
      ];
      expect(controller.isGameOver(), false);
    });

    test('isGameOver returns true when no moves left', () {
      controller.currentBoard = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [2, 4, 8, 16],
        [32, 64, 128, 256],
      ];
      expect(controller.isGameOver(), true);
    });

    test('makeMove returns false when move changes nothing', () {
      controller.currentBoard = [
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final moved = controller.makeMove(MoveDirection.left);
      expect(moved, false);
      expect(controller.moves, 0);
    });
  });
}
