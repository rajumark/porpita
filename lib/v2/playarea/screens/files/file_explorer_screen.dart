import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/overflow_menu.dart';
import 'file_explorer_model.dart';
import 'file_explorer_service.dart';
import 'file_entry_tile.dart';
import 'file_categorizer.dart';
import 'file_search_dialog.dart';
import 'file_details_sheet.dart';
import 'file_operations.dart';
import 'path_breadcrumbs.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  String _currentPath = '/sdcard';
  final _pathHistory = <String>[];
  List<FileEntry> _entries = [];
  List<FileEntry> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  FileViewMode _viewMode = FileViewMode.list;
  FileSortMode _sortMode = FileSortMode.nameAsc;
  String _searchQuery = '';
  String? _lastDeviceId;
  final _searchController = TextEditingController();

  static const _quickPaths = [
    ('/', 'Root'),
    ('/sdcard', 'Internal Storage'),
    ('/sdcard/Download', 'Download'),
    ('/sdcard/DCIM', 'DCIM'),
    ('/sdcard/Pictures', 'Pictures'),
    ('/sdcard/Music', 'Music'),
    ('/sdcard/Documents', 'Documents'),
    ('/storage', 'Storage'),
    ('/data', 'Data'),
    ('/system', 'System'),
    ('/proc', 'Proc'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _navigateTo(_currentPath);
  }

  Future<void> _navigateTo(String path) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResults = [];
      _isSearching = false;
    });

    try {
      final entries = await FileExplorerService.listDirectory(device.id, path);
      if (!mounted) return;
      setState(() {
        _currentPath = path;
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openDirectory(String path) {
    if (path == _currentPath) return;
    _pathHistory.add(_currentPath);
    _navigateTo(path);
  }

  void _goBack() {
    if (_pathHistory.isNotEmpty) {
      final prev = _pathHistory.removeLast();
      _navigateTo(prev);
    } else if (_currentPath != '/') {
      final parent = _currentPath.substring(0, _currentPath.lastIndexOf('/'));
      _navigateTo(parent.isEmpty ? '/' : parent);
    }
  }

  void _onBreadcrumbTap(String path) {
    _pathHistory.clear();
    if (path != _currentPath) {
      _pathHistory.add(_currentPath);
    }
    _navigateTo(path);
  }

  void _showSearchDialog() {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    showDialog(
      context: context,
      builder: (ctx) => FileSearchDialog(
        currentPath: _currentPath,
        onSearch: (filter) async {
          setState(() {
            _isLoading = true;
            _error = null;
            _isSearching = true;
          });
          try {
            final results = await FileExplorerService.search(
              device.id,
              _currentPath,
              filter,
            );
            if (!mounted) return;
            setState(() {
              _searchResults = results;
              _isLoading = false;
            });
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _error = e.toString();
              _isLoading = false;
            });
          }
        },
      ),
    );
  }

  void _handleEntryTap(FileEntry entry) {
    if (entry.isDirectory) {
      _openDirectory(entry.fullPath);
    } else {
      _showFileDetails(entry);
    }
  }

  void _handleEntryAction(FileEntry entry, String action) {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    switch (action) {
      case 'open':
        _openDirectory(entry.fullPath);
        break;
      case 'details':
        _showFileDetails(entry);
        break;
      case 'copy_path':
        _copyPath(entry.fullPath);
        break;
      case 'pull':
        FileOperations.pullToDownloads(
          context,
          entry: entry,
          deviceId: device.id,
        );
        break;
      case 'copy':
        FileOperations.showCopyDialog(
          context,
          entry: entry,
          currentPath: _currentPath,
          deviceId: device.id,
          onCompleted: _refresh,
        );
        break;
      case 'move':
        FileOperations.showMoveDialog(
          context,
          entry: entry,
          currentPath: _currentPath,
          deviceId: device.id,
          onCompleted: _refresh,
        );
        break;
      case 'rename':
        FileOperations.showRenameDialog(
          context,
          entry: entry,
          currentPath: _currentPath,
          deviceId: device.id,
          onCompleted: _refresh,
        );
        break;
      case 'delete':
        FileOperations.showDeleteConfirm(
          context,
          entry: entry,
          deviceId: device.id,
          onCompleted: _refresh,
        );
        break;
    }
  }

  void _copyPath(String path) {
    Clipboard.setData(ClipboardData(text: path));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Path copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showFileDetails(FileEntry entry) {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      useSafeArea: true,
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 460,
          height: double.infinity,
          child: FileDetailsSheet(
            entry: entry,
            deviceId: device.id,
          ),
        ),
      ),
    );
  }

  void _navigateToQuickPath(String path) {
    _pathHistory.clear();
    if (path != _currentPath) {
      _pathHistory.add(_currentPath);
    }
    _navigateTo(path);
  }

  void _refresh() {
    _navigateTo(_currentPath);
  }

  void _showSortSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.sort, size: 20, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('Sort by', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 16),
            for (final mode in FileSortMode.values)
              ListTile(
                dense: true,
                leading: Icon(mode.icon, size: 20, color: mode == _sortMode ? cs.primary : null),
                title: Text(
                  mode.label,
                  style: TextStyle(
                    fontWeight: mode == _sortMode ? FontWeight.w600 : FontWeight.normal,
                    color: mode == _sortMode ? cs.primary : null,
                  ),
                ),
                trailing: mode == _sortMode ? Icon(Icons.check, size: 18, color: cs.primary) : null,
                onTap: () {
                  setState(() => _sortMode = mode);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  List<FileEntry> get _displayEntries {
    final raw = _isSearching && _searchResults.isNotEmpty
        ? _searchResults
        : _searchQuery.isEmpty
            ? _entries
            : _entries.where((e) {
                final q = _searchQuery;
                return e.name.toLowerCase().contains(q) || e.fullPath.toLowerCase().contains(q);
              }).toList();
    return _applySort(raw);
  }

  List<FileEntry> _applySort(List<FileEntry> entries) {
    final dirs = entries.where((e) => e.isDirectory).toList();
    final files = entries.where((e) => !e.isDirectory).toList();

    void sortList(List<FileEntry> list) {
      switch (_sortMode) {
        case FileSortMode.nameAsc:
          list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        case FileSortMode.nameDesc:
          list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        case FileSortMode.newestFirst:
          list.sort((a, b) {
            final ad = a.modified;
            final bd = b.modified;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
        case FileSortMode.oldestFirst:
          list.sort((a, b) {
            final ad = a.modified;
            final bd = b.modified;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return ad.compareTo(bd);
          });
        case FileSortMode.largestFirst:
          list.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
        case FileSortMode.smallestFirst:
          list.sort((a, b) => (a.size ?? 0).compareTo(b.size ?? 0));
        case FileSortMode.kindGroup:
          list.sort((a, b) {
            final catA = FileCategorizer.categoryFromExt(a.extension);
            final catB = FileCategorizer.categoryFromExt(b.extension);
            final cmp = catA.label.compareTo(catB.label);
            if (cmp != 0) return cmp;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
      }
    }

    sortList(dirs);
    sortList(files);
    return [...dirs, ...files];
  }

  BorderRadius _borderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(12);
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }
    if (index == total - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.circular(2);
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    final cs = Theme.of(context).colorScheme;

    if (device != null && device.id != _lastDeviceId) {
      _handleDeviceSwitch(device.id);
    }

    if (device == null || !device.isConnected) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_android, size: 56, color: cs.outlineVariant),
            const SizedBox(height: 12),
            Text('Connect a device to browse files',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    final displayEntries = _displayEntries;

    return Column(
      children: [
        _buildToolbar(cs, device),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: PathBreadcrumbs(
            path: _currentPath,
            onPathTap: _onBreadcrumbTap,
            onBack: _goBack,
          ),
        ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
            child: Row(
              children: [
                Icon(Icons.search, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  'Search results: ${_searchResults.length} items in $_currentPath',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Clear search'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchResults = [];
                      _isSearching = false;
                    });
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$_currentPath  ·  ${displayEntries.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(displayEntries)),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme cs, dynamic device) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: SearchView(
              controller: _searchController,
              hintText: 'Filter files...',
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            iconSize: 20,
            tooltip: 'Deep search (find)',
            onPressed: _showSearchDialog,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          IconButton(
            icon: _viewMode == FileViewMode.list
                ? const Icon(Icons.grid_view_outlined)
                : const Icon(Icons.view_list_outlined),
            iconSize: 20,
            tooltip: _viewMode == FileViewMode.list
                ? 'Switch to grid'
                : 'Switch to list',
            onPressed: () => setState(() {
              _viewMode = _viewMode == FileViewMode.list
                  ? FileViewMode.grid
                  : FileViewMode.list;
            }),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            iconSize: 20,
            tooltip: 'New folder',
            onPressed: () => FileOperations.showNewFolderDialog(
              context,
              currentPath: _currentPath,
              deviceId: device.id,
              onCompleted: _refresh,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            iconSize: 20,
            tooltip: 'Upload file',
            onPressed: () => FileOperations.showPushDialog(
              context,
              currentPath: _currentPath,
              deviceId: device.id,
              onCompleted: _refresh,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 20,
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _refresh,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          IconButton(
            icon: Icon(_sortMode.icon, size: 20),
            iconSize: 20,
            tooltip: 'Sort: ${_sortMode.label}',
            onPressed: _showSortSheet,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          OverflowMenu(
            items: [
              for (final qp in _quickPaths)
                OverflowMenuItem(
                  value: qp.$1,
                  label: qp.$2,
                  icon: qp.$1 == '/'
                      ? Icons.device_hub
                      : qp.$1 == '/sdcard'
                          ? Icons.smartphone
                          : Icons.folder_outlined,
                ),
            ],
            onSelected: (v) => _navigateToQuickPath(v),
            tooltip: 'Quick paths',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<FileEntry> entries) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (entries.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty && !_isSearching
              ? 'Empty directory'
              : 'No matching files',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (_viewMode == FileViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return FileEntryGridCard(
            entry: entry,
            onTap: () => _handleEntryTap(entry),
            onAction: _handleEntryAction,
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return FileEntryListTile(
          entry: entry,
          borderRadius: _borderRadius(index, entries.length),
          onTap: () => _handleEntryTap(entry),
          onAction: _handleEntryAction,
        );
      },
    );
  }
}
