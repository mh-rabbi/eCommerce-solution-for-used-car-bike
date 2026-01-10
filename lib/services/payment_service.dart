import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  /// Initialize payment for a vehicle (called after vehicle creation)
  Future<Payment> initializePayment(int vehicleId, {String? paymentMethod}) async {
    final response = await _apiService.post('/payments/initialize', {
      'vehicleId': vehicleId,
      'paymentMethod': paymentMethod ?? 'sslcommerz',
    });
    return Payment.fromJson(response);
  }

  /// Calculate platform fee for a vehicle
  Future<PlatformFee> calculateFee(int vehicleId) async {
    final response = await _apiService.get('/payments/calculate-fee/$vehicleId');
    return PlatformFee.fromJson(response);
  }

  /// Confirm payment after SSLCommerz success
  Future<Payment> confirmPayment(int paymentId) async {
    final response = await _apiService.post('/payments/$paymentId/confirm', {});
    return Payment.fromJson(response);
  }

  /// Get payment by vehicle ID
  Future<Payment?> getPaymentByVehicle(int vehicleId) async {
    try {
      final response = await _apiService.get('/payments/vehicle/$vehicleId');
      return Payment.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get payment by transaction ID
  Future<Payment?> getPaymentByTransaction(String transactionId) async {
    try {
      final response = await _apiService.get('/payments/transaction/$transactionId');
      return Payment.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

