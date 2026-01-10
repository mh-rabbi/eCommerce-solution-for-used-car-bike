import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vehicle_marketplace/controllers/payment_controller.dart';
import 'package:vehicle_marketplace/controllers/vehicle_controller.dart';


class SellHistoryView extends StatefulWidget {
  const SellHistoryView({super.key});

  @override
  State<SellHistoryView> createState() => _SellHistoryViewState();
}

class _SellHistoryViewState extends State<SellHistoryView> {
  final VehicleController vehicleController = Get.find<VehicleController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  @override
  void initState() {
    super.initState();
    _loadMyVehicles();
  }

  Future<void> _loadMyVehicles() async {
    print('📱 Loading my vehicles...');
    await vehicleController.loadMyVehicles();
    print('📱 My vehicles loaded: ${vehicleController.myVehicles.length} vehicles');
    if (vehicleController.myVehicles.isNotEmpty) {
      print('📱 First vehicle: ${vehicleController.myVehicles.first.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyVehicles,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyVehicles,
        child: Obx(() {
          if (vehicleController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehicleController.myVehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No vehicles posted yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/post-vehicle'),
                    child: const Text('Post Your First Vehicle'),
                  ),
                ],
              ),
            );
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
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
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
                            'BDT ${vehicle.price.toStringAsFixed(2)}',
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
                                  // try {
                                  //   await vehicleController.markAsSold(vehicle.id);
                                  //   final payment = await paymentController.createPayment(vehicle.id);
                                  //   if (payment != null) {
                                  //     Get.toNamed('/payment/${vehicle.id}');
                                  //   }
                                  // } catch (e) {
                                  //   Get.snackbar('Error', 'Failed to process payment: $e');
                                  // }
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
      ),
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

