import 'package:flutter/material.dart';

class ActivitiesTab extends StatelessWidget {
  final String packageName;
  const ActivitiesTab({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Coming Soon', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}