import 'dart:ui';

import 'package:flame/components.dart';

import 'package:paciencia/components/card.dart';
import 'package:paciencia/components/pile.dart';
import 'package:paciencia/components/suit.dart';
import 'package:paciencia/paciencia_game.dart';

class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(int intSuit, this.checkWin, {super.position})
    : suit = Suit.fromInt(intSuit),
      super(size: PacienciaGame.cardSize);

  final VoidCallback checkWin;

  final Suit suit;
  final List<Card> _cards = [];

  bool get isFull => _cards.length == 13;

  @override
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);

    if (isFull) {
      checkWin(); // Get PacienciaWorld to check all FoundationPiles.
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(PacienciaGame.cardRRect, _borderPaint);
    suit.sprite.render(
      canvas,
      position: size / 2,
      anchor: Anchor.center,
      size: Vector2.all(PacienciaGame.cardWidth * 0.6),
      overridePaint: _suitPaint,
    );
  }

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed ? const Color(0x3a000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;

  @override
  bool canMoveCard(Card card, MoveMethod method) =>
      _cards.isNotEmpty && card == _cards.last && method != MoveMethod.tap;

  @override
  bool canAcceptCard(Card card) {
    final topCardRank = _cards.isEmpty ? 0 : _cards.last.rank.value;
    return card.suit == suit &&
        card.rank.value == topCardRank + 1 &&
        card.attachedCards.isEmpty;
  }

  @override
  void removeCard(Card card, MoveMethod method) {
    assert(canMoveCard(card, method));
    _cards.removeLast();
  }

  @override
  void returnCard(Card card) {
    card.position = position;
    card.priority = _cards.indexOf(card);
  }
}
