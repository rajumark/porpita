import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'media_model.dart';
import 'media_list_screen.dart';
import 'media_details_sheet.dart';

class MediaBaseScreen extends StatefulWidget {
  const MediaBaseScreen({super.key});

  @override
  State<MediaBaseScreen> createState() => _MediaBaseScreenState();
}

class _MediaBaseScreenState extends State<MediaBaseScreen> {
  void _handleEntrySelected(MediaEntry entry) {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      useSafeArea: true,
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 460,
          height: double.infinity,
          child: MediaDetailsSheet(
            entry: entry,
            deviceId: device.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: MediaListScreen(onEntrySelected: _handleEntrySelected),
      ),
    );
  }
}
