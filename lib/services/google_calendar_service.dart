import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/session.dart';
import '../models/schedule_option.dart';

class GoogleCalendarService {
  static const _scopes = [calendar.CalendarApi.calendarScope];
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Sign in to Google and get authenticated client
  Future<AuthClient?> _getAuthenticatedClient() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;
      final idToken = authentication.idToken;

      if (accessToken == null) return null;

      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        ),
        null,
        _scopes,
      );

      return authenticatedClient(http.Client(), credentials);
    } catch (e) {
      print('Error getting authenticated client: $e');
      return null;
    }
  }

  /// Export schedule to Google Calendar
  /// Returns the calendar ID if successful, null otherwise
  Future<String?> exportSchedule({
    required ScheduleOption schedule,
    required DateTime semesterStartDate,
    required DateTime semesterEndDate,
    String? calendarName,
  }) async {
    try {
      final client = await _getAuthenticatedClient();
      if (client == null) {
        throw Exception('Không thể đăng nhập Google');
      }

      final calendarApi = calendar.CalendarApi(client);

      // Create a new calendar for this schedule
      final newCalendar = calendar.Calendar()
        ..summary = calendarName ?? 'VKU - Lịch học ${DateTime.now().toString().substring(0, 10)}'
        ..description = 'Lịch học VKU - Điểm: ${schedule.score.toStringAsFixed(1)}'
        ..timeZone = 'Asia/Ho_Chi_Minh';

      final createdCalendar = await calendarApi.calendars.insert(newCalendar);
      final calendarId = createdCalendar.id;

      if (calendarId == null) {
        throw Exception('Không thể tạo calendar');
      }

      // Add all sessions as recurring events
      for (final session in schedule.sessions) {
        await _createRecurringEvent(
          calendarApi,
          calendarId,
          session,
          semesterStartDate,
          semesterEndDate,
        );
      }

      client.close();
      return calendarId;
    } catch (e) {
      print('Error exporting schedule: $e');
      rethrow;
    }
  }

  /// Create a recurring event for a session
  Future<void> _createRecurringEvent(
    calendar.CalendarApi calendarApi,
    String calendarId,
    Session session,
    DateTime semesterStart,
    DateTime semesterEnd,
  ) async {
    final firstOccurrence = _getFirstOccurrence(session, semesterStart);
    
    final startTime = _getPeriodStartTime(session.startPeriod);
    final endTime = _getPeriodEndTime(session.endPeriod);

    final dateStr = '${firstOccurrence.year.toString().padLeft(4, '0')}-'
        '${firstOccurrence.month.toString().padLeft(2, '0')}-'
        '${firstOccurrence.day.toString().padLeft(2, '0')}';
    
    final startTimeStr = 'T${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}:00';
    
    final endTimeStr = 'T${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}:00';

    final localStart = DateTime.parse('$dateStr$startTimeStr');
    final localEnd = DateTime.parse('$dateStr$endTimeStr');
    
    final eventStart = localStart.subtract(const Duration(hours: 7));
    final eventEnd = localEnd.subtract(const Duration(hours: 7));

    final rrule = 'RRULE:FREQ=WEEKLY;UNTIL=${_formatDateForRRule(semesterEnd)}';

    final startEventDateTime = calendar.EventDateTime();
    startEventDateTime.dateTime = eventStart;
    startEventDateTime.timeZone = 'Asia/Ho_Chi_Minh';

    final endEventDateTime = calendar.EventDateTime();
    endEventDateTime.dateTime = eventEnd;
    endEventDateTime.timeZone = 'Asia/Ho_Chi_Minh';

    // Debug logging
    print('Creating event for ${session.courseName}');
    print('Date: $dateStr');
    print('Start time: ${startTime.hour}:${startTime.minute} -> $startTimeStr');
    print('End time: ${endTime.hour}:${endTime.minute} -> $endTimeStr');
    print('Local Start: $localStart');
    print('Local End: $localEnd');
    print('UTC Start (sent to API): $eventStart');
    print('UTC End (sent to API): $eventEnd');
    print('Timezone: Asia/Ho_Chi_Minh');

    final event = calendar.Event()
      ..summary = session.courseName
      ..description = '''
Giảng viên: ${session.teacher}
Phòng: ${session.room}
Khu: ${session.area}
${session.periodRange}
Lớp: N${session.classIndex} (${session.classSize} SV)
Ngôn ngữ: ${session.language}
Chuyên ngành: ${session.field}
'''
      ..location = '${session.room}, ${session.area}, VKU'
      ..start = startEventDateTime
      ..end = endEventDateTime
      ..recurrence = [rrule]
      ..colorId = _getColorForSubject(session.courseName);

    await calendarApi.events.insert(event, calendarId);
  }

  DateTime _getFirstOccurrence(Session session, DateTime semesterStart) {
    final targetDayIndex = session.dayIndex; // 0 = Monday, 6 = Sunday
    final startDayIndex = semesterStart.weekday - 1; // Convert to 0-based

    int daysToAdd = targetDayIndex - startDayIndex;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }

    return semesterStart.add(Duration(days: daysToAdd));
  }

  /// Get start time for a period (VKU schedule)
  /// Lịch VKU: Mỗi tiết 50 phút, nghỉ 10 phút giữa các tiết
  TimeOfDay _getPeriodStartTime(int period) {
    const periodTimes = {
      1: TimeOfDay(hour: 7, minute: 30),   // 07:30
      2: TimeOfDay(hour: 8, minute: 30),   // 08:30
      3: TimeOfDay(hour: 9, minute: 30),   // 09:30
      4: TimeOfDay(hour: 10, minute: 30),  // 10:30
      5: TimeOfDay(hour: 11, minute: 30),  // 11:30
      6: TimeOfDay(hour: 13, minute: 0),   // 13:00 (sau nghỉ trưa)
      7: TimeOfDay(hour: 14, minute: 0),   // 14:00
      8: TimeOfDay(hour: 15, minute: 0),   // 15:00
      9: TimeOfDay(hour: 16, minute: 0),   // 16:00
      10: TimeOfDay(hour: 17, minute: 0),  // 17:00
    };
    return periodTimes[period] ?? const TimeOfDay(hour: 7, minute: 30);
  }

  /// Get end time for a period (VKU schedule)
  TimeOfDay _getPeriodEndTime(int period) {
    const periodTimes = {
      1: TimeOfDay(hour: 8, minute: 20),   // 08:20
      2: TimeOfDay(hour: 9, minute: 20),   // 09:20
      3: TimeOfDay(hour: 10, minute: 20),  // 10:20
      4: TimeOfDay(hour: 11, minute: 20),  // 11:20
      5: TimeOfDay(hour: 12, minute: 20),  // 12:20
      6: TimeOfDay(hour: 13, minute: 50),  // 13:50
      7: TimeOfDay(hour: 14, minute: 50),  // 14:50
      8: TimeOfDay(hour: 15, minute: 50),  // 15:50
      9: TimeOfDay(hour: 16, minute: 50),  // 16:50
      10: TimeOfDay(hour: 17, minute: 50), // 17:50
    };
    return periodTimes[period] ?? const TimeOfDay(hour: 8, minute: 20);
  }

  String _formatDateForRRule(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}${utc.month.toString().padLeft(2, '0')}${utc.day.toString().padLeft(2, '0')}T235959Z';
  }

  String _getColorForSubject(String courseName) {
    final hash = courseName.hashCode.abs();
    final colorId = (hash % 11) + 1; // Colors 1-11
    return colorId.toString();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}
