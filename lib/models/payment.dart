class Payment {
  final int id;
  final int vehicleId;
  final double amount;
  final double vehiclePrice;
  final double feePercentage;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final String? sslTransactionId;
  final String? cardType;
  final String? createdAt;
  final Map<String, dynamic>? vehicle;

  Payment({
    required this.id,
    required this.vehicleId,
    required this.amount,
    this.vehiclePrice = 0.0,
    this.feePercentage = 0.0,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.sslTransactionId,
    this.cardType,
    this.createdAt,
    this.vehicle,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse amount from string or number
    double parseAmount(dynamic amountValue) {
      if (amountValue == null) return 0.0;
      
      if (amountValue is double) {
        return amountValue;
      } else if (amountValue is int) {
        return amountValue.toDouble();
      } else if (amountValue is String) {
        // Remove any currency symbols or commas
        final cleanAmount = amountValue.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanAmount) ?? 0.0;
      } else {
        // Try to convert to string first, then parse
        return double.tryParse(amountValue.toString()) ?? 0.0;
      }
    }

    return Payment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      vehicleId: json['vehicleId'] is int ? json['vehicleId'] : int.tryParse(json['vehicleId'].toString()) ?? 0,
      amount: parseAmount(json['amount']),
      vehiclePrice: parseAmount(json['vehiclePrice']),
      feePercentage: parseAmount(json['feePercentage']),
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      sslTransactionId: json['sslTransactionId']?.toString(),
      cardType: json['cardType']?.toString(),
      createdAt: json['createdAt']?.toString(),
      vehicle: json['vehicle'] is Map ? Map<String, dynamic>.from(json['vehicle']) : null,
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}

class PlatformFee {
  final int vehicleId;
  final String vehicleType;
  final double vehiclePrice;
  final double feePercentage;
  final double platformFee;
  final String currency;

  PlatformFee({
    required this.vehicleId,
    required this.vehicleType,
    required this.vehiclePrice,
    required this.feePercentage,
    required this.platformFee,
    required this.currency,
  });

  factory PlatformFee.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return PlatformFee(
      vehicleId: json['vehicleId'] is int ? json['vehicleId'] : int.tryParse(json['vehicleId'].toString()) ?? 0,
      vehicleType: json['vehicleType']?.toString() ?? '',
      vehiclePrice: parseValue(json['vehiclePrice']),
      feePercentage: parseValue(json['feePercentage']),
      platformFee: parseValue(json['platformFee']),
      currency: json['currency']?.toString() ?? 'BDT',
    );
  }
}

