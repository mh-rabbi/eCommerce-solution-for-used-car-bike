import '../config/app_config.dart';
import 'payment.dart';

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
  final Payment? payment;

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
    this.payment,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse price from string or number
    double parsePrice(dynamic priceValue) {
      if (priceValue == null) return 0.0;
      
      if (priceValue is double) {
        return priceValue;
      } else if (priceValue is int) {
        return priceValue.toDouble();
      } else if (priceValue is String) {
        // Remove any currency symbols or commas
        final cleanPrice = priceValue.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanPrice) ?? 0.0;
      } else {
        // Try to convert to string first, then parse
        return double.tryParse(priceValue.toString()) ?? 0.0;
      }
    }

    return Vehicle(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sellerId: json['sellerId'] is int ? json['sellerId'] : int.tryParse(json['sellerId'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      price: parsePrice(json['price']),
      images: json['images'] != null 
          ? (json['images'] is List
              ? List<String>.from(json['images'].map((img) {
                  final String imgStr = img.toString();
                  if (imgStr.startsWith('http')) return imgStr;
                  if (imgStr.startsWith('/')) return '${AppConfig.baseUrl}$imgStr';
                  return '${AppConfig.baseUrl}/$imgStr';
                }))
              : [])
          : [],
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString(),
      seller: json['seller'] is Map ? Map<String, dynamic>.from(json['seller']) : null,
      payment: (json['payments'] is List && (json['payments'] as List).isNotEmpty)
          ? Payment.fromJson((json['payments'] as List).first)
          : null,
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

