import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../models/vehicle.dart';

/// Service for managing WebSocket connections for real-time updates
/// 
/// This service connects to the backend WebSocket server and listens for
/// vehicle-related events like approvals, rejections, and updates.
class SocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  
  // Event callbacks
  Function(Vehicle)? onVehicleApproved;
  Function(int)? onVehicleRejected;
  Function(Vehicle)? onVehicleCreated;
  Function(Vehicle)? onVehicleUpdated;
  Function(int)? onVehicleDeleted;
  Function(Vehicle)? onVehicleSold;

  /// Initialize and connect to the WebSocket server
  Future<SocketService> init() async {
    connect();
    return this;
  }

  /// Connect to the WebSocket server
  void connect() {
    if (_socket != null && _socket!.connected) {
      print('🔌 Socket already connected');
      return;
    }

    final socketUrl = '${AppConfig.baseUrl}/vehicles';
    print('🔌 Connecting to WebSocket: $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );

    _setupListeners();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      print('✅ WebSocket connected');
      isConnected.value = true;
      connectionStatus.value = 'Connected';
    });

    _socket?.onDisconnect((_) {
      print('❌ WebSocket disconnected');
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
    });

    _socket?.onConnectError((error) {
      print('❌ WebSocket connection error: $error');
      isConnected.value = false;
      connectionStatus.value = 'Connection Error';
    });

    _socket?.onError((error) {
      print('❌ WebSocket error: $error');
    });

    _socket?.on('connected', (data) {
      print('🎉 Welcome message: $data');
    });

    _socket?.on('pong', (data) {
      print('🏓 Pong received: $data');
    });

    // Vehicle events
    _socket?.on('vehicle:approved', (data) {
      print('🚗 Vehicle approved event: $data');
      _handleVehicleApproved(data);
    });

    _socket?.on('vehicle:rejected', (data) {
      print('❌ Vehicle rejected event: $data');
      _handleVehicleRejected(data);
    });

    _socket?.on('vehicle:created', (data) {
      print('🆕 Vehicle created event: $data');
      _handleVehicleCreated(data);
    });

    _socket?.on('vehicle:updated', (data) {
      print('✏️ Vehicle updated event: $data');
      _handleVehicleUpdated(data);
    });

    _socket?.on('vehicle:deleted', (data) {
      print('🗑️ Vehicle deleted event: $data');
      _handleVehicleDeleted(data);
    });

    _socket?.on('vehicle:sold', (data) {
      print('💰 Vehicle sold event: $data');
      _handleVehicleSold(data);
    });
  }

  void _handleVehicleApproved(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicleData = data['data'];
        final vehicle = Vehicle.fromJson(vehicleData);
        print('✅ Parsed approved vehicle: ${vehicle.title}');
        onVehicleApproved?.call(vehicle);
      }
    } catch (e) {
      print('❌ Error parsing approved vehicle: $e');
    }
  }

  void _handleVehicleRejected(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicleId = data['data']['vehicleId'] as int;
        onVehicleRejected?.call(vehicleId);
      }
    } catch (e) {
      print('❌ Error parsing rejected vehicle: $e');
    }
  }

  void _handleVehicleCreated(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicle = Vehicle.fromJson(data['data']);
        onVehicleCreated?.call(vehicle);
      }
    } catch (e) {
      print('❌ Error parsing created vehicle: $e');
    }
  }

  void _handleVehicleUpdated(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicle = Vehicle.fromJson(data['data']);
        onVehicleUpdated?.call(vehicle);
      }
    } catch (e) {
      print('❌ Error parsing updated vehicle: $e');
    }
  }

  void _handleVehicleDeleted(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicleId = data['data']['vehicleId'] as int;
        onVehicleDeleted?.call(vehicleId);
      }
    } catch (e) {
      print('❌ Error parsing deleted vehicle: $e');
    }
  }

  void _handleVehicleSold(dynamic data) {
    try {
      if (data != null && data['data'] != null) {
        final vehicle = Vehicle.fromJson(data['data']);
        onVehicleSold?.call(vehicle);
      }
    } catch (e) {
      print('❌ Error parsing sold vehicle: $e');
    }
  }

  /// Send a ping to keep connection alive
  void ping() {
    _socket?.emit('ping');
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    print('🔌 Disconnecting WebSocket...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
  }

  /// Reconnect to the WebSocket server
  void reconnect() {
    disconnect();
    connect();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
