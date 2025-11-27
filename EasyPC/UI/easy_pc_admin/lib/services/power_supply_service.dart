import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/power_supply.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/utils/auth_helper.dart';
import 'package:desktop/utils/error_parser.dart';
import 'package:http/http.dart' as http;

class PowerSupplyService {
  final UserProvider? userProvider;
  
  const PowerSupplyService({this.userProvider});

  Future<List<PowerSupply>> get() async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/get');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final Map<String, dynamic> pagedResult = jsonDecode(response.body);
      final List<dynamic> items = pagedResult['items'] ?? [];
      return items.map((e) => PowerSupply.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load power supplies');
    }
  }

  Future<PowerSupply?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/get/$id');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PowerSupply.fromJson(json);
    } else {
      throw Exception('Failed to load power supply');
    }
  }

  Future<bool> insert(PowerSupply request) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/insert');
    final response = await http.post(
      uri,
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> update(PowerSupply request) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {...AuthHelper.getAuthHeaders(userProvider), 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(ErrorParser.parseHttpError(response));
    }
  }

  Future<List<String>> getAllowedActions(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/allowedActions/$id');
    final response = await http.get(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    if (response.statusCode == 200) {
      final List<dynamic> actions = jsonDecode(response.body);
      return actions.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<bool> activate(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/activate/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> hide(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/hide/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }

  Future<bool> edit(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/powerSupply/edit/$id');
    final response = await http.put(uri, headers: AuthHelper.getAuthHeaders(userProvider));
    return response.statusCode == 200;
  }
}
