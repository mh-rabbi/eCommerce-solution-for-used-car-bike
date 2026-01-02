class Payment {
  final int id;
  final int vehicleId;
  final double amount;
  final String status;
  final String? createdAt;
  final Map<String, dynamic>? vehicle;

  Payment({
    required this.id,
    required this.vehicleId,
    required this.amount,
    required this.status,
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
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString(),
      vehicle: json['vehicle'] is Map ? Map<String, dynamic>.from(json['vehicle']) : null,
    );
  }
}

