# Export to Google Calendar Feature

## Tổng quan
Tính năng xuất lịch học sang Google Calendar, cho phép người dùng đồng bộ lịch VKU lên Google Calendar của họ.

## Cấu trúc

```
lib/features/export/
├── presentation/
│   └── export_calendar_dialog.dart  # Dialog để chọn thông tin xuất
└── README.md

lib/services/
└── google_calendar_service.dart     # Service xử lý Google Calendar API
```

## Luồng hoạt động

1. **Người dùng chọn xuất lịch**
   - Từ trang "Lịch đã lưu" → Click "Xuất GG"
   - Từ trang "Lịch tuần" → Click icon chia sẻ → "Xuất Google Calendar"

2. **Dialog xuất hiện**
   - Nhập tên calendar
   - Chọn ngày bắt đầu học kỳ
   - Chọn ngày kết thúc học kỳ

3. **Xử lý xuất**
   - Đăng nhập Google (nếu chưa)
   - Tạo calendar mới
   - Tạo các sự kiện lặp lại hàng tuần
   - Thông báo thành công

## API sử dụng

### GoogleCalendarService

```dart
class GoogleCalendarService {
  // Xuất schedule sang Google Calendar
  Future<String?> exportSchedule({
    required ScheduleOption schedule,
    required DateTime semesterStartDate,
    required DateTime semesterEndDate,
    String? calendarName,
  });
  
  // Đăng xuất
  Future<void> signOut();
  
  // Kiểm tra đã đăng nhập chưa
  Future<bool> isSignedIn();
}
```

### Thời gian tiết học VKU

```dart
Tiết 1:  07:30 - 08:20
Tiết 2:  08:30 - 09:20
Tiết 3:  09:30 - 10:20
Tiết 4:  10:30 - 11:20
Tiết 5:  11:30 - 12:20
--- Nghỉ trưa ---
Tiết 6:  13:00 - 13:50
Tiết 7:  14:00 - 14:50
Tiết 8:  15:00 - 15:50
Tiết 9:  16:00 - 16:50
Tiết 10: 17:00 - 17:50
```

**Lưu ý:** 
- Mỗi tiết học 50 phút
- Nghỉ giữa các tiết 10 phút
- Nghỉ trưa: 12:20 - 13:00 (40 phút)

## Cấu hình cần thiết

### 1. Google Cloud Console
- Tạo project
- Bật Google Calendar API
- Tạo OAuth 2.0 credentials (Android, iOS)
- Cấu hình OAuth consent screen

### 2. Android
- Thêm SHA-1 fingerprint
- Cấu hình `strings.xml`
- Min SDK 21

### 3. iOS
- Cấu hình URL schemes trong `Info.plist`
- Thêm reversed client ID

Chi tiết xem file `GOOGLE_CALENDAR_SETUP.md` ở root project.

## Dependencies

```yaml
dependencies:
  googleapis: ^13.1.0
  google_sign_in: ^6.1.6
  googleapis_auth: ^1.4.1
  http: ^1.1.0
```

## Ví dụ sử dụng

```dart
// Trong saved_schedules_page.dart
ElevatedButton.icon(
  onPressed: scheduleOption != null
      ? () {
          showDialog(
            context: context,
            builder: (context) => ExportCalendarDialog(
              schedule: scheduleOption,
            ),
          );
        }
      : null,
  icon: const Icon(Icons.upload),
  label: const Text('Xuất GG'),
)
```

## Xử lý lỗi

### Sign in failed
- Kiểm tra cấu hình OAuth
- Kiểm tra SHA-1 fingerprint
- Kiểm tra package name

### Calendar creation failed
- Kiểm tra quyền truy cập
- Kiểm tra kết nối internet
- Kiểm tra scope trong OAuth consent

### Events not created
- Kiểm tra ngày bắt đầu/kết thúc hợp lệ
- Kiểm tra dữ liệu session
- Kiểm tra timezone

## Testing

```bash
# Chạy app
flutter run

# Test trên thiết bị thật (cần cho Google Sign-In)
flutter run --release
```

## Cải tiến tương lai

1. **Cập nhật calendar**
   - Cho phép cập nhật calendar đã tạo
   - Đồng bộ thay đổi

2. **Chọn calendar có sẵn**
   - Không tạo calendar mới
   - Thêm vào calendar đã có

3. **Xóa calendar**
   - Xóa calendar từ app
   - Xóa các events

4. **Thông báo**
   - Nhắc nhở trước giờ học
   - Thông báo thay đổi lịch

5. **Offline support**
   - Lưu queue export
   - Tự động sync khi có mạng
