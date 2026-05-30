import 'package:flutter/material.dart';

import '../../services/app_details_service.dart';
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
  PackageDetails? _details;
  bool _loading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didUpdateWidget(AppDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPackage != oldWidget.selectedPackage) {
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
      setState(() => _details = null);
      return;
    }

    setState(() => _loading = true);

    final details = await AppDetailsService.fetchPackageDetails(
      deviceId: widget.deviceId,
      packageName: pkg,
    );

    if (mounted) {
      setState(() {
        _details = details;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPackage == null) {
      return const NoPackageSelected();
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_details == null) {
      return const Center(
        child: Text('Failed to load package details'),
      );
    }

    final entries = _details!.toDetailEntries();

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
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Permissions'),
            Tab(text: 'Full Info'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BasicInfoTab(entries: entries),
              _PermissionsTab(details: _details!),
              _FullInfoTab(entries: entries),
            ],
          ),
        ),
      ],
    );
  }
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

class _PermissionsTab extends StatelessWidget {
  final PackageDetails details;

  const _PermissionsTab({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(label: 'installPermissionsFixed', value: details.installPermissionsFixed, theme: theme),
        _InfoRow(label: 'usesNonSdkApi', value: details.usesNonSdkApi, theme: theme),
        _InfoRow(label: 'forceQueryable', value: details.forceQueryable, theme: theme),
        _InfoRow(label: 'queriesPackages', value: details.queriesPackages, theme: theme),
        _InfoRow(label: 'queriesIntents', value: details.queriesIntents, theme: theme),
      ],
    );
  }
}

class _FullInfoTab extends StatelessWidget {
  final List<DetailEntry> entries;

  const _FullInfoTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No details available'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final entry = entries[i];
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
              SelectableText(
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final ThemeData theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
