import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'appslist/appslist_screen.dart';
import 'appsdetails/app_details_screen.dart';

class AppsBaseScreen extends StatefulWidget {
  const AppsBaseScreen({super.key});

  @override
  State<AppsBaseScreen> createState() => _AppsBaseScreenState();
}

class _AppsBaseScreenState extends State<AppsBaseScreen> {
  String? _selectedPackageName;
  int _initialTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            AppsListScreen(
              onAppSelected: (packageName, {int tabIndex = 0}) => setState(() {
                _selectedPackageName = packageName;
                _initialTabIndex = tabIndex;
              }),
            ),
            if (_selectedPackageName != null)
              AppDetailsScreen(
                packageName: _selectedPackageName!,
                onBack: () => setState(() => _selectedPackageName = null),
                initialTabIndex: _initialTabIndex,
              ),
          ],
        ),
      ),
    );
  }
}
