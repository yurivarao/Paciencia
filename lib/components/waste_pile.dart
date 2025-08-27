import 'package:flame/components.dart';

import 'package:paciencia/components/card.dart';
import 'package:paciencia/components/pile.dart';
import 'package:paciencia/paciencia_game.dart';

class WastePile extends PositionComponent
    with HasGameReference<PacienciaGame>
    implements Pile {
  WastePile({super.position}) : super(size: PacienciaGame.cardSize);

  // Which cards are currently placed onto this pile. The first card in the list is at the bottom, the last card is on top.
  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(PacienciaGame.cardWidth * 0.2, 0);

  @override
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.pile = this;
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
    _fanOutTopCards();
  }

  void _fanOutTopCards() {
    if (game.pacienciaDraw == 1) {
      // No fan-out in Klondike Draw 1.
      return;
    }

    final n = _cards.length;
    for (var i = 0; i < n; i++) {
      _cards[i].position = position;
    }
    if (n == 2) {
      _cards[1].position.add(_fanOffset);
    } else if (n >= 3) {
      _cards[n - 2].position.add(_fanOffset);
      _cards[n - 1].position.addScaled(_fanOffset, 2);
    }
  }

  List<Card> removeAllCards() {
    final cards = _cards.toList();
    _cards.clear();
    return cards;
  }

  @override
  bool canMoveCard(Card card, MoveMethod method) =>
      _cards.isNotEmpty && card == _cards.last;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card, MoveMethod method) {
    assert(canMoveCard(card, method));
    _cards.removeLast();
    _fanOutTopCards();
  }

  @override
  void returnCard(Card card) {
    card.priority = _cards.indexOf(card);
    _fanOutTopCards();
  }
}
