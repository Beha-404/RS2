class GraphicsCard {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'vram': '',
    'manufacturerId': 0,
  };

  final int? id;
  final int? price;
  final int? manufacturerId;
  final String? name;
  final String? vram;
  final String? stateMachine;

  const GraphicsCard({
    this.id,
    this.price,
    this.name,
    this.vram,
    this.manufacturerId,
    this.stateMachine,
  });

  factory GraphicsCard.fromJson(Map<String, dynamic> json) {
    return GraphicsCard(
      id: json['id'] as int?,
      price: json['price'] as int?,
      name: json['name'] as String?,
      vram: json['vram'] as String?,
      manufacturerId: json['manufacturerId'] as int?,
      stateMachine: json['stateMachine'] as String?,
    );
  }

  factory GraphicsCard.fromMap(Map<String, dynamic> map) {
    return GraphicsCard(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      vram: map['vram'] as String?,
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
    'vram': vram,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'vram': vram,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };
}
