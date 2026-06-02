import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final List<String> items;
  final List<IconData>? icons;
  final List<IconData>? selectedIcons;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final double width;

  const AppSidebar({
    super.key,
    required this.items,
    this.icons,
    this.selectedIcons,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width = 140,
  });

  BorderRadius _borderRadius(int index) {
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }
    if (index == items.length - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.circular(2);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final isSelected = index == selectedIndex;
            return Material(
              color: isSelected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
              borderRadius: _borderRadius(index),
              child: InkWell(
                borderRadius: _borderRadius(index),
                onTap: () => onItemSelected(index),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, top: 6, bottom: 6),
                  child: Row(
                    children: [
                      if (icons != null && index < icons!.length) ...[
                        Opacity(
                          opacity: isSelected ? 1.0 : 0.8,
                          child: Icon(
                            isSelected && selectedIcons != null && index < selectedIcons!.length
                                ? selectedIcons![index]
                                : icons![index],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        items[index],
                        style: TextStyle(
                          color: isSelected ? scheme.onSecondaryContainer : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
