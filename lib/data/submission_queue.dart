import '../domain/models.dart';

/// A finished run waiting to reach the server.
class PendingSubmission {
  const PendingSubmission({required this.playerId, required this.day, required this.answers});
  final String playerId;
  final DateTime day;
  final List<AnswerLog> answers;
}

/// Keeps a finished run until the network is back, so a dropped connection on a cheap
/// phone never loses the day's only official attempt. The payload is a few hundred
/// bytes (answer values and timings, no media).
class SubmissionQueue {
  final List<PendingSubmission> _pending = [];

  List<PendingSubmission> get pending => List.unmodifiable(_pending);

  void add(PendingSubmission s) {
    // One official attempt per day: a second run for the same day replaces nothing.
    if (_pending.any((p) => p.playerId == s.playerId && p.day == s.day)) return;
    _pending.add(s);
  }

  /// Sends everything with [send]; keeps the ones that fail for the next try.
  Future<int> flush(Future<bool> Function(PendingSubmission) send) async {
    var sent = 0;
    for (final s in [..._pending]) {
      if (await send(s)) {
        _pending.remove(s);
        sent++;
      }
    }
    return sent;
  }
}
