import '../../products/domain/models/product.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final String? productSku;
  final double unitPrice;
  final int quantity;
  final DateTime addedAt;
  
  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.productSku,
    required this.unitPrice,
    required this.quantity,
    required this.addedAt,
  });
  
  factory CartItem.fromProduct(Product product, int quantity) {
    return CartItem(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      productImageUrl: product.imageUrl,
      productSku: product.sku,
      unitPrice: product.price,
      quantity: quantity,
      addedAt: DateTime.now(),
    );
  }
  
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImageUrl: json['product_image_url'] as String?,
      productSku: json['product_sku'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'product_sku': productSku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }
  
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImageUrl,
    String? productSku,
    double? unitPrice,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productSku: productSku ?? this.productSku,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
  
  double get totalPrice => unitPrice * quantity;
  
  String get formattedUnitPrice => 'R\$ ${unitPrice.toStringAsFixed(2)}';
  
  String get formattedTotalPrice => 'R\$ ${totalPrice.toStringAsFixed(2)}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'CartItem(id: $id, productName: $productName, quantity: $quantity)';
  }
}

