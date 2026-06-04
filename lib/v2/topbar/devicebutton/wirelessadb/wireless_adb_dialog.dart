import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'wireless_adb_service.dart';
import 'qr_pairing_service.dart';
import 'wireless_adb_shared_widgets.dart';
import 'wireless_adb_qr_code_tab.dart';
import 'wireless_adb_input_code_tab.dart';
import 'wireless_adb_android10_tab.dart';

enum Android11Tab { qrCode, inputCode }

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

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WirelessAdbService>();

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
                    ? _buildAndroid11Content()
                    : const Android10Tab(),
              ),
            ),
            if (service.error != null) ...[
              const SizedBox(height: 8),
              AdbOutputBox(text: service.error!, isError: true),
            ],
            if (service.output.isNotEmpty && service.error == null) ...[
              const SizedBox(height: 8),
              AdbOutputBox(text: service.output, isError: false),
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
        });
        context.read<WirelessAdbService>().reset();
        context.read<QrPairingService>().reset();
      },
    );
  }

  Widget _buildAndroid11Content() {
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
            setState(() => _android11Tab = s.first);
            context.read<QrPairingService>().reset();
          },
        ),
        const SizedBox(height: 16),
        _android11Tab == Android11Tab.qrCode
            ? const QrCodeTab()
            : const InputCodeTab(),
      ],
    );
  }
}