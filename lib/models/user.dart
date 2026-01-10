class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? address;
  final String? streetNo;
  final String? postalCode;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.address,
    this.streetNo,
    this.postalCode,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profileImage: json['profileImage'],
      address: json['address'],
      streetNo: json['streetNo'],
      postalCode: json['postalCode'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'streetNo': streetNo,
      'postalCode': postalCode,
      'phone': phone,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? profileImage,
    String? address,
    String? streetNo,
    String? postalCode,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      streetNo: streetNo ?? this.streetNo,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
    );
  }
}

