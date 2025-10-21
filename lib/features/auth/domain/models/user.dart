import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  factory User.fromSupabaseUser(supabase.User supabaseUser) {
    final userData = supabaseUser.userMetadata ?? {};
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: userData['name'] as String? ?? '',
      phone: userData['phone'] as String?,
      address: userData['address'] as String?,
      city: userData['city'] as String?,
      state: userData['state'] as String?,
      zipCode: userData['zip_code'] as String?,
      country: userData['country'] as String?,
      createdAt: DateTime.parse(supabaseUser.createdAt),
      updatedAt: DateTime.parse(supabaseUser.updatedAt ?? supabaseUser.createdAt),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}

