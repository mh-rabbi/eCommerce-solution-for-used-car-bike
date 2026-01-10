import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_card.dart';
import '../../services/user_service.dart';
import '../sell_history/sell_history_view.dart';
import 'edit_profile_view.dart';

class ProfileViewPremium extends StatefulWidget {
  const ProfileViewPremium({super.key});

  @override
  State<ProfileViewPremium> createState() => _ProfileViewPremiumState();
}

class _ProfileViewPremiumState extends State<ProfileViewPremium> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Refresh user profile when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().refreshUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        final profileImageUrl = user.profileImage != null
            ? _userService.getProfileImageUrl(user.profileImage)
            : '';

        return CustomScrollView(
          slivers: [
            // Collapsible Header
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Image - Circle Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: AppTheme.shadow3,
                          ),
                          child: ClipOval(
                            child: profileImageUrl.isNotEmpty
                                ? Image.network(
                                    profileImageUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.person_rounded,
                                      size: 70,
                                      color: AppTheme.primary,
                                    ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          color: AppTheme.primary,
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 70,
                                    color: AppTheme.primary,
                                  ),
                          ),
                        )
                            .animate()
                            .scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 600.ms),
                        if (user.phone != null && user.phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              user.phone!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 350.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  children: [
                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.history_rounded,
                            label: 'Sell History',
                            color: AppTheme.primary,
                            onTap: () => Get.to(() => const SellHistoryView()),
                            index: 0,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.notifications_rounded,
                            label: 'Notifications',
                            color: AppTheme.accent,
                            onTap: () {},
                            index: 1,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.add_photo_alternate_rounded,
                            label: 'My Posts',
                            color: AppTheme.success,
                            onTap: () => Get.to(() => const SellHistoryView()),
                            index: 2,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Profile Details
                    AnimatedCard(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          _buildDetailRow('Name', user.name, Icons.person_outline),
                          const Divider(),
                          _buildDetailRow('Email', user.email, Icons.email_outlined),
                          if (user.phone != null && user.phone!.isNotEmpty) ...[
                            const Divider(),
                            _buildDetailRow('Phone', user.phone!, Icons.phone_outlined),
                          ],
                          const Divider(),
                          _buildDetailRow('Role', user.role.toUpperCase(), Icons.badge_outlined),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Address Details
                    if (user.address != null || user.streetNo != null || user.postalCode != null)
                      AnimatedCard(
                        index: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMD),
                            if (user.address != null && user.address!.isNotEmpty)
                              _buildDetailRow('Address', user.address!, Icons.location_on_outlined),
                            if (user.streetNo != null && user.streetNo!.isNotEmpty) ...[
                              const Divider(),
                              _buildDetailRow('Street No.', user.streetNo!, Icons.home_outlined),
                            ],
                            if (user.postalCode != null && user.postalCode!.isNotEmpty) ...[
                              const Divider(),
                              _buildDetailRow('Postal Code', user.postalCode!, Icons.markunread_mailbox_outlined),
                            ],
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Action Buttons
                    AnimatedCard(
                      index: 5,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                            title: const Text('Edit Profile'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Get.to(() => const EditProfileView()),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.history_rounded, color: AppTheme.primary),
                            title: const Text('Sell History'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Get.to(() => const SellHistoryView()),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.settings_rounded, color: AppTheme.primary),
                            title: const Text('Settings'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          authController.logout();
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: AppTheme.spacingXL),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

