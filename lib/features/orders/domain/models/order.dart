import 'order_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
  
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.processing:
        return 'Processando';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  static OrderStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final OrderStatus status;
  final double totalAmount;
  final String? shippingAddress;
  final String? billingAddress;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.totalAmount,
    this.shippingAddress,
    this.billingAddress,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      status: OrderStatusExtension.fromString(json['status'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String?,
      billingAddress: json['billing_address'] as String?,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'status': status.value,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    OrderStatus? status,
    double? totalAmount,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  String get formattedTotalAmount => 'R\$ ${totalAmount.toStringAsFixed(2)}';
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  bool get isCompleted => status == OrderStatus.delivered;
  
  bool get isCancelled => status == OrderStatus.cancelled;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $status)';
  }
}

