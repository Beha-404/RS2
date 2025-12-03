import 'compatibility_check_result.dart';

class BuildWizardState {
  int currentStep;
  int? pcTypeId;
  int? processorId;
  int? motherboardId;
  int? ramId;
  int? graphicsCardId;
  int? powerSupplyId;
  int? caseId;
  int? estimatedPrice;
  CompatibilityCheckResult? compatibilityCheck;

  BuildWizardState({
    this.currentStep = 1,
    this.pcTypeId,
    this.processorId,
    this.motherboardId,
    this.ramId,
    this.graphicsCardId,
    this.powerSupplyId,
    this.caseId,
    this.estimatedPrice,
    this.compatibilityCheck,
  });

  factory BuildWizardState.fromJson(Map<String, dynamic> json) {
    return BuildWizardState(
      currentStep: json['currentStep'] as int,
      pcTypeId: json['pcTypeId'] as int?,
      processorId: json['processorId'] as int?,
      motherboardId: json['motherboardId'] as int?,
      ramId: json['ramId'] as int?,
      graphicsCardId: json['graphicsCardId'] as int?,
      powerSupplyId: json['powerSupplyId'] as int?,
      caseId: json['caseId'] as int?,
      estimatedPrice: json['estimatedPrice'] as int?,
      compatibilityCheck: json['compatibilityCheck'] != null
          ? CompatibilityCheckResult.fromJson(
              json['compatibilityCheck'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStep': currentStep,
        'pcTypeId': pcTypeId,
        'processorId': processorId,
        'motherboardId': motherboardId,
        'ramId': ramId,
        'graphicsCardId': graphicsCardId,
        'powerSupplyId': powerSupplyId,
        'caseId': caseId,
        'estimatedPrice': estimatedPrice,
        'compatibilityCheck': compatibilityCheck?.toJson(),
      };

  bool get isComplete =>
      processorId != null &&
      motherboardId != null &&
      ramId != null &&
      graphicsCardId != null &&
      powerSupplyId != null &&
      caseId != null;
}
