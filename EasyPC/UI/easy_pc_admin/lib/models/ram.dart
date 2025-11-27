class Ram {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'speed': '',
    'manufacturerId': 0,
  };
  final int? id;
  final int? price;
  final String? name;
  final String? speed;
  final int? manufacturerId;
  final String? stateMachine;

  const Ram({
    this.id,
    this.price,
    this.name,
    this.speed,
    this.manufacturerId,
    this.stateMachine,
  });

  factory Ram.fromJson(Map<String, dynamic> json) {
    return Ram(
      id: json['id'] as int,
      price: json['price'] as int,
      name: json['name'] as String,
      speed: json['speed'] as String,
      manufacturerId: json['manufacturerId'] as int,
      stateMachine: json['stateMachine'] as String,
    );
  }

  factory Ram.fromMap(Map<String, dynamic> map) {
    return Ram(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      speed: map['speed'] as String?,
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
    'speed': speed,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'speed': speed,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };
}
