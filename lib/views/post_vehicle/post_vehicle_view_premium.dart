import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/vehicle_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/animated_card.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class PostVehicleViewPremium extends StatefulWidget {
  const PostVehicleViewPremium({super.key});

  @override
  State<PostVehicleViewPremium> createState() => _PostVehicleViewPremiumState();
}

class _PostVehicleViewPremiumState extends State<PostVehicleViewPremium> {
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
        
        if (_selectedImages.isNotEmpty) {
          try {
            imageUrls = await _vehicleService.uploadImages(_selectedImages);
          } catch (e) {
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
            
            if (shouldContinue != true) return;
          }
        }

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

        final success = await _vehicleController.createVehicle(vehicle);
        if (success) {
          _titleController.clear();
          _descriptionController.clear();
          _brandController.clear();
          _priceController.clear();
          setState(() {
            _selectedImages = [];
          });
          Get.back();
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to post vehicle: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Vehicle'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview Section
                if (_selectedImages.isNotEmpty)
                  AnimatedCard(
                    index: 0,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                
                const SizedBox(height: AppTheme.spacingMD),
                
                // Upload Button
                AnimatedButton(
                  text: 'Select Images',
                  icon: Icons.add_photo_alternate_rounded,
                  onPressed: _pickImages,
                  width: double.infinity,
                  backgroundColor: AppTheme.accent,
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),
                
                const SizedBox(height: AppTheme.spacingLG),
                
                // Form Fields
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  icon: Icons.title_rounded,
                  delay: 200,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                  delay: 300,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildTextField(
                  controller: _brandController,
                  label: 'Brand',
                  icon: Icons.branding_watermark_rounded,
                  delay: 400,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildTypeDropdown(delay: 500),
                const SizedBox(height: AppTheme.spacingMD),
                _buildTextField(
                  controller: _priceController,
                  label: 'Price',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  delay: 600,
                ),
                const SizedBox(height: AppTheme.spacingXL),
                
                // Submit Button
                Obx(
                  () => AnimatedButton(
                    text: 'Post Vehicle',
                    icon: Icons.send_rounded,
                    onPressed: _submit,
                    isLoading: _vehicleController.isLoading.value,
                    width: double.infinity,
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0, duration: 400.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int delay = 0,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.surface,
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter $label' : null,
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildTypeDropdown({int delay = 0}) {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Type',
        prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.surface,
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
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }
}

