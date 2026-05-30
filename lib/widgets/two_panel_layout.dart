import 'package:flutter/material.dart';

/// A reusable two-panel desktop layout:
/// - Left: fixed-width list with search
/// - Right: detail view
///
/// On narrow screens it shows one panel at a time.
class TwoPanelLayout<T> extends StatelessWidget {
  final List<T> items;
  final bool loading;
  final String emptyMessage;

  /// Left panel search bar hint
  final String searchHint;

  /// Builds the left-panel list tile for [item].
  final Widget Function(BuildContext, T item, bool isSelected) itemBuilder;

  /// Builds the right-panel detail for [selected].
  final Widget Function(BuildContext, T? selected) detailBuilder;

  /// Called when an item is tapped.
  final ValueChanged<T> onItemSelected;

  final T? selectedItem;

  /// Optional header widget placed above the list (e.g. filter chips).
  final Widget? listHeader;

  /// Optional filter function to filter list items by search query.
  final bool Function(T item, String query)? filter;

  const TwoPanelLayout({
    super.key,
    required this.items,
    required this.loading,
    required this.itemBuilder,
    required this.detailBuilder,
    required this.onItemSelected,
    this.selectedItem,
    this.emptyMessage = 'No items found',
    this.searchHint = 'Search…',
    this.listHeader,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;

        final listPanel = _ListPanel<T>(
          items: items,
          loading: loading,
          emptyMessage: emptyMessage,
          searchHint: searchHint,
          itemBuilder: itemBuilder,
          selectedItem: selectedItem,
          onItemSelected: onItemSelected,
          header: listHeader,
          filter: filter,
        );

        final detailPanel = detailBuilder(context, selectedItem);

        if (wide) {
          return Row(
            children: [
              SizedBox(
                width: 280,
                child: Material(elevation: 1, child: listPanel),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: detailPanel),
            ],
          );
        }

        // narrow: push detail on top of list when selected
        if (selectedItem != null) {
          return Column(
            children: [
              Material(
                elevation: 1,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => onItemSelected(selectedItem as T), // toggles selection handling in parent
                    ),
                    const Expanded(child: Text('Back', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              Expanded(child: detailPanel),
            ],
          );
        }
        return listPanel;
      },
    );
  }
}

class _ListPanel<T> extends StatefulWidget {
  final List<T> items;
  final bool loading;
  final String emptyMessage;
  final String searchHint;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final T? selectedItem;
  final ValueChanged<T> onItemSelected;
  final Widget? header;
  final bool Function(T item, String query)? filter;

  const _ListPanel({
    required this.items,
    required this.loading,
    required this.emptyMessage,
    required this.searchHint,
    required this.itemBuilder,
    required this.onItemSelected,
    this.selectedItem,
    this.header,
    this.filter,
  });

  @override
  State<_ListPanel<T>> createState() => _ListPanelState<T>();
}

class _ListPanelState<T> extends State<_ListPanel<T>> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _q.isEmpty || widget.filter == null
        ? widget.items
        : widget.items.where((item) => widget.filter!(item, _q)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: '${widget.searchHint} (${filtered.length})',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _q.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _search.clear();
                        setState(() => _q = '');
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (v) => setState(() => _q = v.toLowerCase()),
          ),
        ),
        if (widget.header != null) widget.header!,
        Expanded(
          child: widget.loading && widget.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(child: Text(widget.emptyMessage))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        return widget.itemBuilder(ctx, item, item == widget.selectedItem);
                      },
                    ),
        ),
      ],
    );
  }
}
