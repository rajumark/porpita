import 'package:flutter/material.dart';

class NoPackageSelected extends StatelessWidget {
  const NoPackageSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select a package to view details',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
