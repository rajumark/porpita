import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'lifecycle_events_screen.dart';
import 'lifecycle_app_stats_screen.dart';

class LifecycleBaseScreen extends StatefulWidget {
  const LifecycleBaseScreen({super.key});

  @override
  State<LifecycleBaseScreen> createState() => _LifecycleBaseScreenState();
}

class _LifecycleBaseScreenState extends State<LifecycleBaseScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Column(
          children: [
            Container(
              height: 36,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 0),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? scheme.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Events',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _tabIndex == 0 ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                              fontWeight: _tabIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? scheme.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'App Usage',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _tabIndex == 1 ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                              fontWeight: _tabIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? const LifecycleEventsScreen()
                  : const LifecycleAppStatsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}