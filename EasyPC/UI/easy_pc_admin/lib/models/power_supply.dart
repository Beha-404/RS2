class PowerSupply {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'power': '',
    'manufacturerId': 0,
  };
  final int? id;
  final int? price;
  final int? manufacturerId;
  final String? name;
  final String? power;
  final String? stateMachine;

  const PowerSupply({
    this.id,
    this.price,
    this.name,
    this.power,
    this.manufacturerId,
    this.stateMachine,
  });

  factory PowerSupply.fromJson(Map<String, dynamic> json) {
    return PowerSupply(
      id: json['id'] as int,
      price: json['price'] as int,
      name: json['name'] as String,
      power: json['power'] as String,
      manufacturerId: json['manufacturerId'] as int,
      stateMachine: json['stateMachine'] as String,
    );
  }

  factory PowerSupply.fromMap(Map<String, dynamic> map) {
    return PowerSupply(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      power: map['power'] as String?,
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
    'power': power,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'power': power,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };
}
