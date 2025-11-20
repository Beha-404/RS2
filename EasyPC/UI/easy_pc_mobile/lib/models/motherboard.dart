class MotherBoard {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'socket': '',
    'manufacturerId': 0,
  };
  final int? id;
  final int? price;
  final int? manufacturerId;
  final String? name;
  final String? socket;
  final String? stateMachine;

  const MotherBoard({
    this.id,
    this.price,
    this.name,
    this.socket,
    this.manufacturerId,
    this.stateMachine,
  });

  factory MotherBoard.fromJson(Map<String, dynamic> json) {
    return MotherBoard(
      id: json['id'] as int,
      price: json['price'] as int,
      name: json['name'] as String,
      socket: json['socket'] as String,
      manufacturerId: json['manufacturerId'] as int,
      stateMachine: json['stateMachine'] as String,
    );
  }

  factory MotherBoard.fromMap(Map<String, dynamic> map) {
    return MotherBoard(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      socket: map['socket'] as String?,
      manufacturerId: map['manufacturerId'] is String
          ? int.tryParse(map['manufacturerId'])
          : map['manufacturerId'] as int?,
      stateMachine: map['stateMachine'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'price': price,
    'name': name,
    'socket': socket,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'socket': socket,
  };
}
