import 'package:easy_pc/models/order_details.dart';

class Order {
  final int id;
  final DateTime orderDate;
  final int totalPrice;
  final String? paymentMethod;
  final int userId;
  final List<OrderDetails>? orderDetails;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    this.paymentMethod,
    required this.userId,
    this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return Order(
        id: json['id'],
        orderDate: DateTime.parse(json['orderDate']),
        totalPrice: json['totalPrice'],
        paymentMethod: json['paymentMethod'],
        userId: json['userId'],
        orderDetails: json['orderDetails'] != null
            ? (json['orderDetails'] as List)
                  .map((item) => OrderDetails.fromJson(item))
                  .toList()
            : null,
      );
    } catch (e) {
      throw Exception('Error parsing Order: $e');
    }
  }
}
