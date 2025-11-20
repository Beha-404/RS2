import 'package:easy_pc/models/cart.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final Map<int, Cart> _items = {};

  Map<int, Cart> get items => {..._items};

  int get itemCount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  bool get isEmpty => _items.isEmpty;

  int get totalPrice {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  List<Cart> get cartItems => _items.values.toList();

  void addItem(int pcId, String name, int price, String? picture) {
    if (_items.containsKey(pcId)) {
      _items.update(
        pcId,
        (existingItem) => Cart(
          pcId: existingItem.pcId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
          picture: existingItem.picture,
        ),
      );
    } else {
      _items.putIfAbsent(
        pcId,
        () => Cart(
          pcId: pcId,
          name: name,
          price: price,
          quantity: 1,
          picture: picture,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(int pcId) {
    if (_items.containsKey(pcId)) {
      _items.update(
        pcId,
        (existingItem) => Cart(
          pcId: existingItem.pcId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
          picture: existingItem.picture,
        ),
      );
      notifyListeners();
    }
  }
  void decrementQuantity(int pcId) {
    if (!_items.containsKey(pcId)) {
      return;
    }
    if (_items[pcId]!.quantity > 1) {
      _items.update(
        pcId,
        (existingItem) => Cart(
          pcId: existingItem.pcId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity - 1,
          picture: existingItem.picture,
        ),
      );
    } else {
      _items.remove(pcId);
    }
    notifyListeners();
  }

  void removeItem(int pcId) {
    _items.remove(pcId);
    notifyListeners();
  }

  void removeSingleItem(int pcId) {
    if (!_items.containsKey(pcId)) {
      return;
    }
    if (_items[pcId]!.quantity > 1) {
      _items.update(
        pcId,
        (existingItem) => Cart(
          pcId: existingItem.pcId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity - 1,
          picture: existingItem.picture,
        ),
      );
    } else {
      _items.remove(pcId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}