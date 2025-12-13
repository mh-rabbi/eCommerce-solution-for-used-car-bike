import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../sell_history/sell_history_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

