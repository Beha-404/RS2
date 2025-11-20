import 'package:easy_pc/models/cart.dart';
import 'package:easy_pc/providers/cart_provider.dart';
import 'package:easy_pc/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

class PaymentPage extends StatelessWidget {
  final String paymentMethod;
  final String address;
  final String city;
  final String postalCode;
  final String notes;
  final List<Cart> cartItems;
  final int totalPrice;
  final int userId;

  const PaymentPage({
    super.key,
    required this.paymentMethod,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.notes,
    required this.cartItems,
    required this.totalPrice,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          paymentMethod,
          style: const TextStyle(color: yellow, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 100,
                color: yellow,
              ),
              const SizedBox(height: 24),
              Text(
                _getTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getDescription(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _processPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getButtonText(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (paymentMethod) {
      case 'PayPal':
        return Icons.paypal;
      case 'CreditCard':
        return Icons.credit_card;
      case 'CashOnDelivery':
        return Icons.local_shipping;
      default:
        return Icons.payment;
    }
  }

  String _getTitle() {
    switch (paymentMethod) {
      case 'PayPal':
        return 'PayPal Payment';
      case 'CreditCard':
        return 'Credit Card Payment';
      case 'CashOnDelivery':
        return 'Cash on Delivery';
      default:
        return 'Payment';
    }
  }

  String _getDescription() {
    switch (paymentMethod) {
      case 'PayPal':
        return 'You will be redirected to PayPal to complete your payment.';
      case 'CreditCard':
        return 'Enter your card details to complete the payment.';
      case 'CashOnDelivery':
        return 'Pay when your order is delivered to your address.';
      default:
        return '';
    }
  }

  String _getButtonText() {
    switch (paymentMethod) {
      case 'PayPal':
        return 'Continue to PayPal';
      case 'CreditCard':
        return 'Enter Card Details';
      case 'CashOnDelivery':
        return 'Confirm Order';
      default:
        return 'Continue';
    }
  }

  Future<void> _processPayment(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: yellow),
      ),
    );

    try {
      final orderRequest = {
        'paymentMethod': paymentMethod,
        'userId': userId,
        'orderDetails': cartItems
            .map((item) => {
                  'pcId': item.pcId,
                  'quantity': item.quantity,
                  'unitPrice': item.price,
                })
            .toList(),
      };

      await OrderService().createOrder(orderRequest);

      if (context.mounted) {
        Provider.of<CartProvider>(context, listen: false).clear();
      }

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Order Placed!', style: TextStyle(color: yellow)),
              ],
            ),
            content: const Text(
              'Your order has been placed successfully. You can view it in Order History.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Text('Error', style: TextStyle(color: Colors.red)),
              ],
            ),
            content: Text(
              'Failed to place order: $e',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: yellow),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}