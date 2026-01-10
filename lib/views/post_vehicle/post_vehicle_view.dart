import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class PostVehicleView extends StatefulWidget {
  const PostVehicleView({super.key});

  @override
  State<PostVehicleView> createState() => _PostVehicleViewState();
}

class _PostVehicleViewState extends State<PostVehicleView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final VehicleService _vehicleService = VehicleService();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  String _selectedType = 'car';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = images.map((xFile) => File(xFile.path)).toList();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<String> imageUrls = [];
        
        // Upload images if any selected
        if (_selectedImages.isNotEmpty) {
          try {
            print('Starting image upload for ${_selectedImages.length} images...');
            imageUrls = await _vehicleService.uploadImages(_selectedImages);
            print('Images uploaded successfully: $imageUrls');
          } catch (e) {
            print('Image upload error: $e');
            // Ask user if they want to continue without images
            final shouldContinue = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Image Upload Failed'),
                content: Text('Failed to upload images: ${e.toString()}\n\nDo you want to continue without images?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
            
            if (shouldContinue != true) {
              return; // User cancelled
            }
            // Continue with empty imageUrls
          }
        }

        // Parse price
        double price;
        try {
          price = double.parse(_priceController.text);
        } catch (e) {
          Get.snackbar('Error', 'Invalid price. Please enter a valid number.');
          return;
        }

        final vehicle = Vehicle(
          id: 0,
          sellerId: 0,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          brand: _brandController.text.trim(),
          type: _selectedType,
          price: price,
          images: imageUrls,
          status: 'pending',
        );

        print('Creating vehicle: ${vehicle.title}');
        print('Vehicle data: ${vehicle.toJson()}');
        
        final createdVehicle = await _vehicleController.createVehicle(vehicle);
        if (createdVehicle != null) {
          // Clear form
          _titleController.clear();
          _descriptionController.clear();
          _brandController.clear();
          _priceController.clear();
          setState(() {
            _selectedImages = [];
          });
          
          // Navigate to checkout page with vehicle details
          Get.offNamed('/checkout', arguments: {
            'vehicleId': createdVehicle.id,
            'vehicleType': createdVehicle.type,
            'vehiclePrice': createdVehicle.price,
            'vehicleTitle': createdVehicle.title,
          });
        }
      } catch (e) {
        print('Error in _submit: $e');
        String errorMessage = 'Failed to post vehicle';
        
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = 'Session expired. Please login again.';
        } else if (e.toString().contains('Network') || e.toString().contains('Connection')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        
        Get.snackbar(
          'Error', 
          errorMessage,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter brand' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['car', 'bike'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Pick Images'),
              ),
              const SizedBox(height: 16),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              Obx(() => _vehicleController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Post Vehicle'),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

