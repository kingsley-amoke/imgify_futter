class ProStatus {
  final bool isPro;
  final DateTime? purchaseDate;
  final String? purchaseToken;
  final String? productId;

  const ProStatus({
    this.isPro = false,
    this.purchaseDate,
    this.purchaseToken,
    this.productId,
  });

  factory ProStatus.fromJson(Map<String, dynamic> json) {
    return ProStatus(
      isPro: json['isPro'] ?? false,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      purchaseToken: json['purchaseToken'],
      productId: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPro': isPro,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchaseToken': purchaseToken,
      'productId': productId,
    };
  }

  ProStatus copyWith({
    bool? isPro,
    DateTime? purchaseDate,
    String? purchaseToken,
    String? productId,
  }) {
    return ProStatus(
      isPro: isPro ?? this.isPro,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
    );
  }
}
