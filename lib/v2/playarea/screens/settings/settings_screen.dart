import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/settings_service.dart';
import 'package:porpita/v2/widgets/app_sidebar.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'settings_intents_data.dart';
import 'settings_widgets.dart';

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
                            ? const SettingEmptyState()
                            : CustomScrollView(
                                slivers: [
                                  if (pinned.isNotEmpty) ...[
                                    SettingSectionHeader(
                                      icon: Icons.push_pin,
                                      label: 'Pinned',
                                      count: pinned.length,
                                    ),
                                    SettingIntentChipGrid(
                                      items: pinned,
                                      pinnedIds: _pinnedIds,
                                      onTap: (item) => _launch(context, device, item),
                                      onPinToggle: _togglePin,
                                    ),
                                  ],
                                  if (others.isNotEmpty) ...[
                                    SettingSectionHeader(
                                      icon: Icons.settings,
                                      label: pinned.isEmpty && _selectedCategoryIndex == 1 ? kSettingCategories[_selectedCategoryIndex] : kSettingCategories[_selectedCategoryIndex],
                                      count: others.length,
                                    ),
                                    SettingIntentChipGrid(
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