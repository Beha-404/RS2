import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  const OrderService();

  Future<Order> createOrder(Map<String, dynamic> orderRequest) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/insert');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderRequest),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json);
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }

  Future<List<Order>> getUserOrders(int userId) async {
    final queryParams = {'UserId': userId.toString()};
    
    final uri = Uri.parse('$apiBaseUrl/api/order/get')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final items = json['items'] as List;
      return items.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<Order?> getOrderById(int orderId) async {
    final uri = Uri.parse('$apiBaseUrl/api/order/get/$orderId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json);
    } else {
      return null;
    }
  }
}