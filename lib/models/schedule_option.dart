import 'session.dart';

/// Represents a single schedule option with sessions and optimization score
class ScheduleOption {
  final String id;
  final double score;
  final ScheduleMetrics metrics;
  final List<Session> sessions;
  final bool isFavorite;

  ScheduleOption({
    required this.id,
    required this.score,
    required this.metrics,
    required this.sessions,
    this.isFavorite = false,
  });

  /// Create ScheduleOption from API response JSON
  /// Generates a unique ID if not provided
  factory ScheduleOption.fromJson(Map<String, dynamic> json) {
    final sessions = (json['sessions'] as List<dynamic>?)
            ?.map((s) => Session.fromJson(s as Map<String, dynamic>))
            .toList() ??
        (json['schedule'] as List<dynamic>?)
            ?.map((s) => Session.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    // Generate ID from sessions hash if not provided
    final id = json['id'] as String? ??
        _generateIdFromSessions(sessions);

    return ScheduleOption(
      id: id,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      metrics: json['metrics'] != null
          ? ScheduleMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : ScheduleMetrics(),
      sessions: sessions,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Create ScheduleOption from ApiScheduleOption
  factory ScheduleOption.fromApiScheduleOption(dynamic apiSchedule) {
    // Convert ApiSession list to Session list
    final sessions = (apiSchedule.schedule as List<dynamic>)
        .map((apiSession) => Session.fromApiSession(apiSession))
        .toList();

    // Calculate metrics from sessions
    final metrics = calculateMetrics(sessions);

    // Generate unique, short, user-friendly ID from sessions content
    final uniqueId = _generateUniqueId(sessions);

    return ScheduleOption(
      id: uniqueId,
      score: (apiSchedule.score as num).toDouble(),
      metrics: metrics,
      sessions: sessions,
      isFavorite: false,
    );
  }

  /// Calculate metrics from sessions
  static ScheduleMetrics calculateMetrics(List<Session> sessions) {
    if (sessions.isEmpty) {
      return ScheduleMetrics();
    }

    // Calculate conflicts (overlapping sessions)
    int conflicts = 0;
    for (int i = 0; i < sessions.length; i++) {
      for (int j = i + 1; j < sessions.length; j++) {
        if (sessions[i].overlapsWith(sessions[j])) {
          conflicts++;
        }
      }
    }

    // Calculate morning ratio (sessions before period 6)
    final morningSessions = sessions.where((s) => s.startPeriod < 6).length;
    final morningRatio = morningSessions / sessions.length;

    // Calculate balance (variance of sessions per day)
    final dayCounts = <String, int>{};
    for (final session in sessions) {
      dayCounts[session.day] = (dayCounts[session.day] ?? 0) + 1;
    }
    final avg = sessions.length / 7.0;
    final variance = dayCounts.values
        .map((count) => (count - avg) * (count - avg))
        .fold(0.0, (sum, val) => sum + val) / 7.0;
    final balance = variance > 0 ? 1.0 / (1.0 + variance) : 1.0;

    // Calculate gap score (average gap between consecutive sessions on same day)
    double totalGap = 0.0;
    int gapCount = 0;
    final sessionsByDay = <String, List<Session>>{};
    for (final session in sessions) {
      sessionsByDay.putIfAbsent(session.day, () => []).add(session);
    }

    for (final daySessions in sessionsByDay.values) {
      daySessions.sort((a, b) => a.startPeriod.compareTo(b.startPeriod));
      for (int i = 0; i < daySessions.length - 1; i++) {
        final gap = daySessions[i + 1].startPeriod - daySessions[i].endPeriod - 1;
        if (gap > 0) {
          totalGap += gap;
          gapCount++;
        }
      }
    }

    final gapScore = gapCount > 0 ? totalGap / gapCount / 12.0 : 0.0;

    return ScheduleMetrics(
      conflicts: conflicts,
      balance: balance,
      morningRatio: morningRatio,
      gapScore: gapScore,
    );
  }

  /// Generate unique, short, user-friendly ID from sessions content
  /// Format: PA + 6 characters (base36: 0-9, a-z)
  /// This ensures uniqueness based on schedule content and prevents collisions
  static String _generateUniqueId(List<Session> sessions) {
    // Create hash from sessions content to ensure uniqueness
    int contentHash = sessions.fold<int>(
      0,
      (prev, session) => prev ^ session.hashCode,
    );
    
    // Add timestamp to ensure uniqueness even with identical sessions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final combinedHash = contentHash ^ timestamp.hashCode;
    
    // Convert to base36 (0-9, a-z) for shorter, readable format
    final base36Id = _toBase36(combinedHash.abs(), length: 6);
    
    return 'PA$base36Id';
  }

  /// Generate a unique ID based on sessions content (fallback for fromJson)
  static String _generateIdFromSessions(List<Session> sessions) {
    return _generateUniqueId(sessions);
  }

  /// Convert integer to base36 string (0-9, a-z)
  /// Ensures output has exactly [length] characters (padded with 0)
  static String _toBase36(int value, {required int length}) {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    if (value == 0) {
      return '0' * length;
    }
    
    final buffer = StringBuffer();
    int remaining = value;
    
    // Convert to base36
    while (remaining > 0) {
      buffer.write(chars[remaining % 36]);
      remaining ~/= 36;
    }
    
    // Reverse and ensure exactly [length] characters
    final result = buffer.toString().split('').reversed.join();
    
    // If longer than desired length, take last [length] characters
    // If shorter, pad with leading zeros
    if (result.length > length) {
      return result.substring(result.length - length);
    } else {
      return result.padLeft(length, '0');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'metrics': metrics.toJson(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  /// Create a copy with modified fields
  ScheduleOption copyWith({
    String? id,
    double? score,
    ScheduleMetrics? metrics,
    List<Session>? sessions,
    bool? isFavorite,
  }) {
    return ScheduleOption(
      id: id ?? this.id,
      score: score ?? this.score,
      metrics: metrics ?? this.metrics,
      sessions: sessions ?? this.sessions,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Add a session to this schedule
  /// Automatically recalculates metrics
  ScheduleOption addSession(Session session) {
    final newSessions = List<Session>.from(sessions)..add(session);
    final newMetrics = calculateMetrics(newSessions);
    return copyWith(
      sessions: newSessions,
      metrics: newMetrics,
    );
  }

  /// Remove a session from this schedule
  /// Automatically recalculates metrics
  ScheduleOption removeSession(Session session) {
    final newSessions = sessions.where((s) => s != session).toList();
    final newMetrics = calculateMetrics(newSessions);
    return copyWith(
      sessions: newSessions,
      metrics: newMetrics,
    );
  }

  /// Get summary statistics for this schedule
  Map<String, dynamic> getSummary() {
    final daysWithClasses = sessions.map((s) => s.day).toSet().length;
    final totalSessions = sessions.length;
    final freeDays = 7 - daysWithClasses;

    return {
      'totalSessions': totalSessions,
      'daysWithClasses': daysWithClasses,
      'freeDays': freeDays,
      'score': score,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ScheduleOption(id: $id, score: $score, sessions: ${sessions.length})';
}

class ScheduleMetrics {
  final int conflicts;
  final double balance;
  final double morningRatio;
  final double gapScore;

  ScheduleMetrics({
    this.conflicts = 0,
    this.balance = 0.0,
    this.morningRatio = 0.0,
    this.gapScore = 0.0,
  });

  factory ScheduleMetrics.fromJson(Map<String, dynamic> json) {
    return ScheduleMetrics(
      conflicts: json['conflicts'] as int? ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      morningRatio: (json['morningRatio'] as num?)?.toDouble() ?? 0.0,
      gapScore: (json['gapScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conflicts': conflicts,
      'balance': balance,
      'morningRatio': morningRatio,
      'gapScore': gapScore,
    };
  }
}


