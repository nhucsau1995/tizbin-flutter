/// Core game and competition models. Pure Dart, shared by the app, the mock
/// backend and the unit tests.
library;

/// The five reusable game mechanics. Every daily competition cycles through them.
enum GameType { findDifferent, disappeared, count, sameDifferent, match }

/// A flat 2D game piece, drawn in code (no image download needed).
enum PieceKind { apple, star, heart, ball, sun, flower, fish, house, duck, car, banana, cat }

/// Fixed piece colors from the design's game palette.
enum PieceColor { red, green, yellow, blue, orange, lavender, pink }

class Piece {
  const Piece(this.kind, this.color);
  final PieceKind kind;
  final PieceColor color;

  @override
  bool operator ==(Object other) => other is Piece && other.kind == kind && other.color == color;

  @override
  int get hashCode => Object.hash(kind, color);
}

/// One challenge of the daily competition. Each type uses only the fields it needs.
class Challenge {
  const Challenge({
    required this.index,
    required this.type,
    this.pieces = const [],
    this.options = const [],
    this.answer = 0,
    this.left,
    this.right,
    this.scatter = const [],
    this.hidden = -1,
  });

  final int index;
  final GameType type;

  /// findDifferent: the 9 grid tiles. disappeared: the 4 shown before one vanishes.
  /// match: the 6 cards (3 pairs), in board order.
  final List<Piece> pieces;

  /// disappeared: 3 answer pieces. count: 4 number choices (as pieces is unused).
  final List<Object> options;

  /// findDifferent: tile index. disappeared: index in [options] of the vanished piece.
  /// count: the right number. sameDifferent: 1 = same, 0 = different.
  final int answer;

  /// sameDifferent: the two houses (window colors differ when different).
  final HouseSpec? left;
  final HouseSpec? right;

  /// count: the scattered objects on the board.
  final List<Piece> scatter;

  /// disappeared: index in [pieces] that vanishes after the memorize phase.
  final int hidden;
}

class HouseSpec {
  const HouseSpec({required this.windowLeft, required this.windowRight, required this.door});
  final PieceColor windowLeft;
  final PieceColor windowRight;
  final PieceColor door;

  @override
  bool operator ==(Object other) =>
      other is HouseSpec &&
      other.windowLeft == windowLeft &&
      other.windowRight == windowRight &&
      other.door == door;

  @override
  int get hashCode => Object.hash(windowLeft, windowRight, door);
}

/// What the player did on one challenge, sent to the server for validation.
class AnswerLog {
  const AnswerLog({required this.index, required this.value, required this.elapsedMs, this.mistakes = 0});
  final int index;

  /// The chosen value (tile index, number, 1/0 for same/different). Match: pairs found.
  final int value;
  final int elapsedMs;

  /// Match only: wrong flips.
  final int mistakes;
}

class Player {
  const Player({required this.id, required this.name, required this.phone, required this.avatar, required this.referralCode});
  final String id;
  final String name;
  final String phone;
  final String avatar;
  final String referralCode;
}

/// A validated daily result (one official attempt per player per day).
class DailyResult {
  const DailyResult({
    required this.playerId,
    required this.day,
    required this.correct,
    required this.timeMs,
    required this.score,
    this.rank,
  });
  final String playerId;
  final DateTime day;
  final int correct;
  final int timeMs;
  final int score;
  final int? rank;

  DailyResult withRank(int r) =>
      DailyResult(playerId: playerId, day: day, correct: correct, timeMs: timeMs, score: score, rank: r);
}

class LeaderRow {
  const LeaderRow({required this.rank, required this.playerId, required this.name, required this.avatar, required this.score, required this.correct, this.timeMs = 0});
  final int rank;
  final String playerId;
  final String name;
  final String avatar;
  final int score;
  final int correct;
  final int timeMs;
}

enum FlagStatus { pending, approved, rejected }

class ScoreFlag {
  const ScoreFlag({required this.id, required this.userLabel, required this.reason, required this.detail, this.status = FlagStatus.pending});
  final String id;
  final String userLabel;
  final String reason;
  final String detail;
  final FlagStatus status;

  ScoreFlag copyWith({FlagStatus? status}) =>
      ScoreFlag(id: id, userLabel: userLabel, reason: reason, detail: detail, status: status ?? this.status);
}

class PrizeRecord {
  const PrizeRecord({required this.month, required this.place, required this.winner, required this.recorded});
  final String month;
  final String place;
  final String winner;
  final bool recorded;
}
