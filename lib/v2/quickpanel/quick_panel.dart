import 'package:flutter/material.dart';
import '../quickpanel/quick_panel_service.dart';

class QuickPanel extends StatelessWidget {
  final String deviceId;

  const QuickPanel({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _ChipGroup(
              scheme: scheme,
              children: [
                _chip(Icons.arrow_back, 'Back', () => QuickPanelService.pressBack(deviceId)),
                _chip(Icons.home_outlined, 'Home', () => QuickPanelService.pressHome(deviceId)),
                _chip(Icons.layers_outlined, 'Recent', () => QuickPanelService.pressRecent(deviceId)),
              ],
            ),
            const SizedBox(height: 8),
            _ChipGroup(
              scheme: scheme,
              children: [
                _chip(Icons.volume_up_outlined, 'Volume Up', () => QuickPanelService.pressVolumeUp(deviceId)),
                _chip(Icons.volume_down_outlined, 'Volume Down', () => QuickPanelService.pressVolumeDown(deviceId)),
                _chip(Icons.play_circle_outlined, 'Play', () => QuickPanelService.mediaPlay(deviceId)),
                _chip(Icons.pause_circle_outlined, 'Pause', () => QuickPanelService.mediaPause(deviceId)),
                _chip(Icons.volume_off_outlined, 'Mute', () => QuickPanelService.volumeMute(deviceId)),
              ],
            ),
            const SizedBox(height: 8),
            _ChipGroup(
              scheme: scheme,
              children: [
                _chip(Icons.settings_outlined, 'Settings', () => QuickPanelService.openSettings(deviceId)),
                _chip(Icons.lock_outlined, 'Lock', () => QuickPanelService.pressPower(deviceId)),
                _chip(Icons.power_settings_new, 'Power', () => QuickPanelService.longPressPower(deviceId)),
                _chip(Icons.camera_alt_outlined, 'Screenshot', () => QuickPanelService.captureScreenshot(deviceId)),
              ],
            ),
            const SizedBox(height: 8),
            _ChipGroup(
              scheme: scheme,
              children: [
                _chip(Icons.grid_view_outlined, 'Quick Settings', () => QuickPanelService.expandQuickSettings(deviceId)),
                _chip(Icons.notifications_outlined, 'Notifications', () => QuickPanelService.expandNotifications(deviceId)),
                _chip(Icons.unfold_less, 'Collapse', () => QuickPanelService.collapseAll(deviceId)),
              ],
            ),
            const SizedBox(height: 8),
            _ChipGroup(
              scheme: scheme,
              children: [
                _chip(Icons.build_outlined, 'Developer', () => QuickPanelService.openDeveloperSettings(deviceId)),
                _ShowTapButton(deviceId: deviceId, scheme: scheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final ColorScheme scheme;
  final List<Widget> children;

  const _ChipGroup({
    required this.scheme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _ShowTapButton extends StatelessWidget {
  final String deviceId;
  final ColorScheme scheme;

  const _ShowTapButton({required this.deviceId, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Show Tap Options',
      offset: const Offset(0, 0),
      icon: const Icon(Icons.touch_app_outlined, size: 16),
      constraints: const BoxConstraints.tightFor(width: 26, height: 26),
      padding: EdgeInsets.zero,
      splashRadius: 13,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'show') {
          QuickPanelService.showTaps(deviceId);
        } else if (value == 'hide') {
          QuickPanelService.hideTaps(deviceId);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'show', child: Text('Show tap dot')),
        const PopupMenuItem(value: 'hide', child: Text('Hide tap dot')),
      ],
    );
  }
}