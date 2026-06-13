import 'package:flutter/material.dart';

class XmlTreeControls extends StatelessWidget {
  final int focusValue;
  final int totalNodes;
  final String? focusNodeLabel;
  final ValueChanged<int> onFocusChanged;

  const XmlTreeControls({
    super.key,
    required this.focusValue,
    required this.totalNodes,
    this.focusNodeLabel,
    required this.onFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.center_focus_strong, size: 14, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: _buildFocusSlider(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildFocusSlider(ColorScheme colorScheme) {
    final effectiveMax = totalNodes > 1 ? (totalNodes - 1).toDouble() : 1.0;

    return Row(
      children: [
        Text(
          '$focusValue/${totalNodes - 1}',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: focusValue.toDouble().clamp(0, effectiveMax),
              min: 0,
              max: effectiveMax,
              divisions: totalNodes > 1 ? totalNodes - 1 : 1,
              onChanged: (v) => onFocusChanged(v.round()),
            ),
          ),
        ),
      ],
    );
  }
}