# Technology Stack

## Framework & Language

- Flutter 3.x with Dart 3.0+ (null-safety enabled)
- Target platforms: Android (minSdk 23), iOS (13+), Web

## Core Dependencies

### State Management
- `flutter_riverpod` (2.5.1) - Primary state management
- `riverpod_annotation` with code generation

### Navigation
- `go_router` (13.2.0) - Declarative routing

### Networking
- `dio` (5.4.0) - HTTP client with interceptors

### Storage
- `hive` + `hive_flutter` - Local NoSQL database
- `shared_preferences` - Simple key-value storage

### UI Components
- `table_calendar` (3.0.9) - Calendar widgets (custom WeeklyGrid)
- `intl` - Internationalization and date formatting

### Google Integration (Skeleton)
- `google_sign_in` - OAuth authentication
- `googleapis` + `googleapis_auth` - Calendar API

## Code Generation

Uses `build_runner` for generating:
- Riverpod providers (`riverpod_generator`)
- Hive adapters (`hive_generator`)
- JSON serialization (`json_serializable`)

Run: `flutter pub run build_runner build`

## Linting

Uses `flutter_lints` with custom rules in `analysis_options.yaml`:
- Always declare return types
- Avoid print statements
- Prefer const constructors
- Prefer final fields and locals
- Excludes generated files (*.g.dart, *.freezed.dart)

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run app (development)
flutter run --flavor dev

# Run app (production)
flutter run --flavor prod

# Run on web
flutter run -d chrome

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

## NSGA-II Algorithm Configuration

Located in `lib/services/nsga_optimizer.dart`:
- Population size: 50
- Max generations: 100
- Crossover rate: 0.8
- Mutation rate: 0.1
- Optimization objectives: minimize conflicts, maximize morning ratio, maximize balance, minimize gaps
