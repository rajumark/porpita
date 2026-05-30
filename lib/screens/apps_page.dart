import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/device_manager.dart';
import 'apps/app_details_panel.dart';
import 'apps/apps_left_panel.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final deviceId = dm.selected?.id;
    final connected = dm.selected?.isConnected ?? false;

    if (deviceId == null || !connected) {
      return const Center(
        child: Text('Connect a device to view apps'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: 280,
                child: Material(
                  elevation: 1,
                  child: AppsLeftPanel(
                    selectedPackage: _selectedPackage,
                    onPackageSelected: (pkg) {
                      setState(() => _selectedPackage = pkg);
                    },
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: AppDetailsPanel(
                  selectedPackage: _selectedPackage,
                  deviceId: deviceId,
                ),
              ),
            ],
          );
        }

        // Narrow screen: show list or detail
        if (_selectedPackage != null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _selectedPackage = null),
                    ),
                    Expanded(
                      child: Text(
                        _selectedPackage!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AppDetailsPanel(
                  selectedPackage: _selectedPackage,
                  deviceId: deviceId,
                ),
              ),
            ],
          );
        }

        return AppsLeftPanel(
          selectedPackage: _selectedPackage,
          onPackageSelected: (pkg) {
            setState(() => _selectedPackage = pkg);
          },
        );
      },
    );
  }
}
