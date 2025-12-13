import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/vehicle_controller.dart';
import '../../controllers/payment_controller.dart';

class SellHistoryView extends StatelessWidget {
  const SellHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    final paymentController = Get.find<PaymentController>();
    vehicleController.loadMyVehicles();

    return Scaffold(
      appBar: AppBar(title: const Text('Sell History')),
      body: Obx(() {
        if (vehicleController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vehicleController.myVehicles.isEmpty) {
          return const Center(child: Text('No vehicles posted yet'));
        }

        return ListView.builder(
          itemCount: vehicleController.myVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleController.myVehicles[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicle.images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: vehicle.images.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${vehicle.brand} • ${vehicle.type}'),
                        const SizedBox(height: 8),
                        Text(
                          '\$${vehicle.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(vehicle.status.toUpperCase()),
                          backgroundColor: _getStatusColor(vehicle.status),
                        ),
                        if (vehicle.status == 'approved' || vehicle.status == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              onPressed: () async {
                                await vehicleController.markAsSold(vehicle.id);
                                final payment = await paymentController.createPayment(vehicle.id);
                                if (payment != null) {
                                  Get.toNamed('/payment/${vehicle.id}');
                                }
                              },
                              child: const Text('Mark as Sold'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'sold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

