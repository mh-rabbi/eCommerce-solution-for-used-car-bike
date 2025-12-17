class AppConfig {
  // CRITICAL FIX: Define base URL here instead of in api_service.dart
  // This makes it easier to change and maintain

  // For Android Emulator
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:3000';

  // For Physical Device (use your computer's local IP)
  static const String physicalDeviceBaseUrl = 'http://192.168.0.140:3000';

  // For iOS Simulator
  static const String iosSimulatorBaseUrl = 'http://localhost:3000';

  // ACTIVE BASE URL - Change this based on where you're running
  // Set to androidEmulatorBaseUrl for Android Emulator
  // Set to physicalDeviceBaseUrl for Physical Device
  // Set to iosSimulatorBaseUrl for iOS Simulator
  static const String baseUrl = physicalDeviceBaseUrl; // Change this as needed

  // API Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Validation
  static const int maxImageUploadSize = 10 * 1024 * 1024; // 10MB
  static const int maxImagesPerVehicle = 10;

  // Token expiry buffer (refresh token if expires within this duration)
  static const Duration tokenExpiryBuffer = Duration(minutes: 5);

  // Debug mode
  static const bool isDebugMode = true; // Set to false in production

  // Helper method to log configuration
  static void printConfig() {
    if (isDebugMode) {
      print('=================================');
      print('📱 App Configuration');
      print('🌐 Base URL: $baseUrl');
      print('⏱️  Request Timeout: ${requestTimeout.inSeconds}s');
      print('📤 Upload Timeout: ${uploadTimeout.inMinutes}m');
      print('🖼️  Max Image Size: ${maxImageUploadSize ~/ (1024 * 1024)}MB');
      print('📸 Max Images: $maxImagesPerVehicle');
      print('=================================');
    }
  }
}


