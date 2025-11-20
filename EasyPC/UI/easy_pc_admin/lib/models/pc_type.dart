class PcType {
  final int? id;
  final String? name;

  const PcType({
    this.id,
    this.name,
  });

  factory PcType.fromJson(Map<String, dynamic> json) {
    return PcType(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
