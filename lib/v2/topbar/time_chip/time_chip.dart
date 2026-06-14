import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/settings_service.dart';
import 'clock_service.dart';

class TimeChip extends StatefulWidget {
  const TimeChip({super.key});

  @override
  State<TimeChip> createState() => _TimeChipState();
}

class _TimeChipState extends State<TimeChip> {
  final _clockService = ClockService();

  @override
  void initState() {
    super.initState();
    _clockService.start();
  }

  @override
  void dispose() {
    _clockService.stop();
    super.dispose();
  }

  Future<void> _openDateTimeSettings() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;
    await SettingsService.openSetting(deviceId: device.id, intent: 'android.settings.DATE_SETTINGS');
  }

  Future<void> _openClockApp() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;
    await SettingsService.openSetting(deviceId: device.id, intent: 'android.intent.action.SHOW_ALARMS');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockService.stream,
      builder: (context, snapshot) {
        return PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (id) {
            if (id == 'datetime_settings') {
              _openDateTimeSettings();
            } else if (id == 'clock_app') {
              _openClockApp();
            }
          },
          offset: const Offset(0, 36),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'datetime_settings',
              height: 36,
              child: const Row(
                children: [
                  Icon(Icons.schedule, size: 16),
                  SizedBox(width: 8),
                  Text('Date/Time Settings'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'clock_app',
              height: 36,
              child: const Row(
                children: [
                  Icon(Icons.access_alarm, size: 16),
                  SizedBox(width: 8),
                  Text('Clock App'),
                ],
              ),
            ),
          ],
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _clockService.formatHourMinute(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
        );
      },
    );
  }
}