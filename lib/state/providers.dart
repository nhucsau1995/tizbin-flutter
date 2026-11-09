import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_data.dart';
import '../data/score_server.dart';
import '../data/submission_queue.dart';
import '../domain/challenge_generator.dart';
import '../domain/models.dart';
import '../domain/scoring.dart';

/// The mock backend. Overridden in tests with a fixed date.
final serverProvider = Provider<ScoreServer>((ref) => ScoreServer());

final todayProvider = Provider<DateTime>((ref) => ref.watch(serverProvider).data.today);

/// Bumped whenever server data changes, so derived lists recompute.
class Revision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final revisionProvider = NotifierProvider<Revision, int>(Revision.new);

const deviceId = 'this-device';

class Session extends Notifier<Player?> {
  @override
  Player? build() => null;

  /// Registration is one step: name, phone, avatar and an optional referral code.
  /// The mock server knows this phone number, so Sara's earlier games come back.
  void register({required String name, required String avatar}) {
    final base = ref.read(serverProvider).data.player(SampleData.me);
    state = Player(id: base.id, name: name, phone: base.phone, avatar: avatar, referralCode: base.referralCode);
    ref.read(serverProvider).registerDevice(deviceId, base.id);
  }

  void logIn() => register(name: 'سارا احمدی', avatar: 'avatar-sara');

  void logOut() => state = null;
}

final sessionProvider = NotifierProvider<Session, Player?>(Session.new);

enum BoardMode { daily, monthly }

class BoardModeNotifier extends Notifier<BoardMode> {
  @override
  BoardMode build() => BoardMode.daily;
  void set(BoardMode m) => state = m;
}

final boardModeProvider = NotifierProvider<BoardModeNotifier, BoardMode>(BoardModeNotifier.new);

class TabIndex extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

final tabProvider = NotifierProvider<TabIndex, int>(TabIndex.new);

// ---------------------------------------------------------------------------
// The daily run: 15 challenges, one 90-second clock.

class GameState {
  const GameState({
    required this.challenges,
    this.index = 0,
    this.answers = const [],
    this.usedMs = 0,
    this.challengeMs = 0,
    this.feedback,
    this.flipped = const [],
    this.matched = const {},
    this.mistakes = 0,
    this.submitting = false,
    this.result,
  });

  final List<Challenge> challenges;
  final int index;
  final List<AnswerLog> answers;

  /// Active play time used so far (the clock pauses during the short answer feedback).
  final int usedMs;
  final int challengeMs;

  /// Right/wrong flash after an answer, null while playing.
  final bool? feedback;

  // Memory match board.
  final List<int> flipped;
  final Set<int> matched;
  final int mistakes;

  final bool submitting;
  final SubmitResult? result;

  Challenge get current => challenges[index.clamp(0, challenges.length - 1)];
  int get remainingMs => (Rules.totalMs - usedMs).clamp(0, Rules.totalMs);
  bool get finished => submitting || result != null;

  /// Running score shown in the header (correct answers so far x 100).
  int get runningScore =>
      answers.where((a) => isCorrect(challenges[a.index], a)).length * Rules.pointsPerCorrect;

  /// The "which picture disappeared" board shows all four pieces first.
  bool get memorizing => current.type == GameType.disappeared && challengeMs < memorizeMs;

  static const memorizeMs = 2000;

  GameState copyWith({
    int? index,
    List<AnswerLog>? answers,
    int? usedMs,
    int? challengeMs,
    bool? feedback,
    bool clearFeedback = false,
    List<int>? flipped,
    Set<int>? matched,
    int? mistakes,
    bool? submitting,
    SubmitResult? result,
  }) =>
      GameState(
        challenges: challenges,
        index: index ?? this.index,
        answers: answers ?? this.answers,
        usedMs: usedMs ?? this.usedMs,
        challengeMs: challengeMs ?? this.challengeMs,
        feedback: clearFeedback ? null : feedback ?? this.feedback,
        flipped: flipped ?? this.flipped,
        matched: matched ?? this.matched,
        mistakes: mistakes ?? this.mistakes,
        submitting: submitting ?? this.submitting,
        result: result ?? this.result,
      );
}

class Game extends Notifier<GameState?> {
  Timer? _clock;
  Timer? _delay;
  final _queue = SubmissionQueue();

  static const tickMs = 100;
  static const feedbackMs = 450;

  @override
  GameState? build() {
    ref.onDispose(_stop);
    return null;
  }

  void _stop() {
    _clock?.cancel();
    _delay?.cancel();
  }

  void start() {
    _stop();
    state = GameState(challenges: ChallengeGenerator(ref.read(todayProvider)).build());
    _clock = Timer.periodic(const Duration(milliseconds: tickMs), (_) => _tick());
  }

  void _tick() {
    final s = state;
    if (s == null || s.finished || s.feedback != null) return;
    final used = s.usedMs + tickMs;
    state = s.copyWith(usedMs: used, challengeMs: s.challengeMs + tickMs);
    if (used >= Rules.totalMs) _finish();
  }

  /// Single-tap answer for find / disappeared / count / same-different.
  void answer(int value) {
    final s = state;
    if (s == null || s.finished || s.feedback != null || s.memorizing) return;
    _log(AnswerLog(index: s.index, value: value, elapsedMs: s.challengeMs));
  }

  void tapCard(int i) {
    final s = state;
    if (s == null || s.finished || s.feedback != null) return;
    if (s.current.type != GameType.match || s.matched.contains(i) || s.flipped.contains(i) || s.flipped.length == 2) return;
    final flipped = [...s.flipped, i];
    if (flipped.length < 2) {
      state = s.copyWith(flipped: flipped);
      return;
    }
    final cards = s.current.pieces;
    if (cards[flipped[0]] == cards[flipped[1]]) {
      final matched = {...s.matched, ...flipped};
      state = s.copyWith(flipped: const [], matched: matched);
      if (matched.length == cards.length) {
        _log(AnswerLog(index: s.index, value: cards.length ~/ 2, elapsedMs: s.challengeMs, mistakes: s.mistakes));
      }
    } else {
      state = s.copyWith(flipped: flipped, mistakes: s.mistakes + 1);
      _delay = Timer(const Duration(milliseconds: 600), () {
        final now = state;
        if (now != null && now.index == s.index) state = now.copyWith(flipped: const []);
      });
    }
  }

  void _log(AnswerLog a) {
    final s = state!;
    final ok = isCorrect(s.current, a);
    state = s.copyWith(answers: [...s.answers, a], feedback: ok);
    _delay?.cancel();
    _delay = Timer(const Duration(milliseconds: feedbackMs), () {
      final now = state;
      if (now == null) return;
      if (now.index + 1 >= now.challenges.length) {
        _finish();
      } else {
        state = now.copyWith(index: now.index + 1, challengeMs: 0, clearFeedback: true, flipped: const [], matched: const {}, mistakes: 0);
      }
    });
  }

  Future<void> _finish() async {
    final s = state;
    if (s == null || s.finished) return;
    _stop();
    state = s.copyWith(submitting: true, clearFeedback: true);
    final me = ref.read(sessionProvider)!;
    _queue.add(PendingSubmission(playerId: me.id, day: ref.read(todayProvider), answers: s.answers));
    SubmitResult? result;
    // Simulated round trip. On a dropped connection the run stays queued and is retried.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await _queue.flush((p) async {
      result = ref.read(serverProvider).submit(playerId: p.playerId, deviceId: deviceId, day: p.day, answers: p.answers);
      return true;
    });
    ref.read(revisionProvider.notifier).bump();
    final now = state;
    if (now != null && result != null) state = now.copyWith(submitting: false, result: result);
  }

  void quit() {
    _stop();
    state = null;
  }
}

final gameProvider = NotifierProvider<Game, GameState?>(Game.new);

// ---------------------------------------------------------------------------
// Admin review.

class Flags extends Notifier<List<ScoreFlag>> {
  @override
  List<ScoreFlag> build() => [...ref.read(serverProvider).data.flags];

  void decide(String id, FlagStatus status) {
    final flags = ref.read(serverProvider).data.flags;
    final i = flags.indexWhere((f) => f.id == id);
    if (i >= 0) flags[i] = flags[i].copyWith(status: status);
    state = [...flags];
    ref.read(revisionProvider.notifier).bump();
  }
}

final flagsProvider = NotifierProvider<Flags, List<ScoreFlag>>(Flags.new);

/// Small UI preferences on the profile screen.
class Prefs {
  const Prefs({this.sound = true, this.largeText = false});
  final bool sound;
  final bool largeText;
}

class PrefsNotifier extends Notifier<Prefs> {
  @override
  Prefs build() => const Prefs();
  void sound(bool v) => state = Prefs(sound: v, largeText: state.largeText);
  void largeText(bool v) => state = Prefs(sound: state.sound, largeText: v);
}

final prefsProvider = NotifierProvider<PrefsNotifier, Prefs>(PrefsNotifier.new);

// ---------------------------------------------------------------------------
// Derived reads. Plain functions over WidgetRef instead of derived providers: Riverpod 3
// pauses providers under offstage tabs and covered routes, and a paused derived provider
// that recomputes on resume would schedule a rebuild in the middle of a frame.

extension Derived on WidgetRef {
  List<DailyResult> history() {
    watch(revisionProvider);
    final me = watch(sessionProvider);
    return me == null ? const [] : watch(serverProvider).history(me.id);
  }

  int totalPoints() => history().fold(0, (s, r) => s + r.score);

  bool playedToday() {
    watch(revisionProvider);
    final me = watch(sessionProvider);
    return me != null && watch(serverProvider).hasPlayed(me.id, watch(todayProvider));
  }

  List<LeaderRow> board() {
    watch(revisionProvider);
    final server = watch(serverProvider);
    final day = watch(todayProvider);
    return watch(boardModeProvider) == BoardMode.daily ? server.daily(day) : server.monthly(day);
  }
}
