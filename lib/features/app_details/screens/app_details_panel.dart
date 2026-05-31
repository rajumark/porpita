import 'package:flutter/material.dart';

import '../services/app_details_service.dart';
import 'no_package_selected.dart';

class AppDetailsPanel extends StatefulWidget {
  final String? selectedPackage;
  final String deviceId;

  const AppDetailsPanel({
    super.key,
    required this.selectedPackage,
    required this.deviceId,
  });

  @override
  State<AppDetailsPanel> createState() => _AppDetailsPanelState();
}

class _AppDetailsPanelState extends State<AppDetailsPanel>
    with SingleTickerProviderStateMixin {
  DumpsysResult? _result;
  bool _loading = false;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    if (widget.selectedPackage != null) {
      _fetchDetails();
    }
  }

  @override
  void didUpdateWidget(AppDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPackage != oldWidget.selectedPackage ||
        widget.deviceId != oldWidget.deviceId) {
      _fetchDetails();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    final pkg = widget.selectedPackage;
    if (pkg == null || pkg.isEmpty) {
      setState(() {
        _result = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await AppDetailsService.fetchPackageDetails(
        deviceId: widget.deviceId,
        packageName: pkg,
      );

      if (mounted) {
        if (result == null) {
          setState(() {
            _result = null;
            _loading = false;
            _errorMessage = 'Service returned null (ADB not ready or command failed)';
          });
          return;
        }
        setState(() {
          _result = result;
          _loading = false;
          _errorMessage = null;
          final tabCount = _buildTabs().length;
          _tabController.dispose();
          _tabController = TabController(length: tabCount, vsync: this);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = null;
          _loading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  List<_TabData> _buildTabs() {
    if (_result == null) return [];

    final tabs = <_TabData>[
      _TabData('Basic Info', _BasicInfoTab(entries: _result!.details.toDetailEntries())),
    ];

    for (final section in _result!.sections) {
      tabs.add(_TabData(section.title, _RawDumpTab(rawText: section.rawText)));
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPackage == null) {
      return const NoPackageSelected();
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_result == null) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32, color: cs.error),
            const SizedBox(height: 8),
            Text('Failed to load package details',
              style: TextStyle(color: cs.onSurfaceVariant)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, fontFamily: 'monospace',
                    color: cs.onSurfaceVariant)),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _fetchDetails,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final tabs = _buildTabs();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.selectedPackage!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh',
                onPressed: _fetchDetails,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: tabs.map((t) => Tab(text: t.title)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: tabs.map((t) => t.widget).toList(),
          ),
        ),
      ],
    );
  }
}

class _TabData {
  final String title;
  final Widget widget;
  const _TabData(this.title, this.widget);
}

class _BasicInfoTab extends StatelessWidget {
  final List<DetailEntry> entries;

  const _BasicInfoTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    final basicKeys = {
      'appId', 'pkg', 'versionName', 'versionCode',
      'minSdk', 'targetSdk', 'installerPackageName',
      'timeStamp', 'lastUpdateTime', 'codePath',
      'resourcePath', 'dataDir', 'primaryCpuAbi',
      'flags', 'apkSigningVersion',
    };

    final filtered = entries.where((e) => basicKeys.contains(e.key)).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No basic info available'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final entry = filtered[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
              if (entry.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RawDumpTab extends StatelessWidget {
  final String rawText;

  const _RawDumpTab({required this.rawText});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          rawText,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
