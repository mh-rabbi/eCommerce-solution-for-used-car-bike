class Vehicle {
  final int id;
  final int sellerId;
  final String title;
  final String description;
  final String brand;
  final String type;
  final double price;
  final List<String> images;
  final String status;
  final String? createdAt;
  final Map<String, dynamic>? seller;

  Vehicle({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.brand,
    required this.type,
    required this.price,
    required this.images,
    required this.status,
    this.createdAt,
    this.seller,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      sellerId: json['sellerId'],
      title: json['title'],
      description: json['description'],
      brand: json['brand'],
      type: json['type'],
      price: json['price']?.toDouble() ?? 0.0,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'],
      createdAt: json['createdAt'],
      seller: json['seller'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'brand': brand,
      'type': type,
      'price': price,
      'images': images,
    };
  }
}

