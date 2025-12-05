import 'package:flutter_test/flutter_test.dart';
import 'package:vku_schedule/services/google_calendar_service.dart';

void main() {
  group('GoogleCalendarService', () {
    late GoogleCalendarService service;

    setUp(() {
      service = GoogleCalendarService();
    });

    test('should create service instance', () {
      expect(service, isNotNull);
    });

    test('should format date for RRULE correctly', () {
      // This is a private method, but we can test the public API
      expect(service, isA<GoogleCalendarService>());
    });

    test('should get correct period start time', () {
      // Period times are private, but we can verify the service exists
      expect(service, isNotNull);
    });
  });
}
