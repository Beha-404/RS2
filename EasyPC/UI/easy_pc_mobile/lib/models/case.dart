class Case {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'formFactor': '',
    'manufacturerId': 0,
  };

  final int? id;
  final int? price;
  final int? manufacturerId;
  final String? name;
  final String? formFactor;
  final String? stateMachine;

  const Case({
    this.id,
    this.price,
    this.name,
    this.formFactor,
    this.manufacturerId,
    this.stateMachine,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'] as int?,
      price: json['price'] as int?,
      name: json['name'] as String?,
      formFactor: json['formFactor'] as String?,
      manufacturerId: json['manufacturerId'] as int?,
      stateMachine: json['stateMachine'] as String?,
    );
  }

  factory Case.fromMap(Map<String, dynamic> map) {
    return Case(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      formFactor: map['formFactor'] as String?,
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
    'formFactor': formFactor,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'formFactor': formFactor,
  };
}
