import 'package:get/get.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  
  final RxBool isLoading = false.obs;
  final Rx<Payment?> currentPayment = Rx<Payment?>(null);

  Future<Payment?> createPayment(int vehicleId) async {
    try {
      isLoading.value = true;
      final payment = await _paymentService.createPayment(vehicleId);
      currentPayment.value = payment;
      isLoading.value = false;
      return payment;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to create payment: ${e.toString()}');
      return null;
    }
  }

  Future<bool> confirmPayment(int paymentId) async {
    try {
      isLoading.value = true;
      await _paymentService.confirmPayment(paymentId);
      isLoading.value = false;
      Get.snackbar('Success', 'Payment confirmed!');
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to confirm payment: ${e.toString()}');
      return false;
    }
  }

  Future<void> loadPaymentByVehicle(int vehicleId) async {
    try {
      final payment = await _paymentService.getPaymentByVehicle(vehicleId);
      currentPayment.value = payment;
    } catch (e) {
      currentPayment.value = null;
    }
  }
}

