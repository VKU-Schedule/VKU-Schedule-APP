// Test file để verify timezone
// Chạy: dart run lib/services/timezone_test.dart

void main() {
  print('=== Testing VKU Schedule Times ===\n');
  
  // Test period times
  final periods = [
    {'period': 1, 'start': '07:30', 'end': '08:20'},
    {'period': 2, 'start': '08:30', 'end': '09:20'},
    {'period': 3, 'start': '09:30', 'end': '10:20'},
    {'period': 4, 'start': '10:30', 'end': '11:20'},
    {'period': 5, 'start': '11:30', 'end': '12:20'},
    {'period': 6, 'start': '13:00', 'end': '13:50'},
    {'period': 7, 'start': '14:00', 'end': '14:50'},
    {'period': 8, 'start': '15:00', 'end': '15:50'},
    {'period': 9, 'start': '16:00', 'end': '16:50'},
    {'period': 10, 'start': '17:00', 'end': '17:50'},
  ];
  
  print('VKU Schedule Times:');
  for (final p in periods) {
    print('Tiết ${p['period']}: ${p['start']} - ${p['end']}');
  }
  
  print('\n=== Testing DateTime Creation ===\n');
  
  // Test creating DateTime
  final testDate = DateTime(2024, 12, 9); // Monday
  print('Test date: $testDate');
  print('Weekday: ${testDate.weekday} (1=Monday, 7=Sunday)');
  
  // Test period 1 (7:30 AM)
  final period1Start = DateTime(2024, 12, 9, 7, 30, 0);
  print('\nPeriod 1 start (7:30 AM):');
  print('  Local: $period1Start');
  print('  UTC: ${period1Start.toUtc()}');
  print('  ISO: ${period1Start.toIso8601String()}');
  
  // Test period 6 (1:00 PM)
  final period6Start = DateTime(2024, 12, 9, 13, 0, 0);
  print('\nPeriod 6 start (1:00 PM):');
  print('  Local: $period6Start');
  print('  UTC: ${period6Start.toUtc()}');
  print('  ISO: ${period6Start.toIso8601String()}');
  
  print('\n=== Expected Google Calendar Times ===\n');
  print('Nếu bạn ở Vietnam (UTC+7):');
  print('  7:30 AM local = 0:30 AM UTC');
  print('  1:00 PM local = 6:00 AM UTC');
  
  print('\nTimezone trong Google Calendar:');
  print('  Đang set: GMT+07:00 Indochina Time - Ho Chi Minh');
  print('  Đúng: Asia/Ho_Chi_Minh');
  
  print('\n=== Solution ===\n');
  print('Cần đảm bảo:');
  print('1. DateTime được tạo đúng (7:30, 8:30, ..., 13:00, 14:00, ...)');
  print('2. Timezone được set là "Asia/Ho_Chi_Minh"');
  print('3. Google Calendar API hiểu đúng timezone');
  print('4. Mỗi tiết 50 phút, nghỉ 10 phút');
}
