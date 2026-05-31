import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/device_manager.dart';
import '../../app_details/screens/app_details_panel.dart';
import 'apps_left_panel.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String? _selectedPackage;

  Future<void> _handleAppAction(String deviceId, String pkg, AppAction action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action.title),
        content: Text('${action.message}\n\nPackage: $pkg'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final args = action.adbArgs(pkg);
    final result = await Process.run('adb', ['-s', deviceId, 'shell'] + args);
    if (!mounted) return;

    final output = result.exitCode == 0 ? 'Done' : result.stderr;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(output)),
    );
  }

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
                    onAppAction: (pair) => _handleAppAction(deviceId, pair.$1, pair.$2),
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
          onAppAction: (pair) => _handleAppAction(deviceId, pair.$1, pair.$2),
        );
      },
    );
  }
}
