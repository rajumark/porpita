import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../services/device_manager.dart';
import 'wireless_adb_service.dart';
import 'qr_pairing_service.dart';

class WirelessAdbDialog extends StatefulWidget {
  const WirelessAdbDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WirelessAdbService()),
          ChangeNotifierProvider(create: (_) => QrPairingService()),
        ],
        child: const WirelessAdbDialog(),
      ),
    );
  }

  @override
  State<WirelessAdbDialog> createState() => _WirelessAdbDialogState();
}

class _WirelessAdbDialogState extends State<WirelessAdbDialog> {
  WirelessAdbWorkflow _workflow = WirelessAdbWorkflow.android11Plus;
  Android11Tab _android11Tab = Android11Tab.qrCode;

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
    final hasUsbDevice = context.select<DeviceManager, bool>(
      (dm) => dm.physicalDevices.any((d) => d.isConnected && !d.isEmulator),
    );

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
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWorkflowSelector(context),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _workflow == WirelessAdbWorkflow.android11Plus
                    ? _buildAndroid11Content(service, hasUsbDevice)
                    : _buildAndroid10Workflow(service, hasUsbDevice),
              ),
            ),
            if (service.error != null) ...[
              const SizedBox(height: 8),
              _buildOutputBox(context, service.error!, isError: true),
            ],
            if (service.output.isNotEmpty && service.error == null) ...[
              const SizedBox(height: 8),
              _buildOutputBox(context, service.output, isError: false),
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
          context.read<QrPairingService>().reset();
        });
      },
    );
  }

  Widget _buildAndroid11Content(WirelessAdbService service, bool hasUsbDevice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<Android11Tab>(
          segments: const [
            ButtonSegment(value: Android11Tab.qrCode, label: Text('QR Code'), icon: Icon(Icons.qr_code, size: 16)),
            ButtonSegment(value: Android11Tab.inputCode, label: Text('Input Code'), icon: Icon(Icons.keyboard, size: 16)),
          ],
          selected: {_android11Tab},
          onSelectionChanged: (s) {
            setState(() {
              _android11Tab = s.first;
              _step = 0;
            });
            if (s.first == Android11Tab.qrCode) {
              context.read<QrPairingService>().reset();
            } else {
              context.read<QrPairingService>().reset();
            }
          },
        ),
        const SizedBox(height: 16),
        _android11Tab == Android11Tab.qrCode
            ? _buildQrCodeTab()
            : _buildInputCodeTab(service),
      ],
    );
  }

  Widget _buildQrCodeTab() {
    final qrService = context.watch<QrPairingService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(Icons.info_outline, 'On your phone: Developer Options > Wireless Debugging > Pair via QR Code'),
        const SizedBox(height: 12),
        if (qrService.state == QrPairingState.idle || qrService.state == QrPairingState.generating) ...[
          Center(
            child: FilledButton.icon(
              onPressed: () => context.read<QrPairingService>().startQrPairing(),
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
          ),
        ] else if (qrService.state == QrPairingState.waitingForScan) ...[
          Center(
            child: QrImageView(
              data: qrService.qrPayload,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.phone_android, 'Scan this QR code on your phone. Password: ${qrService.password}'),
          const SizedBox(height: 8),
          Center(child: _buildStateIndicator(qrService.state)),
        ] else ...[
          Center(
            child: QrImageView(
              data: qrService.qrPayload,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildStateIndicator(qrService.state),
          if (qrService.pairingOutput.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildOutputBox(context, qrService.pairingOutput, isError: qrService.state == QrPairingState.failed),
          ],
          if (qrService.connectionOutput.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildOutputBox(context, qrService.connectionOutput, isError: false),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.read<QrPairingService>().reset();
                },
                child: const Text('Start Over'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStateIndicator(QrPairingState state) {
    IconData icon;
    String text;
    Color color;

    switch (state) {
      case QrPairingState.waitingForScan:
        icon = Icons.search;
        text = 'Waiting for device to scan QR code...';
        color = Colors.orange;
      case QrPairingState.deviceFound:
        icon = Icons.devices;
        text = 'Device found on network!';
        color = Colors.blue;
      case QrPairingState.pairing:
        icon = Icons.link;
        text = 'Pairing with device...';
        color = Colors.blue;
      case QrPairingState.pairingSuccess:
        icon = Icons.check_circle;
        text = 'Paired successfully!';
        color = Colors.green;
      case QrPairingState.discovering:
        icon = Icons.search;
        text = 'Discovering connection port...';
        color = Colors.orange;
      case QrPairingState.connecting:
        icon = Icons.link;
        text = 'Connecting to device...';
        color = Colors.blue;
      case QrPairingState.connected:
        icon = Icons.check_circle;
        text = 'Connected wirelessly!';
        color = Colors.green;
      case QrPairingState.failed:
        icon = Icons.error;
        text = 'Connection failed';
        color = Colors.red;
      default:
        icon = Icons.hourglass_empty;
        text = 'Preparing...';
        color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
      ],
    );
  }

  Widget _buildInputCodeTab(WirelessAdbService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(Icons.info_outline, 'On your phone: Developer Options > Wireless Debugging > Pair device with pairing code'),
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
          _buildInfoCard(Icons.info_outline, 'The connection port is usually different from the pairing port.'),
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

  Widget _buildOutputBox(BuildContext context, String text, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isError ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: isError ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSurface,
        ),
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

enum WirelessAdbWorkflow { android11Plus, android10AndBelow }

enum Android11Tab { qrCode, inputCode }