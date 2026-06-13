import 'package:flutter/material.dart';
import 'notification/notification_screen.dart';
import 'control_center/control_center_screen.dart';

enum NotificationShadeTab { notifications, controlCenter }

class NotificationShadeDialog extends StatefulWidget {
  final Rect pillRect;

  const NotificationShadeDialog({super.key, required this.pillRect});

  static void show(BuildContext context, {required Rect pillRect}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notification Shade',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return NotificationShadeDialog(pillRect: pillRect);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _PillToDialogTransition(
          animation: animation,
          pillRect: pillRect,
          child: child,
        );
      },
    );
  }

  @override
  State<NotificationShadeDialog> createState() => _NotificationShadeDialogState();
}

class _PillToDialogTransition extends StatelessWidget {
  final Animation<double> animation;
  final Rect pillRect;
  final Widget child;

  const _PillToDialogTransition({
    required this.animation,
    required this.pillRect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final t = curved.value;

        final screenSize = MediaQuery.of(context).size;
        final dialogSize = Size(
          screenSize.width * 0.7,
          screenSize.height * 0.7,
        );
        final dialogOffset = Offset(
          (screenSize.width - dialogSize.width) / 2,
          (screenSize.height - dialogSize.height) / 2,
        );

        final currentSize = Size.lerp(pillRect.size, dialogSize, t)!;
        final currentOffset = Offset.lerp(
          pillRect.topLeft,
          dialogOffset,
          t,
        )!;
        final borderRadius = BorderRadius.circular(20 + (8 - 20) * t);

        return Stack(
          children: [
            Positioned(
              left: currentOffset.dx,
              top: currentOffset.dy,
              width: currentSize.width,
              height: currentSize.height,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class _NotificationShadeDialogState extends State<NotificationShadeDialog> {
  NotificationShadeTab _selectedTab = NotificationShadeTab.notifications;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: Column(
        children: [
          _buildHeader(context),
          _buildSegmentedButtons(context),
          const Divider(height: 1),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Text('Notification Shade'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 20,
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSegmentedButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<NotificationShadeTab>(
        segments: const [
          ButtonSegment(
            value: NotificationShadeTab.notifications,
            label: Text('Notifications'),
            icon: Icon(Icons.notifications_outlined),
          ),
          ButtonSegment(
            value: NotificationShadeTab.controlCenter,
            label: Text('Control Center'),
            icon: Icon(Icons.settings_outlined),
          ),
        ],
        selected: {_selectedTab},
        onSelectionChanged: (selection) {
          setState(() => _selectedTab = selection.first);
        },
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case NotificationShadeTab.notifications:
        return const NotificationScreen();
      case NotificationShadeTab.controlCenter:
        return const ControlCenterScreen();
    }
  }
}
