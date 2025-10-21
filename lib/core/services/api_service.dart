import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/products/domain/models/product.dart';
import '../../features/orders/domain/models/order.dart';
import '../../features/cart/domain/models/cart_item.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }
  
  String? _getAuthToken() {
    // Get token from storage or auth service
    return null; // Implement based on your auth system
  }
  
  void _handleUnauthorized() {
    // Handle unauthorized access
    // Clear tokens, redirect to login, etc.
  }
  
  // Auth endpoints
  Future<User> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return User.fromJson(response.data);
  }
  
  Future<User> register(String email, String password, String name) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return User.fromJson(response.data);
  }
  
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
  
  // Products endpoints
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    final response = await _dio.get('/products', queryParameters: {
      if (category != null && category != 'Todos') 'category': category,
      if (search != null) 'search': search,
    });
    
    return (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
  
  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data);
  }
  
  Future<List<Product>> getProductCatalog() async {
    final response = await _dio.get('/products/catalog');
    return (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
  
  // Orders endpoints
  Future<List<Order>> getOrders() async {
    final response = await _dio.get('/orders');
    return (response.data as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }
  
  Future<Order> getOrder(String id) async {
    final response = await _dio.get('/orders/$id');
    return Order.fromJson(response.data);
  }
  
  Future<Order> createOrder({
    required String customerId,
    required List<CartItem> items,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
  }) async {
    final response = await _dio.post('/orders', data: {
      'customerId': customerId,
      'items': items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
      }).toList(),
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
      if (billingAddress != null) 'billingAddress': billingAddress,
      if (notes != null) 'notes': notes,
    });
    return Order.fromJson(response.data);
  }
  
  Future<Order> updateOrderStatus(String id, String status) async {
    final response = await _dio.patch('/orders/$id/status', data: {
      'status': status,
    });
    return Order.fromJson(response.data);
  }
  
  Future<void> sendOrderConfirmation(String orderId) async {
    await _dio.post('/orders/$orderId/send-confirmation');
  }
  
  Future<String> exportOrderCSV(String orderId) async {
    final response = await _dio.post('/orders/$orderId/export-csv');
    return response.data['downloadUrl'];
  }
  
  // Analytics endpoints
  Future<Map<String, dynamic>> getSalesAnalytics() async {
    final response = await _dio.get('/orders/analytics');
    return response.data;
  }
  
  Future<List<Order>> getRecentOrders() async {
    final response = await _dio.get('/orders/recent');
    return (response.data as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

