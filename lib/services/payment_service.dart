import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<Payment> createPayment(int vehicleId) async {
    final response = await _apiService.post('/payments/vehicle/$vehicleId', {});
    return Payment.fromJson(response);
  }

  Future<Payment> confirmPayment(int paymentId) async {
    final response = await _apiService.post('/payments/$paymentId/confirm', {});
    return Payment.fromJson(response);
  }

  Future<Payment?> getPaymentByVehicle(int vehicleId) async {
    try {
      final response = await _apiService.get('/payments/vehicle/$vehicleId');
      return Payment.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

