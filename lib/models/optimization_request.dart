/// Request model for schedule optimization API
/// Sent to the backend server for NSGA-II optimization
class OptimizationRequest {
  final List<String> queries;
  final String prompt;

  OptimizationRequest({
    required this.queries,
    required this.prompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'queries': queries,
      'prompt': prompt,
    };
  }

  factory OptimizationRequest.fromJson(Map<String, dynamic> json) {
    return OptimizationRequest(
      queries: (json['queries'] as List<dynamic>)
          .map((q) => q as String)
          .toList(),
      prompt: json['prompt'] as String,
    );
  }

  @override
  String toString() =>
      'OptimizationRequest(queries: ${queries.length}, prompt: ${prompt.length} chars)';
}
