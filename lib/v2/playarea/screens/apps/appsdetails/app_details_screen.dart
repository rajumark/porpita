import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'overview/overview_tab.dart';
import 'permissions/permissions_tab.dart';
import 'queries/queries_tab.dart';
import 'dexopt/dexopt_tab.dart';
import 'activities/activities_tab.dart';
import 'rawdata/raw_data_tab.dart';

class AppDetailsScreen extends StatefulWidget {
  final String packageName;
  final VoidCallback onBack;
  const AppDetailsScreen({super.key, required this.packageName, required this.onBack});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: widget.onBack,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                Expanded(
                  child: Text(
                    widget.packageName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Permissions'),
              Tab(text: 'Queries'),
              Tab(text: 'Dexopt'),
              Tab(text: 'Activities'),
              Tab(text: 'Raw Data'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(packageName: widget.packageName),
                PermissionsTab(packageName: widget.packageName),
                QueriesTab(packageName: widget.packageName),
                DexoptTab(packageName: widget.packageName),
                ActivitiesTab(packageName: widget.packageName),
                RawDataTab(packageName: widget.packageName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}