import 'dart:convert';
import 'package:easy_pc/models/build_wizard_step.dart';
import 'package:easy_pc/models/build_wizard_state.dart';
import 'package:easy_pc/config/config.dart';
import 'package:http/http.dart' as http;

class BuildWizardService {
  static Future<List<BuildWizardStep>> getWizardSteps() async {
    final url = Uri.parse('$apiBaseUrl/api/BuildWizard/steps');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => BuildWizardStep.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load wizard steps: ${response.statusCode}');
    }
  }

  static Future<BuildWizardState> updateStep({
    required BuildWizardState state,
    required int stepNumber,
    int? componentId,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/BuildWizard/update-step');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'state': state.toJson(),
        'stepNumber': stepNumber,
        'componentId': componentId,
      }),
    );

    if (response.statusCode == 200) {
      return BuildWizardState.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update step: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getFilteredComponents({
    required BuildWizardState state,
    required int stepNumber,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/BuildWizard/filtered-components');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'state': state.toJson(),
        'stepNumber': stepNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to get components: ${response.statusCode}');
    }
  }
}
