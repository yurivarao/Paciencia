import 'package:flame/game.dart';

import 'package:paciencia/paciencia_game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = PacienciaGame();
  runApp(GameWidget(game: game));
}
