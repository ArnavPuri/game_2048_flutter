import 'package:flutter/material.dart';
import 'package:game_2048/board_controller.dart';

class GameGrid extends StatefulWidget {
  @override
  _GameGridState createState() => _GameGridState();
}

Map<int, Color> kColorsMap = {
  0: Colors.yellow.shade100,
  2: Colors.yellow.shade200,
  4: Colors.yellow.shade300,
  8: Colors.yellow.shade400,
  16: Colors.yellow.shade500,
  32: Colors.yellow.shade600,
  64: Colors.yellow.shade600,
  128: Colors.yellow.shade700,
  256: Colors.yellow.shade700,
  512: Colors.yellow.shade800,
  1024: Colors.yellow.shade800,
  2048: Colors.yellow.shade900,
};

class _GameGridState extends State<GameGrid> {
  BoardController boardController = BoardController();
  List<List<Key>> boardKeys = [];
  List<List<int>> changedCells = [];

  @override
  void initState() {
    super.initState();
    boardController.addRandomTwo();
    boardKeys =
        List.generate(4, (index) => List.generate(4, (index2) => UniqueKey()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int rowIndex = 0;
    rowIndex < boardController.currentBoard.length;
    rowIndex++) {
      children.add(cellsRow(boardController.currentBoard[rowIndex], rowIndex));
    }
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails dragDetails) {
        if (dragDetails.primaryVelocity < 0) {
          changedCells =
              boardController.makeMoveAndGetChanges(MoveDirection.left);
        } else if (dragDetails.primaryVelocity > 0) {
          changedCells =
              boardController.makeMoveAndGetChanges(MoveDirection.right);
        }
        setState(() {});
      },
      onVerticalDragEnd: (DragEndDetails dragDetails) {
        if (dragDetails.primaryVelocity < 0) {
          changedCells =
              boardController.makeMoveAndGetChanges(MoveDirection.down);
        } else if (dragDetails.primaryVelocity > 0) {
          changedCells =
              boardController.makeMoveAndGetChanges(MoveDirection.up);
        }
        setState(() {});
      },
      child: Container(
        color: Colors.black12,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: children),
      ),
    );
  }

  Widget cellsRow(List<int> row, int rowIndex) {
    List<Widget> children = [];
    for (int j = 0; j < changedCells.length; j++) {
      var changedCell = changedCells[j];
      boardKeys[changedCell[0]][changedCell[1]] = UniqueKey();
    }
    changedCells.clear();
    for (int i = 0; i < row.length; i++) {
      int val = row[i];
      children.add(
        SingleCell(
          color: kColorsMap[val],
          value: val,
          key: boardKeys[rowIndex][i],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}

class SingleCell extends StatefulWidget {
  final Color color;
  int value;
  Key key;

  SingleCell({this.color, this.value, this.key}) : super();

  @override
  _SingleCellState createState() => _SingleCellState();
}

class _SingleCellState extends State<SingleCell>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _curve = CurvedAnimation(parent: _controller, curve: Curves.bounceOut);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.2, end: 1.0).animate(_curve),
          child: Text(
            '${widget.value}',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
