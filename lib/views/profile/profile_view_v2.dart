import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../sell_history/sell_history_view.dart';

class ProfileViewV2 extends StatelessWidget {
  const ProfileViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF06A4B4),
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Top Section with Blue Background
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3976B3),
                      Color(0xFF06A4B4),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF06A4B4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // White Card Overlapping
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: 360,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconButton(
                            icon: Icons.history,
                            label: 'Sells History',
                            onTap: () => Get.to(() => const SellHistoryView()),
                          ),
                          _buildIconButton(
                            icon: Icons.notifications,
                            label: 'Notification',
                            onTap: () {},
                          ),
                          _buildIconButton(
                            icon: Icons.add_photo_alternate,
                            label: 'Post Gallery',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      // Detail Rows
                      _buildDetailRow('Password:', 'Change', () {}),
                      _buildDetailRow('Name:', user.name, null),
                      _buildDetailRow('Mobile:', 'N/A', null),
                      _buildDetailRow('Address:', 'N/A', null),
                      _buildDetailRow('PostalCode:', 'N/A', null),
                      const SizedBox(height: 20),
                      // View My All Posts Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.to(() => const SellHistoryView()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077CC),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'View My All Posts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            authController.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06A4B4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF06A4B4)),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF555555),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: onTap != null
                    ? const Color(0xFF0077CC)
                    : const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

