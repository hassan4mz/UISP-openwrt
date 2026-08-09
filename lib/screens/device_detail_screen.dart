import 'package:flutter/material.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';
import 'setup_wizard_screen.dart';

/// Device detail screen showing device information and setup options
class DeviceDetailScreen extends StatelessWidget {
  final DeviceInfo device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(device.hostname.isNotEmpty ? device.hostname : 'OpenWrt Device'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(l10n),
            const SizedBox(height: 16),
            _buildInfoCard(l10n),
            const SizedBox(height: 24),
            _buildSetupButton(l10n, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: device.isSetupComplete ? Colors.green : Colors.orange,
              child: Icon(
                device.isSetupComplete ? Icons.check : Icons.settings,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.isSetupComplete ? l10n.setupComplete : l10n.setupPending,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    device.ipAddress ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildInfoCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildInfoRow(l10n.deviceHostname, device.hostname),
            _buildInfoRow(l10n.deviceMac, device.macAddress),
            if (device.model != null)
              _buildInfoRow(l10n.deviceModel, device.model!),
            if (device.openwrtVersion != null)
              _buildInfoRow(l10n.deviceVersion, device.openwrtVersion!),
            if (device.ipAddress != null)
              _buildInfoRow(l10n.deviceIp, device.ipAddress!),
            if (device.signalStrength != null)
              _buildInfoRow(l10n.deviceSignal, '${device.signalStrength} dBm'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupButton(AppLocalizations l10n, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SetupWizardScreen(device: device),
            ),
          );
        },
        icon: const Icon(Icons.settings),
        label: Text(device.isSetupComplete ? 'Configure' : l10n.connectToDevice),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
