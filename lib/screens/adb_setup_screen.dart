import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_manager.dart';

class AdbSetupScreen extends StatelessWidget {
  const AdbSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adb = context.watch<AdbManager>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusSection(context, adb),
                const SizedBox(height: 32),
                _buildProgressBar(context, adb),
                const SizedBox(height: 16),
                _buildActionButton(context, adb),
                const SizedBox(height: 48),
                _buildInfoCard(context, adb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, AdbManager adb) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (icon, title, subtitle) = switch (adb.status) {
      AdbSetupStatus.idle => (
          Icons.cloud_download_outlined,
          'Setting Up',
          'Preparing to download ADB tools for ${adb.platformLabel}...',
        ),
      AdbSetupStatus.downloading => (
          Icons.downloading,
          'Downloading ADB Tools',
          'Downloading platform tools for ${adb.platformLabel}...',
        ),
      AdbSetupStatus.extracting => (
          Icons.unarchive_outlined,
          'Extracting',
          'Setting up ADB platform tools...',
        ),
      AdbSetupStatus.ready => (
          Icons.check_circle_outline,
          'Ready',
          'ADB tools are installed and ready to use.',
        ),
      AdbSetupStatus.error => (
          Icons.error_outline,
          'Setup Failed',
          adb.error ?? 'An unknown error occurred.',
        ),
    };

    return Column(
      children: [
        _buildAnimatedIcon(icon, colorScheme),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: adb.status == AdbSetupStatus.error
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(IconData icon, ColorScheme colorScheme) {
    final isActive = icon == Icons.downloading || icon == Icons.unarchive_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: isActive
          ? SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 40, color: colorScheme.primary),
                ],
              ),
            )
          : Icon(icon, size: 40, color: colorScheme.primary),
    );
  }

  Widget _buildProgressBar(BuildContext context, AdbManager adb) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (adb.status == AdbSetupStatus.error ||
        adb.status == AdbSetupStatus.ready) {
      return const SizedBox.shrink();
    }

    final progress = adb.downloadProgress;
    final isIndeterminate =
        adb.status == AdbSetupStatus.extracting || adb.totalBytes <= 0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: isIndeterminate ? null : progress,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
        if (!isIndeterminate) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatBytes(adb.downloadedBytes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                _formatBytes(adb.totalBytes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        if (adb.status == AdbSetupStatus.extracting)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Extracting files...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AdbManager adb) {
    if (adb.status == AdbSetupStatus.error) {
      return FilledButton.icon(
        onPressed: adb.retry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry Download'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(200, 44),
        ),
      );
    }

    if (adb.status == AdbSetupStatus.downloading ||
        adb.status == AdbSetupStatus.extracting) {
      return Text(
        'Please wait...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(BuildContext context, AdbManager adb) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Why is this needed?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.usb,
              'Device Communication',
              'ADB enables direct communication with Android devices for debugging and management.',
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.download_done,
              'One-time Setup',
              'Platform tools are downloaded once and cached for future use.',
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.security,
              'Official Tools',
              'We use official Android platform tools from a trusted source.',
              theme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String description,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
