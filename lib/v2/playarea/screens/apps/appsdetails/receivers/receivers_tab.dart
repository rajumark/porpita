import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import '../resolver/resolver_model.dart';
import '../resolver/resolver_service.dart';
import '../resolver/resolver_tab_view.dart';

class ReceiversTab extends StatefulWidget {
  final String packageName;
  const ReceiversTab({super.key, required this.packageName});

  @override
  State<ReceiversTab> createState() => _ReceiversTabState();
}

class _ReceiversTabState extends State<ReceiversTab> with AutomaticKeepAliveClientMixin {
  ResolverResult? _result;
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
  void didUpdateWidget(covariant ReceiversTab oldWidget) {
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
      final result = await ResolverService.fetch(device.id, widget.packageName, 'Receiver Resolver Table');
      if (!mounted) return;
      setState(() { _result = result; _loading = false; });
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

    final sections = _result?.sections ?? [];
    return ResolverTabView(sections: sections, emptyMessage: 'No receiver resolver data');
  }
}