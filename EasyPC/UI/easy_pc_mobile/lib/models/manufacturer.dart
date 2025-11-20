class Manufacturer {
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
