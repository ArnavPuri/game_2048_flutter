import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/board_controller.dart';
import 'package:game_2048/main.dart';
import 'package:game_2048/widgets/block_tile.dart';

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
      test('records tile movements and merges for animation', () {
      controller.currentBoard = [
        [2, 2, 4, 0],
        [0, 0, 0, 8],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.left);

      expect(controller.currentBoard[0].sublist(0, 2), [4, 4]);
      expect(controller.currentBoard[1][0], 8);
      expect(controller.lastMerged, {(0, 0)});

      final moves = {
        for (final m in controller.lastMovements) m.from: (m.to, m.value),
      };
      expect(moves[(0, 0)], ((0, 0), 2));
      expect(moves[(0, 1)], ((0, 0), 2));
      expect(moves[(0, 2)], ((0, 1), 4));
      expect(moves[(1, 3)], ((1, 0), 8));
    });

    test('records the spawned tile after a move', () {
      controller.currentBoard = [
        [0, 0, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.left);

      expect(controller.lastSpawned, hasLength(1));
      final (r, c) = controller.lastSpawned.single;
      expect(controller.currentBoard[r][c], isIn([2, 4]));
    });

    test('merges each tile at most once per move', () {
      controller.currentBoard = [
        [2, 2, 2, 2],
        [4, 4, 8, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      controller.makeMove(MoveDirection.right);
      expect(controller.currentBoard[0].sublist(2), [4, 4]);
      expect(controller.currentBoard[1].sublist(2), [8, 8]);
      expect(controller.score, 16);
    });
  });

  testWidgets('game screen renders and responds to swipes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const Game2048App());
    await tester.pumpAndSettle();

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);

    for (final offset in const [
      Offset(-200, 0),
      Offset(0, -200),
      Offset(200, 0),
      Offset(0, 200),
    ]) {
      await tester.drag(find.byType(TileSocket).at(5), offset);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('NEW GAME'));
    await tester.pumpAndSettle();
    expect(find.text('Moves: 0'), findsOneWidget);
  });
}
