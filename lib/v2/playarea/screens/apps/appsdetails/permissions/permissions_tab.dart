import 'package:flutter/material.dart';

class PermissionsTab extends StatelessWidget {
  final String packageName;
  const PermissionsTab({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Coming Soon', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}