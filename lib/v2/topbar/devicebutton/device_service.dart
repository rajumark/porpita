import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../services/adb_manager.dart';
import '../../../services/device_manager.dart';

class DeviceService extends ChangeNotifier {
  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();
  DeviceService._();

  DeviceManager? _deviceManager;

  void init(DeviceManager deviceManager) {
    _deviceManager = deviceManager;
    deviceManager.addListener(_onDeviceManagerUpdate);
  }

  void _onDeviceManagerUpdate() {
    notifyListeners();
  }

  List<AdbDevice> get devices => _deviceManager?.devices ?? [];
  AdbDevice? get selected => _deviceManager?.selected;
  bool get hasDevices => _deviceManager?.hasDevices ?? false;

  void select(AdbDevice device) {
    _deviceManager?.select(device);
  }

  @override
  void dispose() {
    _deviceManager?.removeListener(_onDeviceManagerUpdate);
    super.dispose();
  }
}
