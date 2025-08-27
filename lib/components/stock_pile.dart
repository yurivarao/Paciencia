import 'dart:ui';

import 'package:flame/components.dart';

import 'package:paciencia/components/card.dart';
import 'package:paciencia/components/pile.dart';
import 'package:paciencia/components/waste_pile.dart';
import 'package:paciencia/paciencia_game.dart';

// Functionalities of StockPile:
// 1. Ability to hold cards that are not currently in play, face down;
// 2. Tapping the stock should reveal top 3 cards and move them to the waste pile;
// 3. When the cards run out, there should be a visual indicating that this is the stock pile;
// 4. When the cards run out, tapping the empty stock should move all the cards from the waste pile into the stock, turning them face down.

class StockPile extends PositionComponent
    with HasGameReference<PacienciaGame>
    implements Pile {
  StockPile({super.position}) : super(size: PacienciaGame.cardSize);

  // Which cards are currently placed onto this pile. The first card in the list is at the bottom, the last card is on top.
  final List<Card> _cards = [];

  @override
  // Can be moved by onTapUp callback (see below).
  bool canMoveCard(Card card, MoveMethod method) => false;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card, MoveMethod method) =>
      throw StateError('Cannot remove cards');

  @override
  // Card cannot be removed but could have been dragged out of place.
  void returnCard(Card card) => card.priority = _cards.indexOf(card);

  @override
  void acquireCard(Card card) {
    assert(card.isFaceDown);
    card.pile = this;
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }

  void handleTapUp(Card card) {
    final wastePile = parent!.firstChild<WastePile>()!;

    if (_cards.isEmpty) {
      assert(card.isBaseCard, 'Stock Pile is empty, but no Base Card present');
      card.position = position; // Force Base Card (back) into correct position.
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < game.pacienciaDraw; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.doMoveAndFlip(
            wastePile.position,
            whenDone: () {
              wastePile.acquireCard(card);
            },
          );
        }
      }
    }
  }

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(PacienciaGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      PacienciaGame.cardWidth * 0.3,
      _circlePaint,
    );
  }
}
