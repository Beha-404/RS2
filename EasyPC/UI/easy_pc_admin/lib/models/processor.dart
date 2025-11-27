class Processor {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'threadCount': 0,
    'coreCount': 0,
    'manufacturerId': 0,
    'socket': '',
  };
  final int? id;
  final int? price;
  final int? threadCount;
  final int? coreCount;
  final int? manufacturerId;
  final String? name;
  final String? socket;
  final String? stateMachine;

  const Processor({
    this.id,
    this.price,
    this.threadCount,
    this.coreCount,
    this.manufacturerId,
    this.name,
    this.socket,
    this.stateMachine,
  });

  factory Processor.fromJson(Map<String, dynamic> json) {
    return Processor(
      id: json['id'] as int,
      price: json['price'] as int,
      threadCount: json['threadCount'] as int,
      coreCount: json['coreCount'] as int,
      manufacturerId: json['manufacturerId'] as int,
      name: json['name'] as String,
      socket: json['socket'] as String,
      stateMachine: json['stateMachine'] as String,
    );
  }

  factory Processor.fromMap(Map<String, dynamic> map) {
    return Processor(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      threadCount: map['threadCount'] is String
          ? int.tryParse(map['threadCount'])
          : map['threadCount'] as int?,
      coreCount: map['coreCount'] is String
          ? int.tryParse(map['coreCount'])
          : map['coreCount'] as int?,
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
    'threadCount': threadCount,
    'coreCount': coreCount,
    'manufacturerId': manufacturerId,
    'socket': socket,
    'stateMachine': stateMachine,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'socket': socket,
    'threadCount': threadCount,
    'coreCount': coreCount,
    'manufacturerId': manufacturerId,
    'stateMachine': stateMachine,
  };
}
