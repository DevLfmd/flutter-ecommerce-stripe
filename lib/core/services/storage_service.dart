import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

import '../config/app_config.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/cart/domain/models/cart_item.dart';

class StorageService {
  static late Box _box;
  
  static Future<void> init() async {
    _box = await Hive.openBox('escribo_ecommerce');
  }
  
  // User storage
  static Future<void> storeUser(User user) async {
    await _box.put(AppConfig.userDataKey, jsonEncode(user.toJson()));
  }
  
  static User? getUser() {
    final userData = _box.get(AppConfig.userDataKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
  
  static Future<void> clearUser() async {
    await _box.delete(AppConfig.userDataKey);
  }
  
  // Cart storage
  static Future<void> storeCart(List<CartItem> cart) async {
    final cartData = cart.map((item) => item.toJson()).toList();
    await _box.put(AppConfig.cartKey, jsonEncode(cartData));
  }
  
  static List<CartItem> getCart() {
    final cartData = _box.get(AppConfig.cartKey);
    if (cartData != null) {
      final List<dynamic> cartList = jsonDecode(cartData);
      return cartList.map((item) => CartItem.fromJson(item)).toList();
    }
    return [];
  }
  
  static Future<void> clearCart() async {
    await _box.delete(AppConfig.cartKey);
  }
  
  // Theme storage
  static Future<void> storeThemeMode(String themeMode) async {
    await _box.put(AppConfig.themeKey, themeMode);
  }
  
  static String? getThemeMode() {
    return _box.get(AppConfig.themeKey);
  }
  
  // Generic storage methods
  static Future<void> store(String key, dynamic value) async {
    await _box.put(key, value);
  }
  
  static T? get<T>(String key) {
    return _box.get(key);
  }
  
  static Future<void> remove(String key) async {
    await _box.delete(key);
  }
  
  static Future<void> clear() async {
    await _box.clear();
  }
}

