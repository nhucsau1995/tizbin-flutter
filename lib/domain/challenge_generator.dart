import 'dart:math';

import 'models.dart';
import 'scoring.dart';

/// Builds the same 15 challenges for every player on a given day, from a seed the
/// server knows. The server regenerates them to validate answers, so the client
/// never sends a score it computed itself.
class ChallengeGenerator {
  ChallengeGenerator(this.day) : _rng = Random(seedFor(day));

  final DateTime day;
  final Random _rng;

  static int seedFor(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

  List<Challenge> build() => [
        for (var i = 0; i < Rules.challenges; i++) _make(i, GameType.values[i % GameType.values.length]),
      ];

  Challenge _make(int i, GameType type) {
    switch (type) {
      case GameType.findDifferent:
        return _findDifferent(i);
      case GameType.disappeared:
        return _disappeared(i);
      case GameType.count:
        return _count(i);
      case GameType.sameDifferent:
        return _sameDifferent(i);
      case GameType.match:
        return _match(i);
    }
  }

  T _pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  static const _diffPairs = [
    (Piece(PieceKind.apple, PieceColor.red), Piece(PieceKind.apple, PieceColor.green)),
    (Piece(PieceKind.star, PieceColor.yellow), Piece(PieceKind.star, PieceColor.orange)),
    (Piece(PieceKind.fish, PieceColor.blue), Piece(PieceKind.fish, PieceColor.orange)),
    (Piece(PieceKind.heart, PieceColor.red), Piece(PieceKind.heart, PieceColor.pink)),
  ];

  Challenge _findDifferent(int i) {
    // The first round always uses the apples from the design.
    final pair = i == 0 ? _diffPairs.first : _pick(_diffPairs);
    final odd = i == 0 ? 4 : _rng.nextInt(9);
    return Challenge(
      index: i,
      type: GameType.findDifferent,
      pieces: [for (var t = 0; t < 9; t++) t == odd ? pair.$2 : pair.$1],
      answer: odd,
    );
  }

  static const _memory = [
    Piece(PieceKind.cat, PieceColor.orange),
    Piece(PieceKind.fish, PieceColor.blue),
    Piece(PieceKind.sun, PieceColor.yellow),
    Piece(PieceKind.duck, PieceColor.yellow),
    Piece(PieceKind.flower, PieceColor.pink),
    Piece(PieceKind.ball, PieceColor.blue),
    Piece(PieceKind.car, PieceColor.red),
    Piece(PieceKind.apple, PieceColor.red),
  ];

  Challenge _disappeared(int i) {
    final pool = [..._memory]..shuffle(_rng);
    final shown = pool.take(4).toList();
    final gone = _rng.nextInt(4);
    // Options: the vanished piece plus two that were never shown, in random order.
    final options = <Object>[shown[gone], pool[4], pool[5]]..shuffle(_rng);
    return Challenge(
      index: i,
      type: GameType.disappeared,
      pieces: shown,
      options: options,
      answer: options.indexOf(shown[gone]),
      hidden: gone,
    );
  }

  Challenge _count(int i) {
    final target = _pick(const [
      Piece(PieceKind.star, PieceColor.yellow),
      Piece(PieceKind.heart, PieceColor.red),
      Piece(PieceKind.ball, PieceColor.blue),
    ]);
    final n = 4 + _rng.nextInt(4); // 4..7
    final others = [
      for (final p in const [
        Piece(PieceKind.star, PieceColor.yellow),
        Piece(PieceKind.heart, PieceColor.red),
        Piece(PieceKind.ball, PieceColor.blue),
      ])
        if (p != target) p,
    ];
    final scatter = <Piece>[
      for (var k = 0; k < n; k++) target,
      for (var k = 0; k < 3 + _rng.nextInt(3); k++) _pick(others),
    ]..shuffle(_rng);
    final base = (n - 1 - _rng.nextInt(3)).clamp(1, 20);
    final options = <Object>[for (var k = 0; k < 4; k++) base + k];
    if (!options.contains(n)) options[3] = n;
    options.sort((a, b) => (a as int).compareTo(b as int));
    return Challenge(index: i, type: GameType.count, pieces: [target], scatter: scatter, options: options, answer: n);
  }

  Challenge _sameDifferent(int i) {
    const colors = [PieceColor.blue, PieceColor.yellow, PieceColor.green, PieceColor.orange];
    final a = HouseSpec(windowLeft: _pick(colors), windowRight: _pick(colors), door: PieceColor.blue);
    final same = _rng.nextBool();
    final b = same
        ? a
        : HouseSpec(
            windowLeft: a.windowLeft,
            windowRight: colors.firstWhere((c) => c != a.windowRight),
            door: a.door,
          );
    return Challenge(index: i, type: GameType.sameDifferent, left: a, right: b, answer: same ? 1 : 0);
  }

  Challenge _match(int i) {
    final kinds = [
      const Piece(PieceKind.banana, PieceColor.yellow),
      const Piece(PieceKind.car, PieceColor.blue),
      const Piece(PieceKind.duck, PieceColor.orange),
      const Piece(PieceKind.flower, PieceColor.pink),
      const Piece(PieceKind.fish, PieceColor.blue),
    ]..shuffle(_rng);
    final cards = [...kinds.take(3), ...kinds.take(3)]..shuffle(_rng);
    return Challenge(index: i, type: GameType.match, pieces: cards, answer: 3);
  }
}
