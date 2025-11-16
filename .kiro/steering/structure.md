# Project Structure

## Architecture Pattern

Feature-first architecture with clean separation of concerns:
- `core/` - Shared infrastructure and utilities
- `features/` - Feature modules with presentation and business logic
- `models/` - Data models shared across features
- `services/` - Business logic and algorithms
- `data/` - Repositories and data sources

## Directory Layout

```
lib/
├── core/
│   ├── di/              # Dependency injection (Riverpod providers)
│   ├── network/         # Dio client, interceptors
│   ├── router/          # GoRouter configuration
│   ├── theme/           # VKU theme (colors, typography)
│   ├── utils/           # Validators, helpers
│   └── widgets/         # Reusable widgets (AppBar, BottomNav, WeeklyGrid, SubjectCard)
│
├── features/            # Feature modules
│   ├── auth/
│   ├── onboarding/
│   ├── semester/
│   ├── subjects/
│   ├── preferences/
│   ├── weights/
│   ├── optimization/
│   ├── options/
│   ├── comparison/
│   ├── timetable/
│   ├── save_sync/
│   └── settings/
│
├── models/              # Domain models
│   ├── preference_constraints.dart
│   ├── schedule_option.dart
│   ├── session.dart
│   ├── subject.dart
│   └── weights.dart
│
├── services/            # Business logic
│   ├── calendar_sync_service.dart
│   ├── nlp_service.dart
│   ├── nsga_optimizer.dart
│   └── optimization_service.dart
│
├── data/                # Data layer
│   └── repositories/
│
└── main.dart            # App entry point
```

## Feature Module Structure

Each feature follows this pattern:
```
feature_name/
├── presentation/        # UI components (pages, widgets)
└── providers/          # Riverpod state providers
```

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants
- Private members: prefix with `_`

## State Management Pattern

- Use `StateNotifierProvider` for mutable state
- Use `Provider` for immutable services/repositories
- Use `FutureProvider` for async initialization
- State classes use `copyWith` pattern for immutability

## Model Conventions

- All models have `fromJson` and `toJson` methods
- Use required named parameters
- Prefer immutability (final fields)
- Use null-safety appropriately

## Widget Conventions

- Prefer `const` constructors where possible
- Extract reusable widgets to `core/widgets/`
- Feature-specific widgets stay in feature's `presentation/` folder
- Use `key` parameter for stateful widgets

## Service Layer

- Services are stateless and provided via Riverpod
- Business logic lives in services, not in providers
- Services return Future for async operations
- Use dependency injection for testability
