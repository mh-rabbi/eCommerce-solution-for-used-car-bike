import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import '../../controllers/payment_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/animated_card.dart';
import '../../models/payment.dart';
import '../../config/app_config.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final PaymentController _paymentController = Get.find<PaymentController>();
  
  int? vehicleId;
  String? vehicleType;
  double? vehiclePrice;
  String? vehicleTitle;
  
  String? selectedGateway;
  bool isProcessing = false;
  PlatformFee? platformFee;
  Payment? initializedPayment;

  final List<Map<String, dynamic>> gateways = [
    {
      'id': 'sslcommerz',
      'name': 'SSLCommerz',
      'description': 'Pay with Card, Mobile Banking, Net Banking',
      'logo': 'https://apps.odoo.com/web/image/loempia.module/193670/icon_image?unique=c301a64',
      'available': true,
    },
    {
      'id': 'bkash',
      'name': 'bKash',
      'description': 'Pay with bKash Mobile Wallet',
      'logo': 'https://freelogopng.com/images/all_img/1656234841bkash-icon-png.png',
      'available': false, // Not implemented yet
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    // Get vehicle details from arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      vehicleId = args['vehicleId'];
      vehicleType = args['vehicleType'];
      vehiclePrice = args['vehiclePrice']?.toDouble();
      vehicleTitle = args['vehicleTitle'];
    }

    if (vehicleId == null) {
      Get.snackbar('Error', 'Vehicle information not found');
      Get.back();
      return;
    }

    // Calculate platform fee
    final fee = await _paymentController.calculateFee(vehicleId!);
    if (fee != null) {
      setState(() {
        platformFee = fee;
      });
    }
  }

  Future<void> _processPayment() async {
    if (selectedGateway == null) {
      Get.snackbar('Error', 'Please select a payment method');
      return;
    }

    if (vehicleId == null || platformFee == null) {
      Get.snackbar('Error', 'Payment details not loaded');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Initialize payment in backend
      initializedPayment = await _paymentController.initializePayment(
        vehicleId!,
        paymentMethod: selectedGateway,
      );

      if (initializedPayment == null) {
        setState(() {
          isProcessing = false;
        });
        return;
      }

      if (selectedGateway == 'sslcommerz') {
        await _processSSLCommerzPayment();
      } else {
        Get.snackbar('Info', 'This payment method is not available yet');
        setState(() {
          isProcessing = false;
        });
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Payment processing error: $e');
      }
      Get.snackbar('Error', 'Payment failed: ${e.toString()}');
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _processSSLCommerzPayment() async {
    if (platformFee == null || initializedPayment == null) return;

    try {
      if (AppConfig.isDebugMode) {
        print('🔄 Starting SSLCommerz payment...');
        print('Transaction ID: ${initializedPayment!.transactionId}');
        print('Amount: ${platformFee!.platformFee}');
      }

      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: "visa,master,bkash,nagad,rocket",
          currency: SSLCurrencyType.BDT,
          product_category: "Vehicle Advertisement",
          sdkType: SSLCSdkType.TESTBOX, // Use TESTBOX for sandbox testing
          store_id: "store id", // Replace with your store ID
          store_passwd: "sotre pass@ssl", // Replace with your store password
          total_amount: platformFee!.platformFee,
          tran_id: initializedPayment!.transactionId ?? "TXN${DateTime.now().millisecondsSinceEpoch}",
        ),
      );

      final response = await sslcommerz.payNow();

      if (AppConfig.isDebugMode) {
        print('📥 SSLCommerz Response: ${jsonEncode(response)}');
        print('Status: ${response.status}');
      }

      if (response.status == 'VALID') {
        // Payment successful
        if (AppConfig.isDebugMode) {
          print('✅ Payment successful!');
          print('Transaction ID: ${response.tranId}');
          print('Transaction Date: ${response.tranDate}');
        }

        Get.snackbar(
          'Success',
          'Payment completed successfully!',
          backgroundColor: AppTheme.success.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to home
        Get.offAllNamed('/home');
      } else if (response.status == 'Closed') {
        if (AppConfig.isDebugMode) {
          print('⚠️ Payment closed by user');
        }
        Get.snackbar('Cancelled', 'Payment was cancelled');
        setState(() {
          isProcessing = false;
        });
      } else if (response.status == 'FAILED') {
        if (AppConfig.isDebugMode) {
          print('❌ Payment failed');
        }
        Get.snackbar('Failed', 'Payment failed. Please try again.');
        setState(() {
          isProcessing = false;
        });
      } else {
        if (AppConfig.isDebugMode) {
          print('⚠️ Unknown payment status: ${response.status}');
        }
        setState(() {
          isProcessing = false;
        });
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ SSLCommerz error: $e');
      }
      Get.snackbar('Error', 'Payment processing failed: ${e.toString()}');
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: Obx(() {
          if (_paymentController.isLoading.value && platformFee == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Summary Card
                _buildVehicleSummaryCard(),
                const SizedBox(height: AppTheme.spacingLG),

                // Platform Fee Card
                _buildPlatformFeeCard(),
                const SizedBox(height: AppTheme.spacingLG),

                // Fee Explanation
                _buildFeeExplanation(),
                const SizedBox(height: AppTheme.spacingLG),

                // Payment Methods
                _buildPaymentMethodsSection(),
                const SizedBox(height: AppTheme.spacingXL),

                // Pay Button
                _buildPayButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVehicleSummaryCard() {
    return AnimatedCard(
      index: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  vehicleType?.toLowerCase() == 'car'
                      ? Icons.directions_car_rounded
                      : Icons.two_wheeler_rounded,
                  color: AppTheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleTitle ?? 'Vehicle Post',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${vehicleType?.toUpperCase() ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          const Divider(),
          const SizedBox(height: AppTheme.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Listed Price:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                '৳${platformFee?.vehiclePrice.toStringAsFixed(0) ?? vehiclePrice?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPlatformFeeCard() {
    final fee = platformFee;
    
    return AnimatedCard(
      index: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppTheme.accent),
              SizedBox(width: 8),
              Text(
                'Platform Fee',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee Rate (${fee?.vehicleType.toUpperCase() ?? vehicleType?.toUpperCase() ?? 'N/A'}):',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${fee?.feePercentage.toStringAsFixed(0) ?? (vehicleType?.toLowerCase() == 'car' ? '8' : '5')}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: const Text(
                        'Amount to Pay:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '৳${fee?.platformFee.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeeExplanation() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.info, size: 20),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              'Platform fee is charged for vehicle advertisement:\n'
              '• Car: 8% of listed price\n'
              '• Bike: 5% of listed price\n\n'
              'Your vehicle will be visible to buyers after payment.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppTheme.spacingMD),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gateways.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingSM),
          itemBuilder: (context, index) {
            final gateway = gateways[index];
            final isSelected = selectedGateway == gateway['id'];
            final isAvailable = gateway['available'] == true;

            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        selectedGateway = gateway['id'];
                      });
                    }
                  : null,
              child: Opacity(
                opacity: isAvailable ? 1.0 : 0.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? AppTheme.shadow2 : AppTheme.shadow1,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          gateway['logo'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(Icons.payment),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  gateway['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!isAvailable) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Coming Soon',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gateway['description'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.1, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    final isDisabled = selectedGateway == null || isProcessing || platformFee == null;

    return AnimatedButton(
      text: isProcessing ? 'Processing...' : 'Pay ৳${platformFee?.platformFee.toStringAsFixed(2) ?? '0.00'}',
      icon: isProcessing ? Icons.hourglass_top_rounded : Icons.lock_rounded,
      onPressed: isDisabled ? null : _processPayment,
      isLoading: isProcessing,
      width: double.infinity,
      backgroundColor: isDisabled ? Colors.grey : AppTheme.primary,
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
