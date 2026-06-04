import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'wireless_adb_service.dart';
import 'wireless_adb_shared_widgets.dart';

class InputCodeTab extends StatefulWidget {
  const InputCodeTab({super.key});

  @override
  State<InputCodeTab> createState() => _InputCodeTabState();
}

class _InputCodeTabState extends State<InputCodeTab> {
  int _step = 0;
  final _pairIpController = TextEditingController();
  final _pairPortController = TextEditingController();
  final _pairCodeController = TextEditingController();
  final _connectIpController = TextEditingController();
  final _connectPortController = TextEditingController();

  @override
  void dispose() {
    _pairIpController.dispose();
    _pairPortController.dispose();
    _pairCodeController.dispose();
    _connectIpController.dispose();
    _connectPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WirelessAdbService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdbInfoCard(icon: Icons.info_outline, text: 'On your phone: Developer Options > Wireless Debugging > Pair device with pairing code'),
        const SizedBox(height: 12),
        Text('Step 1: Pair Device', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        AdbTextField(controller: _pairIpController, label: 'IP Address', hint: '192.168.1.50', enabled: !service.busy),
        const SizedBox(height: 8),
        AdbTextField(controller: _pairPortController, label: 'Pairing Port', hint: '42315', enabled: !service.busy),
        const SizedBox(height: 8),
        AdbTextField(controller: _pairCodeController, label: 'Pairing Code', hint: '123456', enabled: !service.busy, obscure: true),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: service.busy ? null : () async {
              final result = await service.pairDevice(
                _pairIpController.text.trim(),
                _pairPortController.text.trim(),
                _pairCodeController.text.trim(),
              );
              if (result.success) {
                setState(() => _step = 1);
              }
            },
            child: const Text('Pair'),
          ),
        ),
        if (_step >= 1) ...[
          const Divider(height: 24),
          Text('Step 2: Connect Device', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          const AdbInfoCard(icon: Icons.info_outline, text: 'The connection port is usually different from the pairing port.'),
          const SizedBox(height: 8),
          AdbTextField(controller: _connectIpController, label: 'IP Address', hint: '192.168.1.50', enabled: !service.busy),
          const SizedBox(height: 8),
          AdbTextField(controller: _connectPortController, label: 'Connection Port', hint: '39841', enabled: !service.busy),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: service.busy ? null : () async {
                final result = await service.connectDevice(
                  _connectIpController.text.trim(),
                  _connectPortController.text.trim(),
                );
                if (result.success) {
                  setState(() => _step = 2);
                }
              },
              child: const Text('Connect'),
            ),
          ),
        ],
        if (_step >= 2) ...[
          const Divider(height: 24),
          const AdbInfoCard(icon: Icons.check_circle, text: 'Device connected wirelessly! It should now appear in the device list.'),
        ],
      ],
    );
  }
}