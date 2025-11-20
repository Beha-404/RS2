class Rating {
  final int? id;
  final int? ratingValue;
  final int? userId;
  final int? pcId;

  const Rating({
    this.id,
    this.ratingValue,
    this.userId,
    this.pcId,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as int?,
      ratingValue: json['ratingValue'] as int?,
      userId: json['userId'] as int?,
      pcId: json['pcId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratingValue': ratingValue,
      'userId': userId,
      'pcId': pcId,
    };
  }
}
