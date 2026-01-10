import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/user_service.dart';
import '../sell_history/sell_history_view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        final profileImageUrl = user.profileImage != null
            ? _userService.getProfileImageUrl(user.profileImage)
            : '';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: profileImageUrl.isNotEmpty
                            ? Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(user.email),
                    const SizedBox(height: 8),
                    Chip(label: Text(user.role.toUpperCase())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Address Info (if available)
            if (user.address != null || user.streetNo != null || user.postalCode != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user.address != null && user.address!.isNotEmpty)
                        Text(user.address!),
                      if (user.streetNo != null && user.streetNo!.isNotEmpty)
                        Text('Street No: ${user.streetNo}'),
                      if (user.postalCode != null && user.postalCode!.isNotEmpty)
                        Text('Postal Code: ${user.postalCode}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const EditProfileView()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Sell History'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const SellHistoryView()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                authController.logout();
              },
            ),
          ],
        );
      }),
    );
  }
}

