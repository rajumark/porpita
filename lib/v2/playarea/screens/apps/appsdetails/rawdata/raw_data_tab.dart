import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'raw_data_service.dart';

class RawDataTab extends StatefulWidget {
  final String packageName;
  const RawDataTab({super.key, required this.packageName});

  @override
  State<RawDataTab> createState() => _RawDataTabState();
}

class _RawDataTabState extends State<RawDataTab> with AutomaticKeepAliveClientMixin {
  String _data = '';
  bool _loading = true;
  String? _error;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<_TextSpan> _spans = [];
  int _matchCount = 0;
  int _currentMatch = 0;
  List<int> _matchOffsets = [];

  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RawDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) _fetch();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _buildSpans(_searchController.text);
    });
  }

  static _SpanResult _computeSpans(String data, String query) {
    if (query.isEmpty) {
      return _SpanResult(
        spans: [_TextSpan(data, _SpanType.normal)],
        matchCount: 0,
        matchOffsets: [],
      );
    }

    final q = query.toLowerCase();
    final lowerData = data.toLowerCase();
    final spans = <_TextSpan>[];
    final offsets = <int>[];
    int matchIdx = 0;

    var start = 0;
    while (start < lowerData.length) {
      final idx = lowerData.indexOf(q, start);
      if (idx == -1) break;
      if (idx > start) {
        spans.add(_TextSpan(data.substring(start, idx), _SpanType.normal));
      }
      matchIdx++;
      offsets.add(idx);
      spans.add(_TextSpan(data.substring(idx, idx + q.length), _SpanType.match, matchIndex: matchIdx));
      start = idx + q.length;
    }
    if (start < data.length) {
      spans.add(_TextSpan(data.substring(start), _SpanType.normal));
    }

    return _SpanResult(spans: spans, matchCount: matchIdx, matchOffsets: offsets);
  }

  Future<void> _buildSpans(String query) async {
    if (_data.isEmpty) return;

    final result = await compute(_computeSpansStatic, _ComputeArgs(_data, query));

    if (!mounted) return;

    setState(() {
      _spans = result.spans;
      _matchCount = result.matchCount;
      _matchOffsets = result.matchOffsets;
      if (_currentMatch > _matchCount) _currentMatch = _matchCount;
      if (_matchCount > 0 && _currentMatch == 0) _currentMatch = 1;
    });

    if (_matchCount > 0 && _currentMatch >= 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentMatch();
      });
    }
  }

  void _scrollToCurrentMatch() {
    if (!_scrollController.hasClients || _matchOffsets.isEmpty) return;
    if (_currentMatch < 1 || _currentMatch > _matchOffsets.length) return;

    final charOffset = _matchOffsets[_currentMatch - 1];
    final totalLen = _data.length;
    if (totalLen == 0) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final viewport = _scrollController.position.viewportDimension;

    final proportion = charOffset / totalLen;
    final estimatedY = proportion * maxScroll;
    final centered = (estimatedY - viewport / 2).clamp(0.0, maxScroll);

    _scrollController.animateTo(
      centered,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _goToMatch(int index) {
    if (_matchCount == 0) return;
    setState(() => _currentMatch = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMatch();
    });
  }

  void _nextMatch() {
    if (_matchCount == 0) return;
    final next = _currentMatch >= _matchCount ? 1 : _currentMatch + 1;
    _goToMatch(next);
  }

  void _prevMatch() {
    if (_matchCount == 0) return;
    final prev = _currentMatch <= 1 ? _matchCount : _currentMatch - 1;
    _goToMatch(prev);
  }

  static _SpanResult _computeSpansStatic(_ComputeArgs args) {
    return _computeSpans(args.data, args.query);
  }

  Future<void> _fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final data = await RawDataService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
      _buildSpans(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    }
    if (_data.isEmpty) {
      return const Center(child: Text('No data'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: SearchView(controller: _searchController, hintText: 'Search in raw data...')),
              if (_matchCount > 0) ...[
                const SizedBox(width: 8),
                _navButton(Icons.keyboard_arrow_up, _prevMatch),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('$_currentMatch/$_matchCount', style: Theme.of(context).textTheme.labelSmall),
                ),
                _navButton(Icons.keyboard_arrow_down, _nextMatch),
              ] else if (_searchController.text.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('0/0', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        Expanded(
          child: _buildHighlightedText(context),
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(const Size(28, 28)),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context) {
    final theme = Theme.of(context);
    final normalStyle = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    final matchStyle = normalStyle?.copyWith(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.3),
    );
    final currentMatchStyle = normalStyle?.copyWith(
      backgroundColor: theme.colorScheme.primary,
      color: theme.colorScheme.onPrimary,
    );

    final children = <InlineSpan>[];
    for (final span in _spans) {
      if (span.type == _SpanType.normal) {
        children.add(TextSpan(text: span.text, style: normalStyle));
      } else if (span.type == _SpanType.match) {
        final isCurrent = span.matchIndex == _currentMatch;
        children.add(TextSpan(
          text: span.text,
          style: isCurrent ? currentMatchStyle : matchStyle,
        ));
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SelectableText.rich(
        TextSpan(children: children),
      ),
    );
  }
}

enum _SpanType { normal, match }

class _TextSpan {
  final String text;
  final _SpanType type;
  final int matchIndex;
  const _TextSpan(this.text, this.type, {this.matchIndex = 0});
}

class _SpanResult {
  final List<_TextSpan> spans;
  final int matchCount;
  final List<int> matchOffsets;
  const _SpanResult({required this.spans, required this.matchCount, required this.matchOffsets});
}

class _ComputeArgs {
  final String data;
  final String query;
  const _ComputeArgs(this.data, this.query);
}