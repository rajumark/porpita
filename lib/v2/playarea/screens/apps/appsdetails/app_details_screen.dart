import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'overview/overview_tab.dart';
import 'permissions/permissions_tab.dart';
import 'queries/queries_tab.dart';
import 'dexopt/dexopt_tab.dart';
import 'activities/activities_tab.dart';
import 'receivers/receivers_tab.dart';
import 'services/services_tab.dart';
import 'domain_verification/domain_verification_tab.dart';
import 'content_providers/content_providers_tab.dart';
import 'keyset/keyset_tab.dart';
import 'packages/packages_tab.dart';
import 'paths/paths_tab.dart';
import 'appfiles/app_files_tab.dart';
import 'apks_files/apks_files_tab.dart';
import 'rawdata/raw_data_tab.dart';

class AppDetailsScreen extends StatefulWidget {
  final String packageName;
  final VoidCallback onBack;
  final int initialTabIndex;
  const AppDetailsScreen({super.key, required this.packageName, required this.onBack, this.initialTabIndex = 0});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 15, vsync: this, initialIndex: widget.initialTabIndex);
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
              Tab(text: 'Receivers'),
              Tab(text: 'Services'),
              Tab(text: 'ContentProviders'),
              Tab(text: 'Domain Verif'),
              Tab(text: 'Key Set'),
              Tab(text: 'Packages'),
              Tab(text: 'Paths'),
              Tab(text: 'App Files'),
              Tab(text: 'APKs Files'),
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
                ReceiversTab(packageName: widget.packageName),
                ServicesTab(packageName: widget.packageName),
                ContentProvidersTab(packageName: widget.packageName),
                DomainVerificationTab(packageName: widget.packageName),
                KeySetTab(packageName: widget.packageName),
                PackagesTab(packageName: widget.packageName),
                PathsTab(packageName: widget.packageName),
                AppFilesTab(packageName: widget.packageName),
                ApksFilesTab(packageName: widget.packageName),
                RawDataTab(packageName: widget.packageName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}