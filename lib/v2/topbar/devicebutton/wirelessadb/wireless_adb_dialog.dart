import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/device_manager.dart';
import 'wireless_adb_service.dart';

class WirelessAdbDialog extends StatefulWidget {
  const WirelessAdbDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => WirelessAdbService(),
        child: const WirelessAdbDialog(),
      ),
    );
  }

  @override
  State<WirelessAdbDialog> createState() => _WirelessAdbDialogState();
}

class _WirelessAdbDialogState extends State<WirelessAdbDialog> {
  WirelessAdbWorkflow _workflow = WirelessAdbWorkflow.android11Plus;

  final _pairIpController = TextEditingController();
  final _pairPortController = TextEditingController();
  final _pairCodeController = TextEditingController();
  final _connectIpController = TextEditingController();
  final _connectPortController = TextEditingController();
  final _tcpIpController = TextEditingController();

  int _step = 0;

  @override
  void dispose() {
    _pairIpController.dispose();
    _pairPortController.dispose();
    _pairCodeController.dispose();
    _connectIpController.dispose();
    _connectPortController.dispose();
    _tcpIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WirelessAdbService>();
    final dm = context.watch<DeviceManager>();
    final hasUsbDevice = dm.physicalDevices.any((d) => d.isConnected && !d.isEmulator);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.wifi, size: 20),
          const SizedBox(width: 8),
          const Text('Wireless ADB'),
          const Spacer(),
          if (service.busy)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWorkflowSelector(context),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _workflow == WirelessAdbWorkflow.android11Plus
                    ? _buildAndroid11Workflow(service)
                    : _buildAndroid10Workflow(service, hasUsbDevice),
              ),
            ),
            if (service.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12),
                ),
              ),
            ],
            if (service.output.isNotEmpty && service.error == null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.output,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildWorkflowSelector(BuildContext context) {
    return SegmentedButton<WirelessAdbWorkflow>(
      segments: const [
        ButtonSegment(value: WirelessAdbWorkflow.android11Plus, label: Text('Android 11+')),
        ButtonSegment(value: WirelessAdbWorkflow.android10AndBelow, label: Text('Android 10-')),
      ],
      selected: {_workflow},
      onSelectionChanged: (s) {
        setState(() {
          _workflow = s.first;
          _step = 0;
          context.read<WirelessAdbService>().reset();
        });
      },
    );
  }

  Widget _buildAndroid11Workflow(WirelessAdbService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(Icons.info_outline, 'On your phone, go to Developer Options > Wireless Debugging > Pair device with pairing code.'),
        const SizedBox(height: 12),
        Text('Step 1: Pair Device', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        _buildTextField(_pairIpController, 'IP Address', '192.168.1.50', enabled: !service.busy),
        const SizedBox(height: 8),
        _buildTextField(_pairPortController, 'Pairing Port', '42315', enabled: !service.busy),
        const SizedBox(height: 8),
        _buildTextField(_pairCodeController, 'Pairing Code', '123456', enabled: !service.busy, obscure: true),
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
          _buildInfoCard(Icons.info_outline, 'The connection port is usually different from the pairing port. Find it on the Wireless Debugging screen.'),
          const SizedBox(height: 8),
          _buildTextField(_connectIpController, 'IP Address', '192.168.1.50', enabled: !service.busy),
          const SizedBox(height: 8),
          _buildTextField(_connectPortController, 'Connection Port', '39841', enabled: !service.busy),
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
          _buildInfoCard(Icons.check_circle, 'Device connected wirelessly! It should now appear in the device list.'),
        ],
      ],
    );
  }

  Widget _buildAndroid10Workflow(WirelessAdbService service, bool hasUsbDevice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(Icons.info_outline, 'Android 10 and below require a USB cable to initialize wireless ADB. Connect your device via USB first.'),
        const SizedBox(height: 12),
        if (!hasUsbDevice) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(child: Text('No USB device detected. Connect your device via USB first.', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text('Step 1: Switch to TCP Mode', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (hasUsbDevice) ...[
          Text('Device: ${context.read<DeviceManager>().physicalDevices.firstWhere((d) => d.isConnected && !d.isEmulator).id}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: service.busy ? null : () async {
                final device = context.read<DeviceManager>().physicalDevices.firstWhere((d) => d.isConnected && !d.isEmulator);
                final result = await service.switchToTcpMode(device.id);
                if (result.success) {
                  setState(() => _step = 1);
                }
              },
              child: const Text('Enable TCP Mode (Port 5555)'),
            ),
          ),
        ],
        if (_step >= 1) ...[
          const Divider(height: 24),
          _buildInfoCard(Icons.cable, 'You can now unplug the USB cable.'),
          const SizedBox(height: 12),
          Text('Step 2: Connect Wirelessly', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          _buildTextField(_tcpIpController, 'Device IP Address', '192.168.1.50', enabled: !service.busy),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: service.busy ? null : () async {
                final result = await service.connectDevice(
                  _tcpIpController.text.trim(),
                  '5555',
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
          _buildInfoCard(Icons.check_circle, 'Device connected wirelessly! It should now appear in the device list.'),
        ],
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool enabled = true, bool obscure = false}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}