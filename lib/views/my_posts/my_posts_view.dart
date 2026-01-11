import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vehicle_marketplace/controllers/vehicle_controller.dart';
import 'package:vehicle_marketplace/core/theme/app_theme.dart';
import 'package:vehicle_marketplace/models/vehicle.dart';

class MyPostsView extends StatefulWidget {
  const MyPostsView({super.key});

  @override
  State<MyPostsView> createState() => _MyPostsViewState();
}

class _MyPostsViewState extends State<MyPostsView> with SingleTickerProviderStateMixin {
  final VehicleController vehicleController = Get.find<VehicleController>();
  late TabController _tabController;
  
  final List<String> _tabs = ['All', 'Pending', 'Approved', 'Rejected', 'Sold'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadMyVehicles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyVehicles() async {
    await vehicleController.loadMyVehicles();
  }

  List<Vehicle> _getFilteredVehicles(String filter) {
    final vehicles = vehicleController.myVehicles;
    if (filter == 'All') return vehicles.toList();
    return vehicles.where((v) => v.status.toLowerCase() == filter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          'My Posts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.shadow1,
              ),
              child: const Icon(Icons.refresh, size: 20, color: AppTheme.primary),
            ),
            onPressed: _loadMyVehicles,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: AppTheme.shadow1,
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              indicator: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.all(4),
              tabs: _tabs.map((tab) => Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(tab),
                ),
              )).toList(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyVehicles,
        color: AppTheme.primary,
        child: Obx(() {
          if (vehicleController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) => _buildVehicleList(tab)).toList(),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/post-vehicle'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Vehicle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildVehicleList(String filter) {
    final vehicles = _getFilteredVehicles(filter);

    if (vehicles.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle, index);
      },
    );
  }

  Widget _buildEmptyState(String filter) {
    IconData icon;
    String title;
    String subtitle;

    switch (filter.toLowerCase()) {
      case 'pending':
        icon = Icons.hourglass_empty_rounded;
        title = 'No Pending Vehicles';
        subtitle = 'Your pending vehicle listings will appear here';
        break;
      case 'approved':
        icon = Icons.check_circle_outline_rounded;
        title = 'No Approved Vehicles';
        subtitle = 'Your approved vehicles will appear here';
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        title = 'No Rejected Vehicles';
        subtitle = 'That\'s great! No rejections yet';
        break;
      case 'sold':
        icon = Icons.sell_outlined;
        title = 'No Sold Vehicles';
        subtitle = 'Mark approved vehicles as sold when they sell';
        break;
      default:
        icon = Icons.directions_car_outlined;
        title = 'No Vehicles Posted';
        subtitle = 'Start selling by posting your first vehicle';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (filter == 'All') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/post-vehicle'),
              icon: const Icon(Icons.add),
              label: const Text('Post Your First Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildVehicleCard(Vehicle vehicle, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: vehicle.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vehicle.images.first,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 60, color: Colors.grey),
                        ),
                      ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                left: 12,
                child: _buildStatusBadge(vehicle.status),
              ),
              // Type Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vehicle.type.toLowerCase() == 'car' 
                            ? Icons.directions_car 
                            : Icons.two_wheeler,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.type.capitalize!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.brand,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '৳ ${_formatPrice(vehicle.price)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    // Actions
                    if (vehicle.status == 'approved')
                      _buildMarkAsSoldButton(vehicle),
                  ],
                ),
                // Rejection reason if rejected
                if (vehicle.status == 'rejected')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Contact support for rejection reason',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.error.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = AppTheme.success;
        textColor = Colors.white;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'pending':
        bgColor = AppTheme.warning;
        textColor = Colors.white;
        icon = Icons.hourglass_empty;
        label = 'Pending';
        break;
      case 'rejected':
        bgColor = AppTheme.error;
        textColor = Colors.white;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case 'sold':
        bgColor = AppTheme.info;
        textColor = Colors.white;
        icon = Icons.sell;
        label = 'Sold';
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.help;
        label = status.capitalize!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAsSoldButton(Vehicle vehicle) {
    return Obx(() {
      final isLoading = vehicleController.isLoading.value;
      
      return ElevatedButton.icon(
        onPressed: isLoading ? null : () => _showMarkAsSoldDialog(vehicle),
        icon: isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sell, size: 18),
        label: const Text('Mark Sold'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.info,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      );
    });
  }

  void _showMarkAsSoldDialog(Vehicle vehicle) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sell, color: AppTheme.info),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Mark as Sold',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to mark "${vehicle.title}" as sold?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The vehicle will be removed from the marketplace.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await vehicleController.markAsSold(vehicle.id);
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lac';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}
