import 'package:flutter/material.dart';

enum XmlTreeMode { layers, focus }

class XmlTreeControls extends StatelessWidget {
  final XmlTreeMode mode;
  final int layersValue;
  final int maxDepth;
  final int layersNodeCount;
  final int focusValue;
  final int totalNodes;
  final String? focusNodeLabel;
  final ValueChanged<XmlTreeMode> onModeChanged;
  final ValueChanged<int> onLayersChanged;
  final ValueChanged<int> onFocusChanged;

  const XmlTreeControls({
    super.key,
    required this.mode,
    required this.layersValue,
    required this.maxDepth,
    this.layersNodeCount = 0,
    required this.focusValue,
    required this.totalNodes,
    this.focusNodeLabel,
    required this.onModeChanged,
    required this.onLayersChanged,
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
          _buildToggle(colorScheme),
          const SizedBox(width: 12),
          Expanded(child: _buildSlider(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildToggle(ColorScheme colorScheme) {
    final isLayers = mode == XmlTreeMode.layers;
    return Tooltip(
      message: isLayers ? 'Switch to Focus' : 'Switch to Layers',
      child: InkWell(
        onTap: () => onModeChanged(isLayers ? XmlTreeMode.focus : XmlTreeMode.layers),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: colorScheme.primary,
          ),
          child: Icon(
            isLayers ? Icons.layers : Icons.center_focus_strong,
            size: 14,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(ColorScheme colorScheme) {
    if (mode == XmlTreeMode.layers) {
      return _buildLayersSlider(colorScheme);
    } else {
      return _buildFocusSlider(colorScheme);
    }
  }

  Widget _buildLayersSlider(ColorScheme colorScheme) {
    final effectiveMax = maxDepth > 0 ? maxDepth.toDouble() : 1.0;

    return Row(
      children: [
        Text(
          '$layersValue/$maxDepth',
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
              value: layersValue.toDouble().clamp(0, effectiveMax),
              min: 0,
              max: effectiveMax,
              divisions: maxDepth > 0 ? maxDepth : 1,
              onChanged: (v) => onLayersChanged(v.round()),
            ),
          ),
        ),
      ],
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