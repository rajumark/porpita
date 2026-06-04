import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_pairing_service.dart';
import 'wireless_adb_shared_widgets.dart';

class QrCodeTab extends StatelessWidget {
  const QrCodeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final qrService = context.watch<QrPairingService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdbInfoCard(icon: Icons.info_outline, text: 'On your phone: Developer Options > Wireless Debugging > Pair via QR Code'),
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
          AdbInfoCard(icon: Icons.phone_android, text: 'Scan this QR code on your phone. Password: ${qrService.password}'),
          const SizedBox(height: 8),
          Center(child: _QrStateIndicator(state: qrService.state)),
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
          _QrStateIndicator(state: qrService.state),
          if (qrService.pairingOutput.isNotEmpty) ...[
            const SizedBox(height: 8),
            AdbOutputBox(text: qrService.pairingOutput, isError: qrService.state == QrPairingState.failed),
          ],
          if (qrService.connectionOutput.isNotEmpty) ...[
            const SizedBox(height: 4),
            AdbOutputBox(text: qrService.connectionOutput, isError: false),
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
}

class _QrStateIndicator extends StatelessWidget {
  final QrPairingState state;
  const _QrStateIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
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
}