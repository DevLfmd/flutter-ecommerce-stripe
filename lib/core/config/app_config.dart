class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://cznpntfycapjlnilwpfn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6bnBudGZ5Y2FwamxuaWx3cGZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNDkyNjMsImV4cCI6MjA3NjYyNTI2M30.SGZ363bbH38wr-Auo6HzKMcIlZ6LDIHAUBzD4Po6188';
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String apiVersion = 'v1';
  
  // App Configuration
  static const String appName = 'Escribo E-commerce';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String themeKey = 'theme_mode';
  
  // API Endpoints
  static const String customersEndpoint = '/customers';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration imageCacheExpiration = Duration(days: 7);
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
