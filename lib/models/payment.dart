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
    return Payment(
      id: json['id'],
      vehicleId: json['vehicleId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'],
      createdAt: json['createdAt'],
      vehicle: json['vehicle'],
    );
  }
}

