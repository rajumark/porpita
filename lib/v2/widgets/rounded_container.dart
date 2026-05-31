import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double? radius;

  const RoundedContainer({super.key, required this.child, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius ?? 12),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
