import 'dart:convert';
import 'package:desktop/config/config.dart';
import 'package:desktop/models/order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  const OrderService();

  Future<Map<String, dynamic>> get({
    int page = 1,
    int pageSize = 10,
    int? userId,
    int? orderId,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };
    
    if (userId != null) {
      queryParams['UserId'] = userId.toString();
    }
    if (orderId != null) {
      queryParams['OrderId'] = orderId.toString();
    }

    final uri = Uri.parse('$apiBaseUrl/api/order/get')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final items = (json['items'] as List)
          .map((item) => Order.fromJson(item))
          .toList();
      
      return {
        'items': items,
        'totalCount': json['totalCount'] ?? 0,
        'page': json['page'] ?? page,
        'pageSize': json['pageSize'] ?? pageSize,
      };
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Order?> getById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/get/$id');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json);
    } else {
      throw Exception('Failed to load order');
    }
  }

  Future<bool> deleteById(int id) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/delete/$id');
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  Future<bool> insert(Order request) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/insert');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> update(Order request) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/update/${request.id}');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    return response.statusCode == 200;
  }
} 