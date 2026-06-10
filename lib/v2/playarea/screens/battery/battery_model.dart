class BatteryInfo {
  final bool acPowered;
  final bool usbPowered;
  final bool wirelessPowered;
  final bool dockPowered;
  final int status;
  final String statusLabel;
  final int health;
  final String healthLabel;
  final bool present;
  final int level;
  final int scale;
  final int voltage;
  final int temperature;
  final String technology;
  final int chargingState;
  final int chargingPolicy;
  final int capacityLevel;
  final int? maxChargingCurrent;
  final int? maxChargingVoltage;
  final int? chargeCounter;
  final Map<String, String> raw;

  const BatteryInfo({
    required this.acPowered,
    required this.usbPowered,
    required this.wirelessPowered,
    required this.dockPowered,
    required this.status,
    required this.statusLabel,
    required this.health,
    required this.healthLabel,
    required this.present,
    required this.level,
    required this.scale,
    required this.voltage,
    required this.temperature,
    required this.technology,
    required this.chargingState,
    required this.chargingPolicy,
    required this.capacityLevel,
    this.maxChargingCurrent,
    this.maxChargingVoltage,
    this.chargeCounter,
    required this.raw,
  });

  static const Map<int, String> _statusLabels = {
    1: 'Unknown',
    2: 'Charging',
    3: 'Discharging',
    4: 'Not charging',
    5: 'Full',
  };

  static const Map<int, String> _healthLabels = {
    1: 'Unknown',
    2: 'Good',
    3: 'Overheat',
    4: 'Dead',
    5: 'Over voltage',
    6: 'Unspecified failure',
    7: 'Cold',
  };

  static String _statusFor(int value) =>
      _statusLabels[value] ?? 'Unknown';

  static String _healthFor(int value) =>
      _healthLabels[value] ?? 'Unknown';

  factory BatteryInfo.fromMap(Map<String, String> map) {
    return BatteryInfo(
      acPowered: map['AC powered'] == 'true',
      usbPowered: map['USB powered'] == 'true',
      wirelessPowered: map['Wireless powered'] == 'true',
      dockPowered: map['Dock powered'] == 'true',
      status: int.tryParse(map['status'] ?? '') ?? 0,
      statusLabel: _statusFor(int.tryParse(map['status'] ?? '') ?? 0),
      health: int.tryParse(map['health'] ?? '') ?? 0,
      healthLabel: _healthFor(int.tryParse(map['health'] ?? '') ?? 0),
      present: map['present'] == 'true',
      level: int.tryParse(map['level'] ?? '') ?? 0,
      scale: int.tryParse(map['scale'] ?? '') ?? 100,
      voltage: int.tryParse(map['voltage'] ?? '') ?? 0,
      temperature: int.tryParse(map['temperature'] ?? '') ?? 0,
      technology: map['technology'] ?? '',
      chargingState: int.tryParse(map['Charging state'] ?? '') ?? 0,
      chargingPolicy: int.tryParse(map['Charging policy'] ?? '') ?? 0,
      capacityLevel: int.tryParse(map['Capacity level'] ?? '') ?? -1,
      maxChargingCurrent: int.tryParse(map['Max charging current'] ?? '') ?? 0,
      maxChargingVoltage: int.tryParse(map['Max charging voltage'] ?? '') ?? 0,
      chargeCounter: int.tryParse(map['Charge counter'] ?? '') ?? 0,
      raw: map,
    );
  }

  factory BatteryInfo.fromRawOutput(String output) {
    final map = <String, String>{};
    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex < 0) continue;
      final key = trimmed.substring(0, colonIndex).trim();
      final value = trimmed.substring(colonIndex + 1).trim();
      if (key.isEmpty) continue;
      map[key] = value;
    }
    return BatteryInfo.fromMap(map);
  }
}