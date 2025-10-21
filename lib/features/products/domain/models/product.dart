class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? category;
  final String? sku;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.category,
    this.sku,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      category: json['category'] as String?,
      sku: json['sku'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category': category,
      'sku': sku,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? category,
    String? sku,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  bool get isInStock => stockQuantity > 0;
  
  bool get isLowStock => stockQuantity <= 10 && stockQuantity > 0;
  
  bool get isOutOfStock => stockQuantity == 0;
  
  String get availabilityStatus {
    if (isOutOfStock) return 'out_of_stock';
    if (isLowStock) return 'low_stock';
    return 'in_stock';
  }
  
  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2)}';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}

