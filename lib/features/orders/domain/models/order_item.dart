class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productSku;
  final String? productCategory;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;
  
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productCategory,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String?,
      productCategory: json['product_category'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_category': productCategory,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    String? productSku,
    String? productCategory,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productCategory: productCategory ?? this.productCategory,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  String get formattedUnitPrice => 'R\$ ${unitPrice.toStringAsFixed(2)}';
  
  String get formattedTotalPrice => 'R\$ ${totalPrice.toStringAsFixed(2)}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'OrderItem(id: $id, productName: $productName, quantity: $quantity)';
  }
}

