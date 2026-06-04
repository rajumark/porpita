import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'ui_inspector_service.dart';

class UiInspectorScreen extends StatefulWidget {
  const UiInspectorScreen({super.key});

  @override
  State<UiInspectorScreen> createState() => _UiInspectorScreenState();
}

class _UiInspectorScreenState extends State<UiInspectorScreen> {
  UiInspectorResult? _result;
  bool _loading = false;
  String? _lastDeviceId;

  Future<void> _refresh(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);

    final result = await UiInspectorService.fetch(deviceId);

    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
        _lastDeviceId = deviceId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device == null || !device.isConnected) {
      return const Center(child: Text('Connect a device to inspect UI'));
    }

    if (_lastDeviceId != device.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh(device.id));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Column(
          children: [
            _buildToolbar(device.id),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(String deviceId) {
    final foregroundApp = _result?.foregroundApp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (foregroundApp != null) ...[
            Icon(Icons.open_in_browser, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${foregroundApp.packageName} — ${foregroundApp.activityName.split('.').last}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            const Expanded(child: SizedBox.shrink()),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loading ? null : () => _refresh(deviceId),
            tooltip: 'Refresh',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_result == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_result == null) {
      return const Center(child: Text('Press refresh to capture UI'));
    }

    if (_result!.error != null && _result!.xmlContent == null && _result!.screenshotPath == null) {
      return _buildError(_result!.error!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildXmlPanel()),
              const VerticalDivider(width: 1),
              Expanded(child: _buildScreenshotPanel()),
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: _buildScreenshotPanel()),
            const Divider(height: 1),
            Expanded(child: _buildXmlPanel()),
          ],
        );
      },
    );
  }

  Widget _buildXmlPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final xml = _result?.xmlContent;

    if (xml == null || xml.isEmpty) {
      return const Center(child: Text('No XML content'));
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: SelectableText(
            xml,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy XML',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: xml));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('XML copied'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotPanel() {
    final path = _result?.screenshotPath;

    if (path == null || path.isEmpty) {
      return const Center(child: Text('No screenshot'));
    }

    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            child: Center(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Failed to load screenshot: $error',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_result!.error != null)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Material(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _result!.error!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                      tooltip: 'Copy error',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _result!.error!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error copied'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            SelectableText(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: error));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error copied'), duration: Duration(seconds: 1)),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Error'),
            ),
          ],
        ),
      ),
    );
  }
}
