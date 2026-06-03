import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import '../resolver/resolver_model.dart';
import '../resolver/resolver_service.dart';
import '../resolver/resolver_tab_view.dart';

class ContentProvidersTab extends StatefulWidget {
  final String packageName;
  const ContentProvidersTab({super.key, required this.packageName});

  @override
  State<ContentProvidersTab> createState() => _ContentProvidersTabState();
}

class _ContentProvidersTabState extends State<ContentProvidersTab> with AutomaticKeepAliveClientMixin {
  List<ResolverResult> _results = [];
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant ContentProvidersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) _fetch();
  }

  Future<void> _fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final registered = await ResolverService.fetchContentProviders(device.id, widget.packageName);
      final authorities = await ResolverService.fetchContentProviderAuthorities(device.id, widget.packageName);
      if (!mounted) return;
      setState(() {
        _results = [registered, authorities].whereType<ResolverResult>().toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    final sections = _results.expand((r) => r.sections).toList();
    if (sections.isEmpty) {
      return const Center(child: Text('No content provider data', style: TextStyle(fontSize: 14)));
    }
    return ResolverTabView(sections: sections, emptyMessage: 'No content provider data');
  }
}