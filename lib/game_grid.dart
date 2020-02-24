import 'package:flutter/material.dart';
import 'package:game_2048/board_controller.dart';

class GameGrid extends StatefulWidget {
  @override
  _GameGridState createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  BoardController boardController = BoardController();

  @override
  void initState() {
    super.initState();
    boardController.addRandomTwo();
    setState(() {});
  }

  List<List<int>> getRows() {
    List<List<int>> rows = [];
    for (int i = 0; i < boardController.currentBoard.length; i++) {
      List<int> singleRow = [];
      for (int j = 0; j < boardController.currentBoard.length; j++) {
        singleRow.add(boardController.currentBoard[i][j]);
      }
      rows.add(singleRow);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: EdgeInsets.all(12),
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails dragDetails) {
          print('Drag end v ${dragDetails.velocity}');
          print('Drag end primary v ${dragDetails.primaryVelocity}');
          if (dragDetails.primaryVelocity < 0) {
            boardController.leftSlideBoard();
          } else if (dragDetails.primaryVelocity > 0) {
            boardController.rightSlideBoard();
          }
          setState(() {});
        },
        onVerticalDragEnd: (DragEndDetails dragDetails) {
          print('Drag end v ${dragDetails.velocity}');
          print('Drag end primary v ${dragDetails.primaryVelocity}');
          if (dragDetails.primaryVelocity < 0) {
            boardController.downSlideBoard();
          } else if (dragDetails.primaryVelocity > 0) {
            boardController.upSlideBoard();
          }
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: getRows().map((row) => cellsRow(row)).toList()
            ..addAll([
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    color: Colors.blue,
                    splashColor: Colors.blue,
                    onPressed: () {
                      boardController.leftSlideBoard();
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                    ),
                    color: Colors.blue,
                    splashColor: Colors.blue,
                    onPressed: () {
                      boardController.upSlideBoard();
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    color: Colors.blue,
                    splashColor: Colors.blue,
                    onPressed: () {
                      boardController.downSlideBoard();
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    color: Colors.blue,
                    splashColor: Colors.blue,
                    onPressed: () {
                      boardController.rightSlideBoard();
                      setState(() {});
                    },
                  ),
                ],
              )
            ]),
        ),
      ),
    );
  }

  Widget cellsRow(List<int> row) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: row.map((val) => singleCell(val)).toList(),
      ),
    );
  }

  Map<int, Color> colorsMap = {
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

  Widget singleCell(int val) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
          color: colorsMap[val], borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          '$val',
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}
