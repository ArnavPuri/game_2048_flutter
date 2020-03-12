import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_2048/board_controller.dart';

class GameGrid extends StatefulWidget {
  @override
  _GameGridState createState() => _GameGridState();
}

Map<int, Color> kColorsMap = {
  0: Colors.blue.shade100,
  2: Colors.blue.shade200,
  4: Colors.blue.shade300,
  8: Colors.blue.shade400,
  16: Colors.blue.shade500,
  32: Colors.blue.shade600,
  64: Colors.blue.shade600,
  128: Colors.blue.shade700,
  256: Colors.blue.shade700,
  512: Colors.blue.shade800,
  1024: Colors.blue.shade800,
  2048: Colors.blue.shade900,
};

class _GameGridState extends State<GameGrid>
    with SingleTickerProviderStateMixin {
  BoardController boardController = BoardController();
  AnimationController _controller;
  MoveDirection _swipeDirection;

  @override
  void initState() {
    super.initState();
    boardController.addRandomTwo();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 800), value: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int rowIndex = 0;
    rowIndex < boardController.currentBoard.length;
    rowIndex++) {
      children.add(cellsRow(boardController.currentBoard[rowIndex], rowIndex));
    }
    return Column(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragEnd: (DragEndDetails dragDetails) {
            if (dragDetails.primaryVelocity == 0) {
              return;
            }
            _swipeDirection = dragDetails.primaryVelocity < 0
                ? MoveDirection.left
                : MoveDirection.right;
            boardController.makeMove(_swipeDirection);
            _controller.forward(from: 0.0);
            setState(() {});
          },
          onVerticalDragEnd: (DragEndDetails dragDetails) {
            if (dragDetails.primaryVelocity == 0) {
              return;
            }
            _swipeDirection = dragDetails.primaryVelocity < 0
                ? MoveDirection.up
                : MoveDirection.down;
            boardController.makeMove(_swipeDirection);
            _controller.forward(from: 0.0);
            setState(() {});
          },
          child: Container(
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: children),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          '${boardController.moves} Moves',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 32,
          ),
        )
      ],
    );
  }

  Widget cellsRow(List<int> row, int rowIndex) {
    List<Widget> children = [];
    for (int i = 0; i < row.length; i++) {
      int val = row[i];
      children.add(
        SingleCell(
          color: kColorsMap[val],
          value: val,
          animationController: _controller,
          direction: _swipeDirection,
          key: UniqueKey(),
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
  final int value;
  final Key key;
  final AnimationController animationController;
  final MoveDirection direction;

  SingleCell({this.color,
    this.value,
    this.key,
    this.animationController,
    this.direction})
      : super();

  @override
  _SingleCellState createState() => _SingleCellState();
}

class _SingleCellState extends State<SingleCell> {
  CurvedAnimation _curve;
  int oldValue;
  Color oldColor;

  @override
  void initState() {
    super.initState();
    _curve = CurvedAnimation(
        parent: widget.animationController, curve: Curves.decelerate);
    oldValue = widget.value;
    oldColor = widget.color;
    widget.animationController.addStatusListener(updateOldValue);
    widget.animationController.addListener(updateState);
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorTween(begin: oldColor, end: widget.color)
              .animate(_curve)
              .value,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          overflow: Overflow.clip,
          fit: StackFit.expand,
          children: <Widget>[
            Transform.translate(
              offset: getEnteringOffset()
                  .animate(_curve)
                  .value,
              child: Center(
                child: Text(
                  '${widget.value}',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ),
            Transform.translate(
              offset: getExitOffset()
                  .animate(_curve)
                  .value,
              child: Center(
                child: Text(
                  '${oldValue}',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tween<Offset> getEnteringOffset() {
    if (widget.direction == MoveDirection.down) {
      return Tween<Offset>(begin: Offset(0, -60), end: Offset(0, 0));
    } else if (widget.direction == MoveDirection.left) {
      return Tween<Offset>(begin: Offset(60, 0), end: Offset(0, 0));
    } else if (widget.direction == MoveDirection.right) {
      return Tween<Offset>(begin: Offset(-60, 0), end: Offset(0, 0));
    }
    return Tween<Offset>(begin: Offset(0, 60), end: Offset(0, 0));
  }

  Tween<Offset> getExitOffset() {
    Tween<Offset> enteringOffset = getEnteringOffset();
    return Tween<Offset>(
        begin: negation(enteringOffset.end),
        end: negation(enteringOffset.begin));
  }

  Offset negation(Offset offset) {
    return Offset(-offset.dx, -offset.dy);
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController.removeStatusListener(updateOldValue);
    widget.animationController.removeListener(updateState);
  }

  void updateOldValue(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      oldValue = widget.value;
      oldColor = widget.color;
    }
  }
}
