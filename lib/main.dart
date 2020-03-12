import 'package:flutter/material.dart';

import 'game_grid.dart';

void main() => runApp(MaterialApp(
      home: GameScreen(),
    ));

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048 Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GameGrid(),
        ],
      ),
    );
  }
}
