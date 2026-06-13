import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'ui_inspector_controller.dart';
import 'ui_inspector_error_view.dart';
import 'ui_inspector_properties_panel.dart';
import 'ui_inspector_screenshot_panel.dart';
import 'ui_inspector_service.dart';
import 'ui_inspector_xml_panel.dart';

class UiInspectorScreen extends StatefulWidget {
  const UiInspectorScreen({super.key});

  @override
  State<UiInspectorScreen> createState() => _UiInspectorScreenState();
}

class _UiInspectorScreenState extends State<UiInspectorScreen> {
  final _controller = UiInspectorController();
  UiInspectorResult? _result;
  bool _loading = false;
  String? _lastDeviceId;
  int _screenshotVersion = 0;
  bool _showProperties = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_controller.selectedNode != null && !_showProperties) {
      setState(() => _showProperties = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);

    final result = await UiInspectorService.fetch(deviceId);

    if (result.screenshotPath != null) {
      PaintingBinding.instance.imageCache
          .evict(FileImage(File(result.screenshotPath!)));
    }

    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
        _lastDeviceId = deviceId;
        _screenshotVersion++;
        _controller.parseTree(result.xmlContent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device != null && _lastDeviceId != device.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh(device.id));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Column(
          children: [
            _buildToolbar(device?.id),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(String? deviceId) {
    final foregroundApp = _result?.foregroundApp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (foregroundApp != null) ...[
            Icon(Icons.open_in_browser, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                foregroundApp.activityName.split('.').last,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (foregroundApp.fragments.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 14,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 6),
              ...foregroundApp.fragments.map((name) => _buildFragmentChip(name)),
            ],
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
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_showProperties) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.list_alt, size: 20),
                onPressed: _controller.selectedNode != null
                    ? () => setState(() => _showProperties = true)
                    : null,
                tooltip: 'Properties',
                visualDensity: VisualDensity.compact,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loading || deviceId == null ? null : () => _refresh(deviceId),
            tooltip: 'Refresh',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildFragmentChip(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: name));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: $name'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final device = context.watch<DeviceManager>().selected;

    if (_result == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_result == null) {
      if (device == null || !device.isConnected) {
        return const Center(child: Text('Connect a device to inspect UI'));
      }
      return const Center(child: Text('Press refresh to capture UI'));
    }

    if (_result!.error != null && _result!.xmlContent == null && _result!.screenshotPath == null) {
      return UiInspectorErrorView(error: _result!.error!);
    }

    final xmlContent = _result?.xmlContent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        final xmlPanel = xmlContent != null && xmlContent.isNotEmpty
            ? UiInspectorXmlPanel(controller: _controller, xmlContent: xmlContent)
            : const Center(child: Text('No XML content'));

        final screenshotPanel = ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return UiInspectorScreenshotPanel(
              screenshotPath: _result?.screenshotPath,
              error: _result?.error,
              screenshotVersion: _screenshotVersion,
              boundsOverlays: _controller.highlightedBounds,
              selectedBoundsOverlay: _controller.selectedBounds,
              controller: _controller,
              onNodeTap: () {
                if (!_showProperties && _controller.selectedNode != null) {
                  setState(() => _showProperties = true);
                }
              },
            );
          },
        );

        final propertiesPanel = ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return UiInspectorPropertiesPanel(
              node: _controller.selectedNode,
              onClose: () => setState(() => _showProperties = false),
              controller: _controller,
              screenshotPath: _result?.screenshotPath,
              screenshotVersion: _screenshotVersion,
            );
          },
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: xmlPanel),
              const VerticalDivider(width: 1),
              Expanded(child: screenshotPanel),
              if (_showProperties) ...[
                const VerticalDivider(width: 1),
                SizedBox(width: 260, child: propertiesPanel),
              ],
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: screenshotPanel),
            const Divider(height: 1),
            Expanded(child: xmlPanel),
            if (_showProperties) ...[
              const Divider(height: 1),
              SizedBox(height: 200, child: propertiesPanel),
            ],
          ],
        );
      },
    );
  }
}