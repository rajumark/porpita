import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import '../permission_row.dart';
import 'requested_permissions_model.dart';
import 'requested_permissions_service.dart';

class RequestedPermissionsPage extends StatefulWidget {
  final String packageName;
  const RequestedPermissionsPage({super.key, required this.packageName});

  @override
  State<RequestedPermissionsPage> createState() => RequestedPermissionsPageState();
}

class RequestedPermissionsPageState extends State<RequestedPermissionsPage> with AutomaticKeepAliveClientMixin {
  List<RequestedPermission> _permissions = [];
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
  void didUpdateWidget(covariant RequestedPermissionsPage oldWidget) {
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
      final list = await RequestedPermissionsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _permissions = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<RequestedPermission> get _filtered {
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
    if (_permissions.isEmpty) return const Center(child: Text('No requested permissions'));

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchView(controller: _searchController, hintText: 'Search requested permissions...'),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return PermissionRow(name: filtered[index].name);
            },
          ),
        ),
      ],
    );
  }
}