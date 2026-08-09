import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Troubleshooting screen with helpful tips
class TroubleshootingScreen extends StatelessWidget {
  const TroubleshootingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.troubleshootingTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            context,
            Icons.wifi,
            l10n.troubleshootingConnectWifi,
            l10n.troubleshootingConnectWifiMessage,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.signal_cellular_off,
            l10n.troubleshootingDisableMobileData,
            l10n.troubleshootingDisableMobileDataMessage,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.location_on,
            l10n.troubleshootingLocationPermission,
            l10n.troubleshootingLocationPermissionMessage,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.visibility_off,
            l10n.troubleshootingHiddenSsid,
            l10n.troubleshootingHiddenSsidMessage,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.security,
            l10n.certificateWarning,
            l10n.certificateWarningMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, IconData icon, String title, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
