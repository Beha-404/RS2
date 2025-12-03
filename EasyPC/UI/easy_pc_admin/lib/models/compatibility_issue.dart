class CompatibilityIssue {
  final String component;
  final String issue;
  final String severity;
  final String suggestion;

  CompatibilityIssue({
    required this.component,
    required this.issue,
    required this.severity,
    required this.suggestion,
  });

  factory CompatibilityIssue.fromJson(Map<String, dynamic> json) {
    return CompatibilityIssue(
      component: json['component'] as String,
      issue: json['issue'] as String,
      severity: json['severity'] as String,
      suggestion: json['suggestion'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'component': component,
        'issue': issue,
        'severity': severity,
        'suggestion': suggestion,
      };
}
