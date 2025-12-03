class BuildWizardStep {
  final int stepNumber;
  final String stepName;
  final String componentType;

  BuildWizardStep({
    required this.stepNumber,
    required this.stepName,
    required this.componentType,
  });

  factory BuildWizardStep.fromJson(Map<String, dynamic> json) {
    return BuildWizardStep(
      stepNumber: json['stepNumber'] as int,
      stepName: json['stepName'] as String,
      componentType: json['componentType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'stepName': stepName,
        'componentType': componentType,
      };
}
