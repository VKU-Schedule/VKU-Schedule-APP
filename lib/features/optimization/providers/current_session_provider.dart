import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để lưu sessionId của lần tạo lịch hiện tại
final currentSessionIdProvider = StateProvider<String?>((ref) => null);

/// Tạo sessionId mới
String generateSessionId() {
  return 'session_${DateTime.now().millisecondsSinceEpoch}';
}
