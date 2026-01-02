import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/vehicle_controller.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleId = int.parse(Get.parameters['vehicleId'] ?? '0');
    final paymentController = Get.find<PaymentController>();
    final vehicleController = Get.find<VehicleController>();

    vehicleController.loadVehicle(vehicleId);
    paymentController.loadPaymentByVehicle(vehicleId);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Obx(() {
        final vehicle = vehicleController.selectedVehicle.value;
        final payment = paymentController.currentPayment.value;

        if (vehicle == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final amount = payment?.amount ?? (vehicle.price * 0.1);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${vehicle.brand} • ${vehicle.type}'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Vehicle Price:'),
                          Text(
                            'BDT ${vehicle.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Commission (10%):'),
                          Text(
                            'BDT ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (payment != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Chip(
                            label: Text(
                              payment.status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: payment.status == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (payment == null || payment.status == 'pending')
                ElevatedButton(
                  onPressed: () async {
                    if (payment == null) {
                      final newPayment = await paymentController.createPayment(vehicleId);
                      if (newPayment != null) {
                        Get.snackbar('Success', 'Payment created!');
                      }
                    } else {
                      final success = await paymentController.confirmPayment(payment.id);
                      if (success) {
                        Get.back();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: Obx(() => paymentController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          payment == null
                              ? 'Create Payment'
                              : 'Confirm Payment (Mock)',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        )),
                ),
            ],
          ),
        );
      }),
    );
  }
}

