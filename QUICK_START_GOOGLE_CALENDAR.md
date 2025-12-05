# Hướng dẫn nhanh: Xuất lịch sang Google Calendar

## Bước 1: Cấu hình Google Cloud Console (Chỉ làm 1 lần)

### 1.1. Tạo Project
1. Truy cập: https://console.cloud.google.com/
2. Click "Select a project" → "New Project"
3. Đặt tên: "VKU Schedule"
4. Click "Create"

### 1.2. Bật Google Calendar API
1. Vào menu → "APIs & Services" → "Library"
2. Tìm "Google Calendar API"
3. Click "Enable"

### 1.3. Tạo OAuth Consent Screen
1. Vào "APIs & Services" → "OAuth consent screen"
2. Chọn "External" → Click "Create"
3. Điền thông tin:
   - App name: `VKU Schedule`
   - User support email: `your-email@gmail.com`
   - Developer contact: `your-email@gmail.com`
4. Click "Save and Continue"
5. Scopes: Click "Add or Remove Scopes"
   - Tìm và chọn: `https://www.googleapis.com/auth/calendar`
   - Click "Update" → "Save and Continue"
6. Test users: Click "Add Users"
   - Thêm email của bạn
   - Click "Save and Continue"
7. Click "Back to Dashboard"

### 1.4. Tạo OAuth Client ID cho Android

#### Lấy SHA-1 Fingerprint:
```bash
# Mở terminal và chạy:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy dòng SHA-1 (ví dụ: `A1:B2:C3:D4:...`)

#### Tạo Credentials:
1. Vào "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Application type: "Android"
4. Name: `VKU Schedule Android`
5. Package name: `com.vku.schedule` (hoặc package name trong `android/app/build.gradle`)
6. SHA-1: Paste SHA-1 fingerprint vừa copy
7. Click "Create"

### 1.5. Tạo OAuth Client ID cho Web (Bắt buộc)
1. Click "Create Credentials" → "OAuth client ID"
2. Application type: "Web application"
3. Name: `VKU Schedule Web`
4. Click "Create"
5. **Copy Client ID** (dạng: `xxxxx.apps.googleusercontent.com`)

## Bước 2: Cấu hình Android App

### 2.1. Tạo file strings.xml
Tạo file `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">PASTE_WEB_CLIENT_ID_HERE</string>
</resources>
```

**Thay `PASTE_WEB_CLIENT_ID_HERE` bằng Web Client ID từ bước 1.5**

### 2.2. Kiểm tra build.gradle
Mở `android/app/build.gradle`, đảm bảo:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Phải >= 21
    }
}
```

## Bước 3: Chạy App

```bash
# Cài dependencies
flutter pub get

# Chạy app (debug)
flutter run --flavor prod

# Hoặc chạy release
flutter run --flavor prod --release
```

## Bước 4: Sử dụng tính năng

### Cách 1: Từ trang "Lịch đã lưu"
1. Mở app → Vào tab "Lịch đã lưu"
2. Chọn lịch muốn xuất
3. Click nút **"Xuất GG"**
4. Điền thông tin:
   - Tên lịch (ví dụ: "VKU HK1 2024")
   - Ngày bắt đầu học kỳ
   - Ngày kết thúc học kỳ
5. Click **"Xuất lịch"**
6. Đăng nhập Google (lần đầu)
7. Chấp nhận quyền truy cập
8. Đợi xuất xong → Thông báo thành công!

### Cách 2: Từ trang "Lịch tuần"
1. Mở lịch tuần
2. Click icon **chia sẻ** (iOS share icon) ở góc trên
3. Chọn **"Xuất Google Calendar"**
4. Làm theo các bước tương tự

## Kiểm tra kết quả

1. Mở Google Calendar trên web: https://calendar.google.com
2. Bên trái, tìm calendar mới tạo (tên bạn đã đặt)
3. Click vào để xem các sự kiện
4. Mỗi môn học sẽ lặp lại hàng tuần đến hết học kỳ

## Xử lý lỗi thường gặp

### Lỗi: "Sign in failed"
**Nguyên nhân:** SHA-1 fingerprint không đúng hoặc package name sai

**Giải pháp:**
1. Kiểm tra lại SHA-1 fingerprint
2. Đảm bảo package name trong Google Console khớp với `android/app/build.gradle`
3. Xóa app và cài lại

### Lỗi: "Access denied" hoặc "403"
**Nguyên nhân:** Chưa thêm email vào test users

**Giải pháp:**
1. Vào Google Cloud Console
2. "OAuth consent screen" → "Test users"
3. Thêm email đang dùng để test
4. Thử lại

### Lỗi: "Calendar API has not been used"
**Nguyên nhân:** Chưa bật Calendar API

**Giải pháp:**
1. Vào "APIs & Services" → "Library"
2. Tìm "Google Calendar API"
3. Click "Enable"

### Lỗi: "Invalid client"
**Nguyên nhân:** Web Client ID sai hoặc chưa thêm vào strings.xml

**Giải pháp:**
1. Kiểm tra file `android/app/src/main/res/values/strings.xml`
2. Đảm bảo Web Client ID đúng
3. Clean và rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run --flavor prod
   ```

## Lưu ý quan trọng

1. **Lần đầu sử dụng:** Cần đăng nhập Google và cấp quyền
2. **Mỗi lần xuất:** Tạo 1 calendar mới (không ghi đè)
3. **Xóa calendar:** Phải xóa trên Google Calendar web/app
4. **Offline:** Không thể xuất khi không có mạng
5. **Test users:** Chỉ email trong danh sách test users mới dùng được (nếu app chưa publish)

## Cần hỗ trợ?

- Xem chi tiết: `GOOGLE_CALENDAR_SETUP.md`
- Tài liệu kỹ thuật: `lib/features/export/README.md`
- Google Calendar API: https://developers.google.com/calendar
- Google Sign-In: https://developers.google.com/identity/sign-in/android

## Checklist

- [ ] Đã tạo project trên Google Cloud Console
- [ ] Đã bật Google Calendar API
- [ ] Đã tạo OAuth consent screen
- [ ] Đã thêm test users
- [ ] Đã tạo OAuth client ID cho Android (với SHA-1)
- [ ] Đã tạo OAuth client ID cho Web
- [ ] Đã tạo file `strings.xml` với Web Client ID
- [ ] Đã chạy `flutter pub get`
- [ ] Đã test trên thiết bị thật hoặc emulator
- [ ] Đã đăng nhập Google thành công
- [ ] Đã xuất lịch thành công
- [ ] Đã kiểm tra calendar trên Google Calendar

Chúc bạn thành công! 🎉
