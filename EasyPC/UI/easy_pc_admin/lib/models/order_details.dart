import 'package:desktop/models/pc.dart';

class OrderDetails {
  final int id;
  final int quantity;
  final int unitPrice;
  final int orderId;
  final int pcId;
  final PC? pc;

  const OrderDetails({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.orderId,
    required this.pcId,
    this.pc,
  });

  int get totalPrice => quantity * unitPrice;

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    try {
      return OrderDetails(
        id: json['id'],
        quantity: json['quantity'],
        unitPrice: json['unitPrice'],
        orderId: json['orderId'],
        pcId: json['pcId'],
        pc: json['pc'] != null ? PC.fromJson(json['pc']) : null,
      );
    } catch (e) {
      throw Exception('Error parsing OrderDetails: $e');
    }
  }
}
