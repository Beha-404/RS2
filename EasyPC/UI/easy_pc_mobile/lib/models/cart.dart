class Cart {
  final int pcId;
  final String name;
  final int price;
  final int quantity;
  final String? picture;

  Cart({
    required this.pcId,
    required this.name,
    required this.price,
    required this.quantity,
    this.picture,
  });

  int get totalPrice => price * quantity;
}