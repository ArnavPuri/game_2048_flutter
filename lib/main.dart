import 'package:flutter/material.dart';

import 'game_grid.dart';

void main() => runApp(const Game2048App());

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFEDC22E),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF776E65),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: GameGrid(),
        ),
      ),
    );
  }
}
