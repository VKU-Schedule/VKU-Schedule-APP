# 🧭 Navigation Guide - VKU Schedule App

## Quy tắc Navigation

### `context.go()` vs `context.push()`

#### ❌ Không dùng `context.go()` khi:
- Navigate từ list item đến detail page
- Muốn user có thể back về trang trước
- Navigate từ modal/dialog

**Lý do:** `context.go()` thay thế toàn bộ navigation stack, không thể back được.

#### ✅ Dùng `context.push()` khi:
- Xem chi tiết từ danh sách
- Mở trang mới từ button/card
- Navigate có thể back

**Lý do:** `context.push()` thêm route lên stack, có thể back bằng nút back.

#### ✅ Dùng `context.go()` khi:
- Navigate giữa các tab chính (bottom nav)
- Reset navigation stack
- Deep link

---

## Các trường hợp trong App

### 1. Options List → Timetable ✅

```dart
// ✅ ĐÚNG - Dùng push
onViewDetails: () {
  ref.read(chosenOptionProvider.notifier).selectOption(option);
  context.push('/timetable');  // User có thể back về options
}

// ❌ SAI - Dùng go
onViewDetails: () {
  ref.read(chosenOptionProvider.notifier).selectOption(option);
  context.go('/timetable');  // Không thể back!
}
```

### 2. Saved Schedules → Timetable ✅

```dart
// ✅ ĐÚNG
onView: () {
  ref.read(chosenOptionProvider.notifier).selectOption(scheduleOption);
  context.push('/timetable');
}
```

### 3. Bottom Navigation ✅

```dart
// ✅ ĐÚNG - Dùng go cho bottom nav
onTap: (index) {
  switch (index) {
    case 0:
      context.go('/home');      // Reset stack
      break;
    case 1:
      context.go('/options');   // Reset stack
      break;
    case 2:
      context.go('/saved-schedules');
      break;
  }
}
```

### 4. Comparison Page ✅

```dart
// ✅ ĐÚNG - Dùng push
onCompare: () {
  context.push('/compare');  // Có thể back
}
```

### 5. Settings → Logout ✅

```dart
// ✅ ĐÚNG - Dùng go để reset
onLogout: () async {
  await ref.read(authProvider.notifier).logout();
  context.go('/login');  // Reset toàn bộ stack
}
```

---

## Navigation Stack Examples

### Scenario 1: Xem lịch từ Options
```
Stack trước:  [Home, Subjects, Options]
Action:       context.push('/timetable')
Stack sau:    [Home, Subjects, Options, Timetable]
Back:         → Options ✅
```

### Scenario 2: Xem lịch từ Options (SAI)
```
Stack trước:  [Home, Subjects, Options]
Action:       context.go('/timetable')
Stack sau:    [Timetable]
Back:         → Exit app ❌
```

### Scenario 3: Bottom Nav
```
Stack trước:  [Home, Detail]
Action:       context.go('/settings')
Stack sau:    [Settings]
Back:         → Exit app ✅ (đúng cho bottom nav)
```

---

## Best Practices

### 1. List → Detail: Luôn dùng `push`
```dart
ListTile(
  onTap: () => context.push('/detail/$id'),
)
```

### 2. Modal → Page: Dùng `push`
```dart
showDialog(
  builder: (context) => AlertDialog(
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);  // Đóng dialog
          context.push('/page');   // Navigate
        },
      ),
    ],
  ),
)
```

### 3. Tab Navigation: Dùng `go`
```dart
BottomNavigationBar(
  onTap: (index) {
    final routes = ['/home', '/search', '/profile'];
    context.go(routes[index]);
  },
)
```

### 4. Deep Link: Dùng `go`
```dart
void handleDeepLink(String path) {
  context.go(path);  // Reset stack và navigate
}
```

---

## Common Mistakes

### ❌ Mistake 1: Dùng `go` cho detail page
```dart
// SAI
onTap: () => context.go('/detail');

// ĐÚNG
onTap: () => context.push('/detail');
```

### ❌ Mistake 2: Dùng `push` cho bottom nav
```dart
// SAI - Stack sẽ tích lũy
onTap: (index) => context.push(routes[index]);

// ĐÚNG
onTap: (index) => context.go(routes[index]);
```

### ❌ Mistake 3: Không pop dialog trước khi navigate
```dart
// SAI
showDialog(
  builder: (context) => AlertDialog(
    actions: [
      TextButton(
        onPressed: () => context.push('/page'),  // Dialog vẫn mở!
      ),
    ],
  ),
)

// ĐÚNG
showDialog(
  builder: (context) => AlertDialog(
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);      // Đóng dialog trước
          context.push('/page');       // Rồi navigate
        },
      ),
    ],
  ),
)
```

---

## Testing Navigation

### Test case 1: Back button
```
1. Navigate: Home → Options → Timetable
2. Press back
3. Expected: Quay về Options ✅
4. Press back again
5. Expected: Quay về Home ✅
```

### Test case 2: Bottom nav
```
1. Navigate: Home → Detail
2. Tap bottom nav "Settings"
3. Expected: Chuyển sang Settings, stack reset ✅
4. Press back
5. Expected: Exit app (hoặc về Home) ✅
```

### Test case 3: Deep link
```
1. Open deep link: /timetable/123
2. Expected: Mở timetable, stack reset ✅
3. Press back
4. Expected: Exit app hoặc về Home ✅
```

---

## Debugging Navigation

### Check current route
```dart
final currentRoute = GoRouterState.of(context).uri.path;
print('Current route: $currentRoute');
```

### Check if can pop
```dart
final canPop = GoRouter.of(context).canPop();
print('Can pop: $canPop');
```

### Print navigation stack
```dart
// Thêm vào GoRouter config
debugLogDiagnostics: true,
```

---

## Summary

| Scenario | Method | Reason |
|----------|--------|--------|
| List → Detail | `push` | Có thể back |
| Card → Detail | `push` | Có thể back |
| Modal → Page | `push` | Có thể back |
| Bottom Nav | `go` | Reset stack |
| Deep Link | `go` | Reset stack |
| Logout | `go` | Reset stack |
| Tab Switch | `go` | Reset stack |

**Golden Rule:** Nếu user cần back về trang trước → dùng `push`, nếu không → dùng `go`

---

## Fixed Issues

✅ **Issue #1:** Options → Timetable không back được
- **Before:** `context.go('/timetable')`
- **After:** `context.push('/timetable')`
- **Files:** `lib/features/options/presentation/options_list_page.dart`

✅ **Issue #2:** History Item → Timetable không back được
- **Before:** `context.go('/timetable')`
- **After:** `context.push('/timetable')`
- **Files:** `lib/features/options/presentation/options_list_page.dart`
