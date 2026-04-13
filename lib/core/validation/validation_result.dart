/// Validation result from Guardrails service
class ValidationResult {
  final String severity; // 'ok', 'warn', 'block'
  final String? message;
  final String? suggestion;
  final List<String> issues;

  const ValidationResult._({
    required this.severity,
    this.message,
    this.suggestion,
    this.issues = const [],
  });

  factory ValidationResult.ok() => const ValidationResult._(severity: 'ok');

  factory ValidationResult.warn({
    required String message,
    String? suggestion,
    List<String> issues = const [],
  }) =>
      ValidationResult._(
        severity: 'warn',
        message: message,
        suggestion: suggestion,
        issues: issues,
      );

  factory ValidationResult.block({
    required String message,
    String? suggestion,
    List<String> issues = const [],
  }) =>
      ValidationResult._(
        severity: 'block',
        message: message,
        suggestion: suggestion,
        issues: issues,
      );

  bool get isOk => severity == 'ok';
  bool get isWarn => severity == 'warn';
  bool get isBlock => severity == 'block';
}
