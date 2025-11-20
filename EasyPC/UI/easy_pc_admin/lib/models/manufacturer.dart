class Manufacturer {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'componentType': '',
  };

  final int? id;
  final String? name;
  final String? componentType;
  final String? stateMachine;

  const Manufacturer({
    this.id,
    this.name,
    this.componentType,
    this.stateMachine,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'] as int?,
      name: json['name'] as String?,
      componentType: json['componentType'] as String?,
      stateMachine: json['stateMachine'] as String?,
    );
  }

  factory Manufacturer.fromMap(Map<String, dynamic> map) {
    return Manufacturer(
      id: map['id'] as int?,
      name: map['name'] as String?,
      componentType: map['componentType'] as String?,
      stateMachine: map['stateMachine'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'componentType': componentType,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'componentType': componentType,
  };
}
