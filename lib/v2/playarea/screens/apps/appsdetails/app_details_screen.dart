import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';

class AppDetailsScreen extends StatelessWidget {
  final String packageName;
  final VoidCallback onBack;
  const AppDetailsScreen({super.key, required this.packageName, required this.onBack});

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
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                Expanded(
                  child: Text(
                    packageName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(packageName, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ],
      ),
    );
  }
}
