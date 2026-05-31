import 'package:flutter/material.dart';
import '../quickpanel/quick_panel_service.dart';

class QuickPanel extends StatelessWidget {
  final String deviceId;

  const QuickPanel({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: scheme.surfaceContainerHighest, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _Button(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              onTap: () => QuickPanelService.pressBack(deviceId),
            ),
            _Button(
              icon: Icons.home_outlined,
              tooltip: 'Home',
              onTap: () => QuickPanelService.pressHome(deviceId),
            ),
            _Button(
              icon: Icons.layers_outlined,
              tooltip: 'Recent Apps',
              onTap: () => QuickPanelService.pressRecent(deviceId),
            ),
            _Divider(),
            _Button(
              icon: Icons.volume_up,
              tooltip: 'Volume Up',
              onTap: () => QuickPanelService.pressVolumeUp(deviceId),
            ),
            _Button(
              icon: Icons.volume_down,
              tooltip: 'Volume Down',
              onTap: () => QuickPanelService.pressVolumeDown(deviceId),
            ),
            _Button(
              icon: Icons.play_arrow,
              tooltip: 'Media Play',
              onTap: () => QuickPanelService.mediaPlay(deviceId),
            ),
            _Button(
              icon: Icons.pause,
              tooltip: 'Media Pause',
              onTap: () => QuickPanelService.mediaPause(deviceId),
            ),
            _Button(
              icon: Icons.volume_off,
              tooltip: 'Volume Mute',
              onTap: () => QuickPanelService.volumeMute(deviceId),
            ),
            _Divider(),
            _Button(
              icon: Icons.settings_outlined,
              tooltip: 'Open Settings',
              onTap: () => QuickPanelService.openSettings(deviceId),
            ),
            _Button(
              icon: Icons.lock_outlined,
              tooltip: 'Screen Lock / Unlock',
              onTap: () => QuickPanelService.pressPower(deviceId),
            ),
            _Button(
              icon: Icons.power_settings_new,
              tooltip: 'Power Long Press',
              onTap: () => QuickPanelService.longPressPower(deviceId),
            ),
            _Button(
              icon: Icons.camera_alt_outlined,
              tooltip: 'Screenshot',
              onTap: () => QuickPanelService.captureScreenshot(deviceId),
            ),
            _Divider(),
            _Button(
              icon: Icons.grid_view_outlined,
              tooltip: 'Quick Settings',
              onTap: () => QuickPanelService.expandQuickSettings(deviceId),
            ),
            _Button(
              icon: Icons.notifications_outlined,
              tooltip: 'Notifications',
              onTap: () => QuickPanelService.expandNotifications(deviceId),
            ),
            _Button(
              icon: Icons.unfold_less,
              tooltip: 'Collapse All',
              onTap: () => QuickPanelService.collapseAll(deviceId),
            ),
            _Divider(),
            _Button(
              icon: Icons.build_outlined,
              tooltip: 'Developer Settings',
              onTap: () => QuickPanelService.openDeveloperSettings(deviceId),
            ),
            _ShowTapButton(deviceId: deviceId),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _Button({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          icon: Icon(icon, size: 18),
          onPressed: onTap,
          padding: EdgeInsets.zero,
          splashRadius: 16,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ShowTapButton extends StatelessWidget {
  final String deviceId;
  const _ShowTapButton({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Show Tap Options',
      offset: const Offset(0, 0),
      icon: Icon(
        Icons.touch_app_outlined,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      splashRadius: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
