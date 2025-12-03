import 'compatibility_issue.dart';

class CompatibilityCheckResult {
  final bool isCompatible;
  final List<CompatibilityIssue> issues;
  final int compatibilityScore;
  final int estimatedWattage;
  final int recommendedPsuWattage;
  final String? performanceBottleneck;

  CompatibilityCheckResult({
    required this.isCompatible,
    required this.issues,
    required this.compatibilityScore,
    required this.estimatedWattage,
    required this.recommendedPsuWattage,
    this.performanceBottleneck,
  });

  factory CompatibilityCheckResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityCheckResult(
      isCompatible: json['isCompatible'] as bool,
      issues: (json['issues'] as List<dynamic>)
          .map((e) => CompatibilityIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      compatibilityScore: json['compatibilityScore'] as int,
      estimatedWattage: json['estimatedWattage'] as int,
      recommendedPsuWattage: json['recommendedPsuWattage'] as int,
      performanceBottleneck: json['performanceBottleneck'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'isCompatible': isCompatible,
        'issues': issues.map((e) => e.toJson()).toList(),
        'compatibilityScore': compatibilityScore,
        'estimatedWattage': estimatedWattage,
        'recommendedPsuWattage': recommendedPsuWattage,
        'performanceBottleneck': performanceBottleneck,
      };
}
