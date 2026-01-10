import 'package:get/get.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';
import '../config/app_config.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  
  final RxBool isLoading = false.obs;
  final Rx<Payment?> currentPayment = Rx<Payment?>(null);
  final Rx<PlatformFee?> currentFee = Rx<PlatformFee?>(null);

  /// Initialize payment for a vehicle
  Future<Payment?> initializePayment(int vehicleId, {String? paymentMethod}) async {
    try {
      isLoading.value = true;
      if (AppConfig.isDebugMode) {
        print('💳 Initializing payment for vehicle: $vehicleId');
      }
      
      final payment = await _paymentService.initializePayment(
        vehicleId, 
        paymentMethod: paymentMethod,
      );
      currentPayment.value = payment;
      
      if (AppConfig.isDebugMode) {
        print('✅ Payment initialized: ${payment.id}, TxnID: ${payment.transactionId}');
      }
      
      isLoading.value = false;
      return payment;
    } catch (e) {
      isLoading.value = false;
      if (AppConfig.isDebugMode) {
        print('❌ Failed to initialize payment: $e');
      }
      Get.snackbar('Error', 'Failed to initialize payment: ${e.toString()}');
      return null;
    }
  }

  /// Calculate platform fee for a vehicle
  Future<PlatformFee?> calculateFee(int vehicleId) async {
    try {
      isLoading.value = true;
      if (AppConfig.isDebugMode) {
        print('💰 Calculating fee for vehicle: $vehicleId');
      }
      
      final fee = await _paymentService.calculateFee(vehicleId);
      currentFee.value = fee;
      
      if (AppConfig.isDebugMode) {
        print('✅ Fee calculated: ${fee.platformFee} ${fee.currency} (${fee.feePercentage}%)');
      }
      
      isLoading.value = false;
      return fee;
    } catch (e) {
      isLoading.value = false;
      if (AppConfig.isDebugMode) {
        print('❌ Failed to calculate fee: $e');
      }
      Get.snackbar('Error', 'Failed to calculate fee: ${e.toString()}');
      return null;
    }
  }

  /// Confirm payment after successful SSLCommerz transaction
  Future<bool> confirmPayment(int paymentId) async {
    try {
      isLoading.value = true;
      if (AppConfig.isDebugMode) {
        print('✅ Confirming payment: $paymentId');
      }
      
      final payment = await _paymentService.confirmPayment(paymentId);
      currentPayment.value = payment;
      
      isLoading.value = false;
      Get.snackbar('Success', 'Payment confirmed!');
      return true;
    } catch (e) {
      isLoading.value = false;
      if (AppConfig.isDebugMode) {
        print('❌ Failed to confirm payment: $e');
      }
      Get.snackbar('Error', 'Failed to confirm payment: ${e.toString()}');
      return false;
    }
  }

  /// Load payment by vehicle ID
  Future<void> loadPaymentByVehicle(int vehicleId) async {
    try {
      isLoading.value = true;
      final payment = await _paymentService.getPaymentByVehicle(vehicleId);
      currentPayment.value = payment;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      currentPayment.value = null;
    }
  }

  /// Load payment by transaction ID
  Future<Payment?> loadPaymentByTransaction(String transactionId) async {
    try {
      isLoading.value = true;
      final payment = await _paymentService.getPaymentByTransaction(transactionId);
      currentPayment.value = payment;
      isLoading.value = false;
      return payment;
    } catch (e) {
      isLoading.value = false;
      return null;
    }
  }

  /// Reset payment state
  void reset() {
    currentPayment.value = null;
    currentFee.value = null;
  }
}

