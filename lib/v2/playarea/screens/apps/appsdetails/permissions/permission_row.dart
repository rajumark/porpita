import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionRow extends StatefulWidget {
  final String name;
  final Widget? trailing;

  const PermissionRow({super.key, required this.name, this.trailing});

  @override
  State<PermissionRow> createState() => _PermissionRowState();
}

class _PermissionRowState extends State<PermissionRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(widget.name, style: Theme.of(context).textTheme.bodySmall),
            ),
            Opacity(
              opacity: _hovering ? 1.0 : 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconButton(Icons.copy, 'Copy', () {
                    Clipboard.setData(ClipboardData(text: widget.name));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied: ${widget.name}'), duration: const Duration(seconds: 1)),
                    );
                  }),
                  _iconButton(Icons.search, 'Search', () {
                    final query = Uri.encodeComponent('what is ${widget.name} android permission');
                    launchUrl(Uri.parse('https://www.google.com/search?q=$query'), mode: LaunchMode.externalApplication);
                  }),
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 14),
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(const Size(28, 28)),
      ),
    );
  }
}