# Hướng dẫn cấu hình Google Calendar Export

## Tính năng
- Xuất lịch học sang Google Calendar
- Tạo calendar riêng cho lịch VKU
- Tự động tạo các sự kiện lặp lại hàng tuần
- Bao gồm đầy đủ thông tin: giảng viên, phòng học, khu vực

## Cấu hình Google Cloud Console

### 1. Tạo Project trên Google Cloud Console
1. Truy cập https://console.cloud.google.com/
2. Tạo project mới hoặc chọn project hiện có
3. Ghi nhớ Project ID

### 2. Bật Google Calendar API
1. Vào "APIs & Services" > "Library"
2. Tìm "Google Calendar API"
3. Click "Enable"

### 3. Tạo OAuth 2.0 Credentials

#### Cho Android:
1. Vào "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Chọn "Android"
4. Nhập Package name: `com.vku.schedule` (hoặc package name của bạn)
5. Lấy SHA-1 fingerprint:
   ```bash
   # Debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release keystore (khi build release)
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
   ```
6. Nhập SHA-1 fingerprint
7. Click "Create"

#### Cho iOS:
1. Vào "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Chọn "iOS"
4. Nhập Bundle ID: `com.vku.schedule` (hoặc bundle ID của bạn)
5. Click "Create"

#### Cho Web (nếu cần test trên web):
1. Tạo OAuth client ID cho Web
2. Thêm authorized redirect URIs:
   - `http://localhost:8080`
   - `http://localhost:3000`

### 4. Cấu hình OAuth Consent Screen
1. Vào "APIs & Services" > "OAuth consent screen"
2. Chọn "External" (hoặc "Internal" nếu dùng Google Workspace)
3. Điền thông tin:
   - App name: VKU Schedule
   - User support email: your-email@example.com
   - Developer contact: your-email@example.com
4. Thêm scopes:
   - `https://www.googleapis.com/auth/calendar`
5. Thêm test users (nếu app chưa publish)

## Cấu hình trong Flutter Project

### Android Configuration

Tạo/cập nhật file `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

Cập nhật `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // ... existing config
        minSdkVersion 21  // Google Sign-In requires min SDK 21
    }
}
```

### iOS Configuration

Cập nhật `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reversed client ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Sử dụng

### 1. Từ trang Lịch đã lưu
1. Mở trang "Lịch đã lưu"
2. Chọn lịch muốn xuất
3. Click nút "Xuất GG"
4. Chọn ngày bắt đầu và kết thúc học kỳ
5. Đặt tên cho calendar
6. Click "Xuất lịch"

### 2. Từ trang Lịch tuần
1. Mở lịch tuần
2. Click icon chia sẻ (iOS share icon)
3. Chọn "Xuất Google Calendar"
4. Làm theo các bước tương tự

## Lưu ý

### Quyền truy cập
- App cần quyền truy cập Google Calendar
- Người dùng phải đăng nhập Google
- Lần đầu sử dụng sẽ yêu cầu cấp quyền

### Dữ liệu được xuất
- Tên môn học
- Giảng viên
- Phòng học và khu vực
- Thời gian (tiết học)
- Lặp lại hàng tuần cho đến hết học kỳ

### Giới hạn
- Mỗi lần xuất tạo 1 calendar mới
- Không tự động cập nhật khi lịch thay đổi
- Cần xóa calendar cũ nếu muốn xuất lại

## Troubleshooting

### Lỗi "Sign in failed"
- Kiểm tra SHA-1 fingerprint đã đúng chưa
- Kiểm tra package name/bundle ID
- Đảm bảo đã bật Google Calendar API

### Lỗi "Access denied"
- Kiểm tra OAuth consent screen đã cấu hình đúng
- Thêm email test user nếu app chưa publish
- Kiểm tra scope đã thêm đúng

### Lỗi "Calendar not created"
- Kiểm tra kết nối internet
- Thử đăng xuất và đăng nhập lại
- Kiểm tra quyền truy cập Google Calendar

## Testing

### Test trên emulator/simulator
```bash
# Android
flutter run

# iOS
flutter run
```

### Test trên thiết bị thật
```bash
# Build và cài đặt
flutter run --release
```

### Kiểm tra calendar đã tạo
1. Mở Google Calendar trên web hoặc app
2. Kiểm tra danh sách calendars bên trái
3. Tìm calendar với tên đã đặt
4. Xem các sự kiện đã được tạo

## Cải tiến trong tương lai
- [ ] Cập nhật calendar khi lịch thay đổi
- [ ] Chọn calendar có sẵn thay vì tạo mới
- [ ] Xóa calendar từ app
- [ ] Đồng bộ 2 chiều
- [ ] Thông báo nhắc nhở trước giờ học
