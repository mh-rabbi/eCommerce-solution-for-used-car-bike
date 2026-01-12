import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/vehicle.dart';
import '../../controllers/favorite_controller.dart';
import '../../services/user_service.dart';
import '../vehicle_list/vehicle_list_view.dart';
import '../favorites/favorites_view.dart';
import '../sell_history/sell_history_view.dart';

class HomeViewPremium extends StatefulWidget {
  const HomeViewPremium({super.key});

  @override
  State<HomeViewPremium> createState() => _HomeViewPremiumState();
}

class _HomeViewPremiumState extends State<HomeViewPremium> with SingleTickerProviderStateMixin {
  late final AnimationController _searchAnimationController;
  late final Animation<double> _searchWidthAnimation;
  late final TextEditingController _searchController;
  
  bool _isSearchExpanded = false;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  bool _isPriceFilterActive = false;
  
  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchWidthAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _searchController = TextEditingController();
    
    // Add listener to update UI when text changes
    _searchController.addListener(() {
      setState(() {});
    });
    
    // Initialize price range from controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleController = Get.find<VehicleController>();
      if (vehicleController.vehicles.isNotEmpty) {
        setState(() {
          _priceRange = RangeValues(
            vehicleController.minVehiclePrice,
            vehicleController.maxVehiclePrice,
          );
        });
      }
    });
  }
  
  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
    if (_isSearchExpanded) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      Get.find<VehicleController>().clearSearch();
    }
  }
  
  void _showPriceFilterSheet() {
    final vehicleController = Get.find<VehicleController>();
    final minPrice = vehicleController.minVehiclePrice;
    final maxPrice = vehicleController.maxVehiclePrice;
    
    // Initialize with current filter values or default to full range
    RangeValues currentRange = RangeValues(
      vehicleController.minPriceFilter.value ?? minPrice,
      vehicleController.maxPriceFilter.value ?? maxPrice,
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXLarge),
              topRight: Radius.circular(AppTheme.radiusXLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Price',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isPriceFilterActive)
                    TextButton(
                      onPressed: () {
                        vehicleController.clearPriceFilter();
                        setState(() {
                          _isPriceFilterActive = false;
                          _priceRange = RangeValues(minPrice, maxPrice);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear Filter',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMD),
              
              // Price range display
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Min Price',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'BDT ${currentRange.start.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSM,
                        vertical: AppTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Text(
                        'to',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Max Price',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'BDT ${currentRange.end.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              
              // Range Slider
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: AppTheme.primary.withOpacity(0.2),
                  thumbColor: AppTheme.primary,
                  overlayColor: AppTheme.primary.withOpacity(0.1),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 4,
                  ),
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                  trackHeight: 6,
                ),
                child: RangeSlider(
                  values: currentRange,
                  min: minPrice,
                  max: maxPrice,
                  divisions: 100,
                  onChanged: (values) {
                    setModalState(() {
                      currentRange = values;
                    });
                  },
                ),
              ),
              
              // Price labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BDT ${minPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'BDT ${maxPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    vehicleController.setPriceRange(
                      currentRange.start,
                      currentRange.end,
                    );
                    setState(() {
                      _priceRange = currentRange;
                      _isPriceFilterActive = true;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppTheme.spacingSM),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    final authController = Get.find<AuthController>();
    vehicleController.loadVehicles();

    return Scaffold(
      drawer: _buildDrawer(context, authController),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Elegant Header
              _buildHeader(context, authController),
              // Vehicle List with Staggered Animation
              Expanded(
                child: _buildVehicleList(context, vehicleController),
              ),
              // Floating Quick Actions
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthController authController) {
    final vehicleController = Get.find<VehicleController>();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingMD,
        AppTheme.spacingLG,
        AppTheme.spacingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: AppTheme.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu Icon - Hidden when search is expanded
              AnimatedBuilder(
                animation: _searchWidthAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_searchWidthAnimation.value * 0.3),
                    child: Opacity(
                      opacity: 1.0 - _searchWidthAnimation.value,
                      child: Builder(
                        builder: (scaffoldContext) => _searchWidthAnimation.value < 0.5
                            ? IconButton(
                                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .scale(delay: 100.ms)
                            : const SizedBox(width: 48),
                      ),
                    ),
                  );
                },
              ),
              
              // Animated Search Bar
              Expanded(
                child: AnimatedBuilder(
                  animation: _searchWidthAnimation,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Search TextField
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            width: _isSearchExpanded
                                ? MediaQuery.of(context).size.width * 0.65
                                : 0,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: _isSearchExpanded
                                ? Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          autofocus: true,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search vehicles...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 15,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onChanged: (value) {
                                            vehicleController.updateSearchQuery(value);
                                          },
                                        ),
                                      ),
                                      // Clear button
                                      if (_searchController.text.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            vehicleController.clearSearch();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      // Filter button
                                      GestureDetector(
                                        onTap: _showPriceFilterSheet,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _isPriceFilterActive
                                                ? AppTheme.primary
                                                : AppTheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.tune_rounded,
                                            color: _isPriceFilterActive
                                                ? Colors.white
                                                : AppTheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Search/Close Icon Button
                        GestureDetector(
                          onTap: _toggleSearch,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isSearchExpanded
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isSearchExpanded
                                  ? Icons.close_rounded
                                  : Icons.search_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                            .animate(target: _isSearchExpanded ? 1 : 0)
                            .rotate(begin: 0, end: 0.5, duration: 300.ms),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Hide greeting when search is expanded
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Obx(() => Text(
                      'Hello, ${authController.currentUser.value?.name ?? "User"} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ))
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0, duration: 600.ms),
                const SizedBox(height: 8),
                const Text(
                  'Find your perfect vehicle',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0, duration: 600.ms),
              ],
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Obx(() {
                final count = vehicleController.filteredVehicles.length;
                final hasFilters = vehicleController.searchQuery.value.isNotEmpty ||
                    _isPriceFilterActive;
                return Text(
                  hasFilters
                      ? '$count vehicle${count != 1 ? 's' : ''} found'
                      : 'Search by name, brand...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ),
            crossFadeState: _isSearchExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(
      BuildContext context, VehicleController vehicleController) {
    return Obx(() {
      if (vehicleController.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          itemCount: 3,
          itemBuilder: (context, index) => const ShimmerVehicleCard(),
        );
      }

      if (vehicleController.filteredVehicles.isEmpty) {
        return EmptyState(
          icon: Icons.directions_car_outlined,
          title: 'No Vehicles Yet',
          message: 'Be the first to list a vehicle!',
          actionLabel: 'Post Vehicle',
          onAction: () => Get.toNamed('/post-vehicle'),
        );
      }

      return AnimationLimiter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid: 2 columns on larger screens, 1 on smaller
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppTheme.spacingMD,
                mainAxisSpacing: AppTheme.spacingMD,
                childAspectRatio: 0.9,
              ),
              itemCount: vehicleController.filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleController.filteredVehicles[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: crossAxisCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildVehicleCard(vehicle),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final favoriteController = Get.find<FavoriteController>();
    favoriteController.checkFavoriteStatus(vehicle.id);

    return AnimatedCard(
      index: 0,
      onTap: () {
        Get.toNamed('/vehicle-detail', arguments: vehicle);
      },
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - Takes up flexible space
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.surfaceVariant,
                    child: vehicle.images.isNotEmpty
                        ? Image.network(
                            vehicle.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.directions_car, size: 40),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadow1,
                      ),
                      child: Obx(() => IconButton(
                        icon: Icon(
                          favoriteController.favoriteStatus[vehicle.id] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                        ),
                        onPressed: () {
                          favoriteController.toggleFavorite(vehicle.id);
                        },
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - Takes up flexible space
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Title - Allow flexible height
                  Flexible(
                    flex: 2,
                    child: Text(
                      vehicle.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Brand and Type - Fixed height
                  SizedBox(
                    height: 16,
                    child: Text(
                      '${vehicle.brand} • ${vehicle.type}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price - Fixed at bottom
                  Text(
                    'BDT ${vehicle.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.success,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.shadow2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(Icons.add_circle, 'Sell', () {
            Get.toNamed('/post-vehicle');
          }),
          Obx(() {
            final vehicleController = Get.find<VehicleController>();
            return _buildQuickAction(
              Icons.directions_car,
              'Cars',
              () => vehicleController.filterByType('car'),
              isSelected: vehicleController.currentFilter.value == 'car',
            );
          }),
          Obx(() {
            final vehicleController = Get.find<VehicleController>();
            return _buildQuickAction(
              Icons.two_wheeler,
              'Bikes',
              () => vehicleController.filterByType('bike'),
              isSelected: vehicleController.currentFilter.value == 'bike',
            );
          }),
          _buildQuickAction(Icons.list, 'All', () {
            final vehicleController = Get.find<VehicleController>();
            vehicleController.showAllVehicles();
          }),
          _buildQuickAction(Icons.favorite, 'Favorites', () {
            Get.toNamed('/favorites');
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    final userService = UserService();
    
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLG,
                60,
                AppTheme.spacingLG,
                AppTheme.spacingLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image - Circle Avatar
                  Obx(() {
                    final user = authController.currentUser.value;
                    final profileImageUrl = user?.profileImage != null
                        ? userService.getProfileImageUrl(user!.profileImage)
                        : '';
                    
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed('/profile');
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: AppTheme.shadow2,
                        ),
                        child: ClipOval(
                          child: profileImageUrl.isNotEmpty
                              ? Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primary,
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primary,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.primary,
                                ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                        authController.currentUser.value?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        authController.currentUser.value?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: AppTheme.spacingLG),
                  children: [
                    _buildDrawerItem(
                      Icons.home_rounded,
                      'Home',
                      () {
                        Get.back();
                        Get.offAllNamed('/home');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.person_rounded,
                      'Profile',
                      () {
                        Get.back();
                        Get.toNamed('/profile');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.notifications_rounded,
                      'Notifications',
                      () {
                        Get.back();
                        Get.toNamed('/checkout');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.history_rounded,
                      'Sell History',
                      () {
                        Get.back();
                        Get.toNamed('/sell-history');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.contact_support_outlined,
                      'Support',
                      () {
                        Get.back();
                        Get.toNamed('/support');
                      },
                    ),
                    const Divider(height: 32),
                    _buildDrawerItem(
                      Icons.logout_rounded,
                      'Logout',
                      () {
                        Get.back();
                        authController.logout();
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }
}

