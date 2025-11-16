# VKU Schedule - Flutter App

Ứng dụng Flutter đa nền tảng (Android/iOS/Web) cho lập thời khóa biểu VKU sử dụng thuật toán NSGA-II để tối ưu hóa lịch học.

## Tính năng chính

### 🏠 Trang chủ
- Trang bắt đầu với giao diện thân thiện
- Nút "Bắt đầu" để bắt đầu quy trình tối ưu hóa lịch học

### 📚 Chọn môn học
- Tìm kiếm môn học theo tên hoặc mã môn
- Đăng ký/bỏ đăng ký môn học
- Hiển thị danh sách môn đã chọn

### 💬 Nhập sở thích
- Nhập sở thích bằng tiếng Việt tự nhiên
- Hỗ trợ xử lý ngôn ngữ tự nhiên (NLP)

### ⚖️ Cấu hình trọng số
- 6 sliders để điều chỉnh trọng số cho các tiêu chí:
  - Giảng viên
  - Nhóm lớp
  - Thứ trong tuần
  - Tiết liên tiếp
  - Ngày nghỉ
  - Phòng học

### 🎯 Tối ưu hóa lịch học
- Sử dụng thuật toán NSGA-II để tạo nhiều phương án lịch học
- Tối ưu hóa đa mục tiêu:
  - Giảm thiểu xung đột lịch
  - Tối đa hóa tỷ lệ buổi sáng
  - Cân bằng số buổi học mỗi ngày
  - Giảm thiểu khoảng cách giữa các tiết

### 📋 Danh sách phương án
- Hiển thị tất cả các phương án được tạo
- Sắp xếp theo: điểm số, số xung đột, tỷ lệ buổi sáng, cân bằng
- Lưu phương án yêu thích
- Xem chi tiết từng phương án
- **Lịch sử các lần tạo**: Khi chưa có dữ liệu mới, hiển thị lịch sử các lần tạo trước đó với khả năng mở rộng để xem chi tiết

### 📊 So sánh lịch
- So sánh 2-3 phương án cùng lúc
- Highlight các khác biệt giữa các phương án
- Hiển thị metrics của từng phương án

### 📅 Lịch tuần
- Hiển thị lịch học theo tuần với giao diện đẹp mắt
- Mỗi tiết hiển thị riêng biệt (1-12)
- Hiển thị thời gian cụ thể (7h30, 8h30, 13h, ...)
- Hiển thị ngày trong header
- Các buổi học nhiều tiết được gộp thành một khối
- Tên môn học hiển thị dọc, tự động xuống dòng
- Tap vào buổi học để xem chi tiết
- **Chỉnh sửa lịch đã lưu**:
  - Xóa môn học (long press)
  - Thêm môn học mới (tìm kiếm và nhập thông tin)
  - Lưu thay đổi

### 💾 Lưu và quản lý
- Lưu các phương án yêu thích
- Xem danh sách lịch đã lưu
- Xóa lịch đã lưu
- **Chỉnh sửa lịch đã lưu**: Thêm/xóa môn học và lưu lại

### ⚙️ Cài đặt
- Quản lý thông tin sinh viên
- Cài đặt mặc định
- Xem và quản lý lịch đã lưu
- Xóa dữ liệu
- Đăng xuất

## Công nghệ sử dụng

- **Flutter 3.x** với Dart null-safety
- **State Management**: Riverpod (AsyncNotifierProvider, StateNotifierProvider)
- **Navigation**: GoRouter với authentication guards
- **HTTP Client**: Dio với interceptors và logging
- **Local Storage**: 
  - Hive (cho UserProfile, SavedSchedule, AppSettings)
  - SharedPreferences (cho settings)
- **UI Components**: Material Design 3
- **Date/Time**: intl package cho formatting

## Cấu trúc dự án

```
lib/
├── core/
│   ├── di/                    # Dependency injection (Riverpod providers)
│   ├── network/               # Dio client, interceptors, error handling
│   ├── router/                # GoRouter configuration với auth guards
│   ├── theme/                 # VKU theme (colors, typography)
│   ├── utils/                 # Validators, helpers
│   └── widgets/               # Reusable widgets
│       ├── bottom_nav.dart    # Bottom navigation bar (chỉ icon)
│       ├── weekly_grid.dart   # Weekly timetable grid với merge cells
│       └── subject_card.dart  # Subject selection card
├── features/
│   ├── auth/                  # Authentication (Login)
│   ├── home/                  # Home page (trang bắt đầu)
│   ├── onboarding/            # Onboarding slides
│   ├── semester/              # Semester selection
│   ├── subjects/              # Subject selection với API search
│   ├── preferences/           # NLP preference input
│   ├── weights/               # Weight configuration
│   ├── optimization/          # Optimization processing
│   │   └── providers/
│   │       ├── optimization_provider.dart
│   │       └── optimization_history_provider.dart
│   ├── options/               # Schedule options list
│   │   ├── presentation/
│   │   │   ├── options_list_page.dart
│   │   │   └── option_card.dart
│   │   └── providers/
│   │       ├── chosen_option_provider.dart
│   │       └── saved_schedules_provider.dart
│   ├── comparison/            # Schedule comparison
│   ├── timetable/             # Weekly timetable view
│   │   └── presentation/
│   │       ├── weekly_timetable_page.dart
│   │       └── add_session_page.dart
│   ├── saved_schedules/       # Saved schedules management
│   └── settings/              # Settings & profile
├── models/                    # Data models
│   ├── schedule_option.dart   # Schedule option với metrics
│   ├── session.dart           # Session/class model
│   ├── optimization_history.dart
│   ├── saved_schedule.dart
│   └── ...
├── services/                  # Business logic
│   ├── api_service.dart       # API calls (search, optimize)
│   ├── optimization_service.dart
│   ├── local_storage_service.dart
│   └── auth_service.dart
└── data/                      # Repositories
    └── repositories/
        └── subject_repository.dart
```

## Cài đặt và chạy

### Yêu cầu

- Flutter SDK 3.0.0 trở lên
- Dart 3.0.0 trở lên
- Android Studio / VS Code với Flutter extension
- Android SDK (minSdk 23) hoặc Xcode (iOS 13+)

### Cài đặt dependencies

```bash
flutter pub get
```

### Chạy ứng dụng

```bash
# Development flavor
flutter run --flavor dev

# Production flavor
flutter run --flavor prod

# Build APK
flutter build apk --flavor dev --debug
```

## Cấu hình API

### API Endpoints

Ứng dụng sử dụng các API endpoints sau:

1. **Tìm kiếm môn học**: `POST /api/search-recommend`
   - Request: `{ "query": "tên môn học" }`
   - Response: `{ "query": "...", "results": [...] }`

2. **Tối ưu hóa lịch**: `POST /api/convert`
   - Request: `{ "queries": [...], "prompt": "..." }`
   - Response: `{ "message": "...", "schedules": [...] }`
   - Timeout: 60 giây

### Cấu hình Base URL

Cập nhật base URL trong `lib/core/network/dio_client.dart`:

```dart
// Main API
baseUrl: 'https://your-api-domain.com'

// Optimization API
baseUrl: 'http://20.106.16.223:5000'
```

### Android Configuration

Để cho phép HTTP traffic (cho development), đã thêm vào `AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## Tính năng nổi bật

### 1. Lịch sử các lần tạo

- Tự động lưu mỗi lần chạy optimization
- Hiển thị lịch sử khi chưa có dữ liệu mới
- Expand/collapse để xem chi tiết các phương án
- Mỗi lần tạo hiển thị: ngày giờ, số lượng phương án

### 2. Chỉnh sửa lịch đã lưu

- **Xóa môn học**: Long press vào buổi học → Xác nhận → Xóa
- **Thêm môn học**: 
  - Nhấn nút "Thêm môn học"
  - Tìm kiếm môn học
  - Nhập thông tin lớp học (thứ, tiết, giảng viên, phòng, ...)
  - Kiểm tra xung đột tự động
  - Thêm vào lịch
- **Lưu thay đổi**: Nhấn nút "Lưu" để cập nhật lịch đã lưu

### 3. Giao diện lịch tuần

- Hiển thị từng tiết riêng biệt (1-12)
- Thời gian cụ thể: 7h30, 8h30, ..., 13h, 14h, ...
- Ngày trong header: "Thứ 2\n16"
- Các buổi học nhiều tiết được gộp thành một khối
- Tên môn học hiển thị dọc, tự động xuống dòng khi quá dài
- Chỉ hiển thị tên môn, tap để xem chi tiết

### 4. Bottom Navigation

- 4 tabs: Home, Phương án, Lịch tuần, Cài đặt
- Chỉ hiển thị icon, không có text label
- Navigation mượt mà với GoRouter

## Luồng sử dụng

1. **Bắt đầu**: Vào trang Home → Nhấn "Bắt đầu"
2. **Chọn môn học**: Tìm kiếm và chọn các môn học muốn đăng ký
3. **Nhập sở thích**: Nhập sở thích về lịch học bằng tiếng Việt
4. **Cấu hình trọng số**: Điều chỉnh trọng số cho các tiêu chí
5. **Tối ưu hóa**: Chờ hệ thống tạo các phương án (30-60 giây)
6. **Xem phương án**: Xem danh sách, sắp xếp, lọc các phương án
7. **So sánh**: So sánh 2-3 phương án để chọn tốt nhất
8. **Xem lịch**: Xem lịch tuần chi tiết
9. **Lưu**: Lưu phương án yêu thích
10. **Chỉnh sửa**: Chỉnh sửa lịch đã lưu (thêm/xóa môn học)

## Thuật toán NSGA-II

Thuật toán NSGA-II được sử dụng để tối ưu hóa lịch học:

- **Population size**: 50
- **Max generations**: 100
- **Crossover rate**: 0.8
- **Mutation rate**: 0.1

### Mục tiêu tối ưu hóa

1. **Minimize conflicts**: Giảm thiểu số xung đột lịch học
2. **Maximize morning ratio**: Tối đa hóa tỷ lệ buổi học buổi sáng
3. **Maximize balance**: Cân bằng số buổi học mỗi ngày
4. **Minimize gap score**: Giảm thiểu khoảng cách giữa các tiết học

## Dữ liệu lưu trữ

### Local Storage (Hive)

- **UserProfile**: Thông tin người dùng
- **SavedSchedule**: Các lịch đã lưu
- **AppSettings**: Cài đặt ứng dụng
- **OptimizationHistory**: Lịch sử các lần tạo
- **HistoryOptions**: Các phương án của mỗi lần tạo

### SharedPreferences

- Cài đặt ứng dụng (theme, notifications, ...)

## Branding

### Màu sắc VKU

- **Primary Green**: `#074B2A`
- **Primary Orange**: `#FFA000`
- **Background**: `#FFFFFF`

### Typography

- Font family: Roboto
- Hỗ trợ đầy đủ tiếng Việt

## Phát triển

### Build flavors

- **dev**: Development environment
- **prod**: Production environment

### Debugging

- Logging chi tiết cho API calls
- Logging cho optimization process
- Error handling với thông báo tiếng Việt

## TODO / Tính năng tương lai

### API Integration
- [ ] Tích hợp API lấy danh sách sessions của môn học
- [ ] Cải thiện error handling
- [ ] Retry mechanism cho API calls

### Features
- [ ] Dark mode support
- [ ] Export lịch sang Google Calendar
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Cache subjects data

### Testing
- [ ] Unit tests cho providers
- [ ] Widget tests cho UI components
- [ ] Integration tests cho flow chính

### UI/UX
- [ ] Animations và transitions
- [ ] Responsive design cho tablet
- [ ] Accessibility improvements

## License

Copyright © 2024 VKU

## Contributors

- Development team

---

**Lưu ý**: Ứng dụng đã tích hợp API thực cho tìm kiếm môn học và tối ưu hóa lịch học. Một số tính năng như Google Calendar sync vẫn đang trong quá trình phát triển.
