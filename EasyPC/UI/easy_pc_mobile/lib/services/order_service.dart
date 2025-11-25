import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  const OrderService();

  Future<Order> createOrder(
    Map<String, dynamic> orderRequest, {
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/insert');
    final credentials = base64Encode(utf8.encode('$username:$password'));
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
      body: jsonEncode(orderRequest),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json);
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }

  Future<List<Order>> getUserOrders(
    int userId, {
    required String username,
    required String password,
  }) async {
    final queryParams = {'UserId': userId.toString()};
    
    final uri = Uri.parse('$apiBaseUrl/api/order/get')
        .replace(queryParameters: queryParams);
    
    final credentials = base64Encode(utf8.encode('$username:$password'));

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final items = json['items'] as List;
      return items.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Order?> getOrderById(
    int orderId, {
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/get/$orderId');
    final credentials = base64Encode(utf8.encode('$username:$password'));
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json);
    } else {
      return null;
    }
  }
}