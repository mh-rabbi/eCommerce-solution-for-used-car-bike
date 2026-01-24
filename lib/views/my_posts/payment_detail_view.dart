import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_marketplace/core/theme/app_theme.dart';
import 'package:vehicle_marketplace/models/vehicle.dart';
import 'package:vehicle_marketplace/services/pdf_service.dart';

class PaymentDetailView extends StatelessWidget {
  const PaymentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get vehicle from arguments
    final Vehicle vehicle = Get.arguments as Vehicle;
    final payment = vehicle.payment;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.shadow1,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: payment == null 
        ? _buildNoPaymentState()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(payment.status),
                const SizedBox(height: 24),
                _buildVehicleSummary(vehicle),
                const SizedBox(height: 24),
                _buildPaymentBreakdown(payment),
                const SizedBox(height: 24),
                _buildTransactionDetails(payment),
                const SizedBox(height: 40),
              ],
            ),
          ),
      bottomNavigationBar: payment != null ? _buildExportButton(vehicle) : null,
    );
  }

  Widget _buildNoPaymentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Payment Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No payment records found for this vehicle.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(String status) {
    bool isPaid = status.toLowerCase() == 'paid';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPaid ? AppTheme.primaryGradient : null,
        color: isPaid ? null : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow2,
      ),
      child: Column(
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isPaid ? 'Payment Received' : 'Payment Pending',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPaid ? 'Your vehicle is active in the marketplace' : 'Complete payment to activate listing',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSummary(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadow1,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: vehicle.images.isNotEmpty
              ? Image.network(vehicle.images.first, width: 80, height: 80, fit: BoxFit.cover)
              : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.directions_car)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${vehicle.brand} · ${vehicle.type.capitalizeFirst}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳ ${vehicle.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown(dynamic payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Payment Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadow1,
          ),
          child: Column(
            children: [
              _buildDetailRow('Vehicle Price', '৳ ${payment.vehiclePrice.toStringAsFixed(0)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDetailRow('Platform Fee (${payment.feePercentage}%)', '৳ ${payment.amount.toStringAsFixed(2)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1.5),
              ),
              _buildDetailRow(
                'Total Amount Paid', 
                '৳ ${payment.amount.toStringAsFixed(2)}',
                isBold: true,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails(dynamic payment) {
    final date = payment.createdAt != null 
        ? DateFormat('MMM dd, yyyy · hh:mm a').format(DateTime.parse(payment.createdAt!).toLocal())
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Transaction Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadow1,
          ),
          child: Column(
            children: [
              _buildDetailRow('Transaction ID', payment.transactionId ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow('Payment Method', payment.paymentMethod ?? 'SSLCommerz'),
              const SizedBox(height: 12),
              _buildDetailRow('Card Type', payment.cardType ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow('Payment Date', date),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => PdfService.generateAndShareInvoice(vehicle),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text(
          'Export PDF Invoice',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
