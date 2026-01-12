import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';

class SellerProfileView extends StatelessWidget {
  const SellerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> seller = Get.arguments as Map<String, dynamic>;
    final userService = UserService();

    final String name = seller['name'] ?? 'Seller';
    final String email = seller['email'] ?? '';
    final String? phone = seller['phone'];
    final String? profileImage = seller['profileImage'];
    final String? address = seller['address'];
    final String? streetNo = seller['streetNo'];
    final String? postalCode = seller['postalCode'];
    final String? createdAt = seller['createdAt'];

    final profileImageUrl = profileImage != null
        ? userService.getProfileImageUrl(profileImage)
        : '';

    // Format member since date
    String memberSince = 'Member';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        memberSince = 'Member since ${months[date.month - 1]} ${date.year}';
      } catch (_) {}
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with Profile
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Image
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
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
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
                      // Name
                      Text(
                        name,
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
                      // Member since
                      Text(
                        memberSince,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms),
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
                  // Quick Contact Actions
                  Row(
                    children: [
                      if (phone != null && phone.isNotEmpty) ...[
                        Expanded(
                          child: _buildContactAction(
                            icon: Icons.phone_rounded,
                            label: 'Call',
                            color: AppTheme.success,
                            onTap: () => _makePhoneCall(phone),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSM),
                      ],
                      Expanded(
                        child: _buildContactAction(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          color: AppTheme.primary,
                          onTap: () => _sendEmail(email, name),
                        ),
                      ),
                      if (phone != null && phone.isNotEmpty) ...[
                        const SizedBox(width: AppTheme.spacingSM),
                        Expanded(
                          child: _buildContactAction(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp(phone),
                          ),
                        ),
                      ],
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Contact Information Card
                  _buildInfoCard(
                    title: 'Contact Information',
                    icon: Icons.contact_mail_rounded,
                    children: [
                      _buildInfoRow(Icons.email_outlined, 'Email', email),
                      if (phone != null && phone.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
                      ],
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, duration: 600.ms),

                  // Address Information Card
                  if (address != null || streetNo != null || postalCode != null) ...[
                    const SizedBox(height: AppTheme.spacingMD),
                    _buildInfoCard(
                      title: 'Location',
                      icon: Icons.location_on_rounded,
                      children: [
                        if (address != null && address.isNotEmpty)
                          _buildInfoRow(Icons.home_outlined, 'Address', address),
                        if (streetNo != null && streetNo.isNotEmpty) ...[
                          if (address != null && address.isNotEmpty)
                            const Divider(height: 24),
                          _buildInfoRow(Icons.signpost_outlined, 'Street', streetNo),
                        ],
                        if (postalCode != null && postalCode.isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildInfoRow(Icons.markunread_mailbox_outlined, 'Postal Code', postalCode),
                        ],
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0, duration: 600.ms),
                  ],

                  const SizedBox(height: AppTheme.spacingXL),

                  // Safety Tips Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: AppTheme.warning.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Safety Tips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warning.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSafetyTip('Meet in a public place for transactions'),
                        _buildSafetyTip('Verify the vehicle documents before payment'),
                        _buildSafetyTip('Never share OTP or banking details'),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: AppTheme.warning.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Cannot Make Call',
          'Unable to open phone dialer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make phone call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _sendEmail(String email, String sellerName) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        'subject': 'Inquiry from Gaari Haat',
        'body': 'Hi $sellerName,\n\nI am interested in your vehicle listing on Gaari Haat.\n\nPlease let me know more details.\n\nThank you!',
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'No Email App',
          'Please email the seller at: $email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email app',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters and ensure it has country code
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add Bangladesh country code if not present
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+88$cleanPhone';
      } else if (!cleanPhone.startsWith('88')) {
        cleanPhone = '+88$cleanPhone';
      } else {
        cleanPhone = '+$cleanPhone';
      }
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/${cleanPhone.replaceAll('+', '')}');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'WhatsApp Not Available',
          'Please install WhatsApp or contact the seller directly',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
