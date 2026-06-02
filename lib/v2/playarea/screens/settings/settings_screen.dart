import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/settings_service.dart';
import 'package:porpita/v2/widgets/app_sidebar.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'settings_intents_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _prefKey = 'pinned_settings_ids';

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Set<String> _pinnedIds = {};
  bool _prefsLoaded = false;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPins();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPins() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefKey) ?? [];
    if (mounted) {
      setState(() {
        _pinnedIds = saved.toSet();
        _prefsLoaded = true;
      });
    }
  }

  Future<void> _savePins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, _pinnedIds.toList());
  }

  void _togglePin(SettingIntent item) {
    setState(() {
      if (_pinnedIds.contains(item.id)) {
        _pinnedIds.remove(item.id);
      } else {
        _pinnedIds.add(item.id);
      }
    });
    _savePins();
  }

  List<SettingIntent> get _displayedItems {
    final category = kSettingCategories[_selectedCategoryIndex];
    final filtered = _query.isEmpty
        ? kSettingsIntents
        : kSettingsIntents.where((e) => e.text.toLowerCase().contains(_query)).toList();

    if (category == 'All Settings') {
      return filtered;
    }
    return filtered.where((e) => e.category == category).toList();
  }

  Future<void> _launch(
    BuildContext context,
    AdbDevice? device,
    SettingIntent item,
  ) async {
    if (device == null || !device.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No connected device selected')),
      );
      return;
    }

    final ok = await SettingsService.openSetting(
      deviceId: device.id,
      intent: item.intent,
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open "${item.text}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _displayedItems;
    final pinned = items.where((e) => _pinnedIds.contains(e.id)).toList();
    final others = items.where((e) => !_pinnedIds.contains(e.id)).toList();

    return Consumer<DeviceManager>(
      builder: (context, dm, _) {
        final device = dm.selected;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: RoundedContainer(
            child: Row(
              children: [
                AppSidebar(
                  width: 200,
                  items: kSettingCategories,
                  icons: kSettingCategories.map((c) => kCategoryIcons[c] ?? Icons.category).toList(),
                  selectedIndex: _selectedCategoryIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedCategoryIndex = index);
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SearchView(
                          controller: _searchController,
                          hintText: 'Search in ${kSettingsIntents.length} intents…',
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? const _EmptyState()
                            : CustomScrollView(
                                slivers: [
                                  if (pinned.isNotEmpty) ...[
                                    _SectionHeader(
                                      icon: Icons.push_pin,
                                      label: 'Pinned',
                                      count: pinned.length,
                                    ),
                                    _IntentChipGrid(
                                      items: pinned,
                                      pinnedIds: _pinnedIds,
                                      onTap: (item) => _launch(context, device, item),
                                      onPinToggle: _togglePin,
                                    ),
                                  ],
                                  if (others.isNotEmpty) ...[
                                    _SectionHeader(
                                      icon: Icons.settings,
                                      label: pinned.isEmpty && _selectedCategoryIndex == 1 ? kSettingCategories[_selectedCategoryIndex] : kSettingCategories[_selectedCategoryIndex],
                                      count: others.length,
                                    ),
                                    _IntentChipGrid(
                                      items: others,
                                      pinnedIds: _pinnedIds,
                                      onTap: (item) => _launch(context, device, item),
                                      onPinToggle: _togglePin,
                                    ),
                                  ],
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 24),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentChipGrid extends StatelessWidget {
  const _IntentChipGrid({
    required this.items,
    required this.pinnedIds,
    required this.onTap,
    required this.onPinToggle,
  });

  final List<SettingIntent> items;
  final Set<String> pinnedIds;
  final void Function(SettingIntent) onTap;
  final void Function(SettingIntent) onPinToggle;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return _IntentChip(
              item: item,
              isPinned: pinnedIds.contains(item.id),
              onTap: () => onTap(item),
              onPinToggle: () => onPinToggle(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _IntentChip extends StatefulWidget {
  const _IntentChip({
    required this.item,
    required this.isPinned,
    required this.onTap,
    required this.onPinToggle,
  });

  final SettingIntent item;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  @override
  State<_IntentChip> createState() => _IntentChipState();
}

class _IntentChipState extends State<_IntentChip> {
  bool _hovered = false;
  bool _pressed = false;

  void _showContextMenu(BuildContext context, Offset offset) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(4, 4),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          onTap: widget.onPinToggle,
          child: Row(
            children: [
              Icon(
                widget.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(widget.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    if (_pressed) {
      bg = cs.primaryContainer;
    } else if (_hovered) {
      bg = cs.surfaceContainerHigh;
    } else if (widget.isPinned) {
      bg = cs.secondaryContainer.withValues(alpha: 0.5);
    } else {
      bg = cs.surfaceContainerLow;
    }

    final border = widget.isPinned
        ? BorderSide(color: cs.secondary, width: 1.2)
        : BorderSide(color: cs.outlineVariant, width: 1);

    return GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
      onLongPressStart: (d) => _showContextMenu(context, d.globalPosition),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.fromBorderSide(border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isPinned) ...[
                Icon(Icons.push_pin, size: 12, color: cs.secondary),
                const SizedBox(width: 4),
              ],
              Text(
                widget.item.text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: widget.isPinned ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching intents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}