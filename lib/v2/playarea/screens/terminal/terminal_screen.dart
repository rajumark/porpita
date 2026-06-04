import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:porpita/services/adb_manager.dart';
import 'package:porpita/services/device_manager.dart';

const _kMaxLines = 5000;
const _kMaxHistory = 200;
const _kHistoryPrefsKey = 'terminal_command_history';

class _CatalogCommand {
  final String command;
  final String label;
  final String description;
  final IconData icon;
  const _CatalogCommand({
    required this.command,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const _catalogCommands = [
  _CatalogCommand(
    command: 'pm list packages',
    label: 'List Packages',
    description: 'List all installed app packages',
    icon: Icons.apps,
  ),
  _CatalogCommand(
    command: 'pm list packages -3',
    label: 'List 3rd-Party',
    description: 'List only third-party packages',
    icon: Icons.shop_outlined,
  ),
  _CatalogCommand(
    command: 'dumpsys battery',
    label: 'Battery Info',
    description: 'Show battery status and level',
    icon: Icons.battery_std,
  ),
  _CatalogCommand(
    command: 'dumpsys meminfo',
    label: 'Memory Info',
    description: 'Show memory usage breakdown',
    icon: Icons.memory,
  ),
  _CatalogCommand(
    command: 'getprop ro.build.version.release',
    label: 'Android Version',
    description: 'Get Android release version',
    icon: Icons.info_outline,
  ),
  _CatalogCommand(
    command: 'logcat -d',
    label: 'Logcat Dump',
    description: 'Dump recent logcat output',
    icon: Icons.description_outlined,
  ),
  _CatalogCommand(
    command: 'df -h',
    label: 'Disk Usage',
    description: 'Show filesystem disk usage',
    icon: Icons.storage,
  ),
  _CatalogCommand(
    command: 'cat /proc/cpuinfo',
    label: 'CPU Info',
    description: 'Show processor information',
    icon: Icons.speed,
  ),
  _CatalogCommand(
    command: 'settings list system',
    label: 'System Settings',
    description: 'List system settings values',
    icon: Icons.settings_suggest_outlined,
  ),
  _CatalogCommand(
    command: 'wm size',
    label: 'Display Size',
    description: 'Show screen resolution',
    icon: Icons.display_settings,
  ),
];

enum _OutputLineType { normal, system, error, success }

class _OutputLine {
  final String text;
  final _OutputLineType type;
  const _OutputLine(this.text, {this.type = _OutputLineType.normal});
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _inputFocus = FocusNode();

  final _lines = <_OutputLine>[];
  final _history = <String>[];
  int _historyIndex = -1;
  String _draftInput = '';

  Process? _shell;
  bool _connected = false;
  bool _starting = false;

  bool _showSearch = false;
  String _searchQuery = '';
  int _searchMatchCount = 0;
  int _searchCurrentIndex = -1;
  List<int> _searchMatchLines = [];

  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startShell());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _inputFocus.dispose();
    _shell?.kill();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final wasAuto = _autoScroll;
    setState(() {
      _autoScroll = max - current < 40;
    });
    if (wasAuto != _autoScroll) return;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kHistoryPrefsKey) ?? [];
    if (mounted) {
      setState(() {
        _history.clear();
        _history.addAll(saved);
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHistoryPrefsKey, _history);
  }

  Future<void> _startShell() async {
    if (_starting || _connected) return;
    setState(() => _starting = true);

    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    final adb = AdbManager.instance.adbPath;

    if (device == null || !device.isConnected || adb == null) {
      if (mounted) setState(() => _starting = false);
      return;
    }

    try {
      final proc = await Process.start(adb, ['-s', device.id, 'shell']);
      _shell = proc;
      if (mounted) setState(() { _connected = true; _starting = false; });
      _append('Connected to ${device.id}', type: _OutputLineType.success);

      proc.stdout.transform(const SystemEncoding().decoder).listen((data) {
        if (!mounted) return;
        for (final line in data.split('\n')) {
          if (line.isNotEmpty) _append(line);
        }
      });
      proc.stderr.transform(const SystemEncoding().decoder).listen((data) {
        if (mounted && data.trim().isNotEmpty) _append(data.trim(), type: _OutputLineType.error);
      });
      proc.exitCode.then((_) {
        if (mounted) {
          setState(() { _connected = false; _shell = null; });
          _append('Session ended', type: _OutputLineType.system);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _starting = false);
        _append('Error: $e', type: _OutputLineType.error);
      }
    }
  }

  void _append(String text, {_OutputLineType type = _OutputLineType.normal}) {
    setState(() {
      _lines.add(_OutputLine(text, type: type));
      if (_lines.length > _kMaxLines) _lines.removeRange(0, _lines.length - _kMaxLines);
    });
    if (_autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _updateSearchMatches();
  }

  void _send(String cmd) {
    final trimmed = cmd.trim();
    if (trimmed.isEmpty || _shell == null || !_connected) return;
    _append('\$ $trimmed', type: _OutputLineType.system);
    _shell!.stdin.writeln(trimmed);
    _inputController.clear();
    _historyIndex = -1;
    _draftInput = '';
    final idx = _history.indexOf(trimmed);
    if (idx >= 0) _history.removeAt(idx);
    _history.insert(0, trimmed);
    if (_history.length > _kMaxHistory) _history.removeRange(_kMaxHistory, _history.length);
    _saveHistory();
  }

  void _updateSearchMatches() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchMatchCount = 0;
        _searchCurrentIndex = -1;
        _searchMatchLines = [];
      });
      return;
    }
    final q = _searchQuery.toLowerCase();
    final matches = <int>[];
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].text.toLowerCase().contains(q)) {
        matches.add(i);
      }
    }
    setState(() {
      _searchMatchLines = matches;
      _searchMatchCount = matches.length;
      if (matches.isEmpty) {
        _searchCurrentIndex = -1;
      } else if (_searchCurrentIndex >= matches.length || _searchCurrentIndex < 0) {
        _searchCurrentIndex = 0;
      }
    });
  }

  void _searchNext() {
    if (_searchMatchLines.isEmpty) return;
    setState(() {
      _searchCurrentIndex = (_searchCurrentIndex + 1) % _searchMatchLines.length;
    });
    _scrollToSearchMatch();
  }

  void _searchPrev() {
    if (_searchMatchLines.isEmpty) return;
    setState(() {
      _searchCurrentIndex = (_searchCurrentIndex - 1 + _searchMatchLines.length) % _searchMatchLines.length;
    });
    _scrollToSearchMatch();
  }

  void _scrollToSearchMatch() {
    if (_searchMatchLines.isEmpty || _searchCurrentIndex < 0) return;
    final lineIndex = _searchMatchLines[_searchCurrentIndex];
    if (lineIndex < _lines.length && _scrollController.hasClients) {
      final approx = lineIndex * 20.0;
      _scrollController.animateTo(
        approx.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  List<String> _getAutoCompleteSuggestions(String input) {
    if (input.isEmpty) return [];
    final lower = input.toLowerCase();
    return _history.where((h) => h.toLowerCase().startsWith(lower)).take(8).toList();
  }

  void _copyOutput() {
    final text = _lines.map((l) => l.text).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Output copied'), duration: Duration(seconds: 1)),
    );
  }

  void _clearOutput() {
    setState(() {
      _lines.clear();
      _searchMatchLines = [];
      _searchMatchCount = 0;
      _searchCurrentIndex = -1;
    });
  }

  Future<void> _saveOutput() async {
    final text = _lines.map((l) => l.text).join('\n');
    try {
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final fileName = 'adb_terminal_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}'), duration: const Duration(seconds: 3)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  void _killProcess() {
    _shell?.kill();
    setState(() {
      _connected = false;
      _shell = null;
    });
    _append('Process killed', type: _OutputLineType.error);
  }

  Color _lineColor(_OutputLineType type, bool isDark) {
    switch (type) {
      case _OutputLineType.error:
        return const Color(0xFFF38BA8);
      case _OutputLineType.system:
        return const Color(0xFF89B4FA);
      case _OutputLineType.success:
        return const Color(0xFFA6E3A1);
      case _OutputLineType.normal:
        return isDark ? const Color(0xFFCDD6F4) : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (device == null || !device.isConnected) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_android, size: 56, color: cs.outlineVariant),
            const SizedBox(height: 12),
            Text('Connect a device to use terminal', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    final suggestions = _getAutoCompleteSuggestions(_inputController.text);

    return Column(
      children: [
        _buildStatusBar(cs, device),
        if (_showSearch) _buildSearchBar(cs),
        Expanded(
          child: Stack(
            children: [
              Container(
                color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _lines.length,
                  itemBuilder: (ctx, i) {
                    final ln = _lines[i];
                    final isSearchMatch = _searchMatchLines.contains(i);
                    final isCurrentMatch = _searchMatchLines.isNotEmpty &&
                        _searchCurrentIndex >= 0 &&
                        _searchCurrentIndex < _searchMatchLines.length &&
                        _searchMatchLines[_searchCurrentIndex] == i;
                    return Container(
                      color: isCurrentMatch
                          ? Colors.orange.withValues(alpha: 0.3)
                          : isSearchMatch
                              ? Colors.yellow.withValues(alpha: isDark ? 0.15 : 0.2)
                              : null,
                      child: Text(
                        ln.text,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          height: 1.55,
                          color: _lineColor(ln.type, isDark),
                          backgroundColor: isCurrentMatch
                              ? Colors.orange.withValues(alpha: 0.4)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!_autoScroll && _lines.isNotEmpty)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() => _autoScroll = true);
                        _scrollToBottom();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard_arrow_down, size: 16),
                            SizedBox(width: 4),
                            Text('Auto-scroll paused', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text('Resume', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty && _inputController.text.isNotEmpty)
          Container(
            color: isDark ? const Color(0xFF181825) : Colors.grey.shade100,
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: suggestions.map((s) {
                return InkWell(
                  onTap: () {
                    _inputController.text = s;
                    _inputController.selection = TextSelection.collapsed(offset: s.length);
                    _inputFocus.requestFocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        _buildInputBar(cs, isDark),
      ],
    );
  }

  Widget _buildStatusBar(ColorScheme cs, dynamic device) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _connected ? cs.primaryContainer : cs.errorContainer,
      child: Row(
        children: [
          Icon(
            _connected ? Icons.terminal : (_starting ? Icons.hourglass_top : Icons.warning_amber),
            size: 14,
            color: _connected ? cs.primary : cs.error,
          ),
          const SizedBox(width: 6),
          Text(
            _connected ? 'Shell — ${device.id}' : _starting ? 'Connecting...' : 'Disconnected',
            style: TextStyle(
              fontSize: 11,
              color: _connected ? cs.onPrimaryContainer : cs.onErrorContainer,
            ),
          ),
          const Spacer(),
          if (_lines.isNotEmpty)
            Text(
              '${_lines.length} lines',
              style: TextStyle(fontSize: 10, color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.stop, size: 16),
            tooltip: 'Kill process',
            onPressed: _connected ? _killProcess : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.replay, size: 16),
            tooltip: 'Reconnect',
            onPressed: (!_connected && !_starting) ? _startShell : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 16),
            tooltip: 'Search output',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                  _searchMatchLines = [];
                  _searchMatchCount = 0;
                  _searchCurrentIndex = -1;
                }
              });
            },
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copy output',
            onPressed: _lines.isNotEmpty ? _copyOutput : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, size: 16),
            tooltip: 'Save as .txt',
            onPressed: _lines.isNotEmpty ? _saveOutput : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 16),
            tooltip: 'Clear output',
            onPressed: _clearOutput,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.history, size: 16),
            tooltip: 'Command history',
            onPressed: _history.isEmpty ? null : () => _showHistoryDialog(),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.code, size: 16),
            tooltip: 'Command catalog',
            onPressed: () => _showCommandCatalogDialog(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cs.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search in output...',
                hintStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Text(
                        _searchMatchCount > 0
                            ? '${_searchCurrentIndex + 1} of $_searchMatchCount'
                            : '0 matches',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: cs.primary),
                ),
              ),
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _updateSearchMatches();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            tooltip: 'Previous match',
            onPressed: _searchMatchCount > 0 ? _searchPrev : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            tooltip: 'Next match',
            onPressed: _searchMatchCount > 0 ? _searchNext : null,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Close search',
            onPressed: () {
              setState(() {
                _showSearch = false;
                _searchQuery = '';
                _searchController.clear();
                _searchMatchLines = [];
                _searchMatchCount = 0;
                _searchCurrentIndex = -1;
              });
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_history.isNotEmpty) {
        setState(() {
          if (_historyIndex == -1) {
            _draftInput = _inputController.text;
          }
          if (_historyIndex < _history.length - 1) {
            _historyIndex++;
          }
          _inputController.text = _history[_historyIndex];
          _inputController.selection = TextSelection.collapsed(offset: _inputController.text.length);
        });
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_history.isNotEmpty) {
        setState(() {
          if (_historyIndex > 0) {
            _historyIndex--;
            _inputController.text = _history[_historyIndex];
          } else if (_historyIndex == 0) {
            _historyIndex = -1;
            _inputController.text = _draftInput;
          }
          _inputController.selection = TextSelection.collapsed(offset: _inputController.text.length);
        });
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildInputBar(ColorScheme cs, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF181825) : Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          const Text(
            '\$',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFA6E3A1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Focus(
              onKeyEvent: _handleKeyEvent,
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                autofocus: true,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter command...',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) {
                  _send(v);
                  _inputFocus.requestFocus();
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, size: 16, color: Color(0xFF89B4FA)),
            tooltip: 'Send',
            onPressed: () {
              _send(_inputController.text);
              _inputFocus.requestFocus();
            },
          ),
        ],
      ),
    );
  }

  void _showCommandCatalogDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (ctx, scrollController) {
            final cs = Theme.of(ctx).colorScheme;
            final tt = Theme.of(ctx).textTheme;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 20, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Command Catalog', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${_catalogCommands.length} commands', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: _catalogCommands.length,
                    itemBuilder: (ctx, i) {
                      final cmd = _catalogCommands[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Material(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              _inputController.text = cmd.command;
                              _inputController.selection = TextSelection.collapsed(offset: cmd.command.length);
                              Navigator.pop(ctx);
                              _inputFocus.requestFocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(cmd.icon, size: 18, color: cs.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cmd.label,
                                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cmd.description,
                                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: cs.outlineVariant, width: 0.5),
                                          ),
                                          child: Text(
                                            cmd.command,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.tonal(
                                    onPressed: () {
                                      _inputController.text = cmd.command;
                                      _inputController.selection = TextSelection.collapsed(offset: cmd.command.length);
                                      Navigator.pop(ctx);
                                      _inputFocus.requestFocus();
                                    },
                                    style: FilledButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.north_west, size: 14),
                                        SizedBox(width: 4),
                                        Text('Use'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.2,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 20),
                      const SizedBox(width: 8),
                      const Text('Command History', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${_history.length} commands', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      if (_history.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_sweep, size: 16),
                          label: const Text('Clear', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            setState(() {
                              _history.clear();
                              _historyIndex = -1;
                            });
                            _saveHistory();
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(child: Text('No commands in history'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _history.length,
                          itemBuilder: (ctx, i) {
                            return ListTile(
                              dense: true,
                              leading: Text('${i + 1}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                              title: Text(
                                _history[i],
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.north_west, size: 14),
                                tooltip: 'Use command',
                                onPressed: () {
                                  _inputController.text = _history[i];
                                  _inputController.selection = TextSelection.collapsed(offset: _history[i].length);
                                  Navigator.pop(ctx);
                                  _inputFocus.requestFocus();
                                },
                              ),
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: _history[i]));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}