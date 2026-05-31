import 'package:flutter/material.dart';
import 'declared/declared_permissions_page.dart';
import 'requested/requested_permissions_page.dart';
import 'install/install_permissions_page.dart';
import 'runtime/runtime_permissions_page.dart';

class PermissionsTab extends StatefulWidget {
  final String packageName;
  const PermissionsTab({super.key, required this.packageName});

  @override
  State<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends State<PermissionsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Declared'),
            Tab(text: 'Requested'),
            Tab(text: 'Install'),
            Tab(text: 'Runtime'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DeclaredPermissionsPage(packageName: widget.packageName),
              RequestedPermissionsPage(packageName: widget.packageName),
              InstallPermissionsPage(packageName: widget.packageName),
              RuntimePermissionsPage(packageName: widget.packageName),
            ],
          ),
        ),
      ],
    );
  }
}