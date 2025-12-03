import 'dart:convert';
import 'package:desktop/models/compatibility_check_result.dart';
import 'package:desktop/config/config.dart';
import 'package:http/http.dart' as http;

class CompatibilityService {
  static Future<CompatibilityCheckResult> checkCompatibility({
    int? processorId,
    int? motherboardId,
    int? ramId,
    int? graphicsCardId,
    int? powerSupplyId,
    int? caseId,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/Compatibility/check');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'processorId': processorId,
        'motherboardId': motherboardId,
        'ramId': ramId,
        'graphicsCardId': graphicsCardId,
        'powerSupplyId': powerSupplyId,
        'caseId': caseId,
      }),
    );

    if (response.statusCode == 200) {
      return CompatibilityCheckResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to check compatibility: ${response.statusCode}');
    }
  }
}
