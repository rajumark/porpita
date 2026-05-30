import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../services/adb_manager.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';

class _TermLine {
  final String text;
  final bool isSystem;
  final bool isError;
  const _TermLine({required this.text, this.isSystem = false, this.isError = false});
}

/// Interactive ADB shell terminal — dark Catppuccin theme, 2000-line ring buffer.
class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final device = context.watch<DeviceManager>().selected;
    // Re-create the stateful shell whenever the device changes
    return _ShellView(key: ValueKey(device?.id));
  }
}

class _ShellView extends StatefulWidget {
  const _ShellView({super.key});

  @override
  State<_ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<_ShellView> {
  static const _maxLines = 2000;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocus = FocusNode();
  final _lines = <_TermLine>[];

  Process? _shell;
  bool _connected = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _shell?.kill();
    super.dispose();
  }

  Future<void> _start() async {
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
      _append('Connected to ${device.id}', isSystem: true);

      proc.stdout.transform(const SystemEncoding().decoder).listen((data) {
        if (!mounted) return;
        for (final line in data.split('\n')) {
          if (line.isNotEmpty) _append(line);
        }
      });
      proc.stderr.transform(const SystemEncoding().decoder).listen((data) {
        if (mounted && data.trim().isNotEmpty) _append(data.trim(), isError: true);
      });
      proc.exitCode.then((_) {
        if (mounted) setState(() { _connected = false; _shell = null; });
        _append('Session ended', isSystem: true);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _starting = false);
        _append('Error: $e', isError: true);
      }
    }
  }

  void _append(String text, {bool isSystem = false, bool isError = false}) {
    setState(() {
      _lines.add(_TermLine(text: text, isSystem: isSystem, isError: isError));
      if (_lines.length > _maxLines) _lines.removeRange(0, _lines.length - _maxLines);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String cmd) {
    final trimmed = cmd.trim();
    if (trimmed.isEmpty || _shell == null || !_connected) return;
    _append('\$ $trimmed', isSystem: true);
    _shell!.stdin.writeln(trimmed);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device == null || !device.isConnected) return const NoDevicePanel();

    return Column(
      children: [
        // ── status bar ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: _connected ? cs.primaryContainer : cs.errorContainer,
          child: Row(
            children: [
              Icon(
                _connected ? Icons.terminal : Icons.warning_amber,
                size: 14,
                color: _connected ? cs.primary : cs.error,
              ),
              const SizedBox(width: 6),
              Text(
                _connected ? 'Shell — ${device.id}' : _starting ? 'Connecting…' : 'Disconnected',
                style: TextStyle(
                  fontSize: 12,
                  color: _connected ? cs.onPrimaryContainer : cs.onErrorContainer,
                ),
              ),
              const Spacer(),
              if (!_connected && !_starting)
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reconnect', style: TextStyle(fontSize: 12)),
                  onPressed: _start,
                ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, size: 18),
                tooltip: 'Clear output',
                onPressed: () => setState(() => _lines.clear()),
              ),
            ],
          ),
        ),

        // ── terminal output ──────────────────────────────────────────────
        Expanded(
          child: Container(
            color: const Color(0xFF1E1E2E), // Catppuccin Mocha base
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _lines.length,
              itemBuilder: (ctx, i) {
                final ln = _lines[i];
                return Text(
                  ln.text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.55,
                    color: ln.isError
                        ? const Color(0xFFF38BA8) // red
                        : ln.isSystem
                            ? const Color(0xFF89B4FA) // blue
                            : const Color(0xFFCDD6F4), // text
                  ),
                );
              },
            ),
          ),
        ),

        // ── input bar ────────────────────────────────────────────────────
        Container(
          color: const Color(0xFF181825),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFFA6E3A1), // green prompt
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _inputFocus,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFFCDD6F4),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter command and press Enter…',
                    hintStyle: TextStyle(color: Color(0xFF6C7086), fontSize: 12),
                  ),
                  onSubmitted: (v) {
                    _send(v);
                    _inputFocus.requestFocus();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 16, color: Color(0xFF89B4FA)),
                tooltip: 'Send',
                onPressed: () {
                  _send(_controller.text);
                  _inputFocus.requestFocus();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
