import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_grid.dart';
import 'game_theme.dart';
import 'widgets/hud.dart';

void main() => runApp(const Game2048App());

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: GamePalette.gold,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: GamePalette.backgroundBottom,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GameBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: GameGrid(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
