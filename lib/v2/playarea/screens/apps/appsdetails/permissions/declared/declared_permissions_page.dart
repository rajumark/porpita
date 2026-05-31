import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import '../permission_row.dart';
import 'declared_permissions_model.dart';
import 'declared_permissions_service.dart';

class DeclaredPermissionsPage extends StatefulWidget {
  final String packageName;
  const DeclaredPermissionsPage({super.key, required this.packageName});

  @override
  State<DeclaredPermissionsPage> createState() => DeclaredPermissionsPageState();
}

class DeclaredPermissionsPageState extends State<DeclaredPermissionsPage> with AutomaticKeepAliveClientMixin {
  List<DeclaredPermission> _permissions = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DeclaredPermissionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) fetch();
  }

  Future<void> fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final list = await DeclaredPermissionsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _permissions = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<DeclaredPermission> get _filtered {
    var list = _permissions;
    if (_query.isNotEmpty) list = list.where((p) => p.name.toLowerCase().contains(_query)).toList();
    list = list.where((p) => p.name.contains('.')).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    if (_permissions.isEmpty) return const Center(child: Text('No declared permissions'));

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchView(controller: _searchController, hintText: 'Search declared permissions...'),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final p = filtered[index];
              return PermissionRow(
                name: p.name,
                trailing: p.protectionLevel.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _protColor(p.protectionLevel).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(p.protectionLevel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _protColor(p.protectionLevel))),
                          ),
                        ],
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Color _protColor(String prot) {
    switch (prot) {
      case 'dangerous': return Colors.red;
      case 'signature': return Colors.orange;
      case 'normal': return Colors.green;
      default: return Colors.grey;
    }
  }
}