import 'package:flutter/material.dart';
import '../models/models.dart';
import 'setup_wizard_screen.dart';

/// Device detail screen showing device information and setup options
class DeviceDetailScreen extends StatelessWidget {
  final DeviceInfo device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.hostname.isNotEmpty ? device.hostname : 'OpenWrt Device'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildInfoCard(context),
            const SizedBox(height: 24),
            _buildSetupButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
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
                    device.isSetupComplete ? 'Setup Complete' : 'Setup Pending',
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

  Widget _buildInfoCard(BuildContext context) {
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
            _buildInfoRow('Hostname', device.hostname, context),
            _buildInfoRow('MAC Address', device.macAddress, context),
            if (device.model != null)
              _buildInfoRow('Model', device.model!, context),
            if (device.openwrtVersion != null)
              _buildInfoRow('OpenWrt Version', device.openwrtVersion!, context),
            if (device.ipAddress != null)
              _buildInfoRow('IP Address', device.ipAddress!, context),
            if (device.signalStrength != null)
              _buildInfoRow('Signal Strength', '${device.signalStrength} dBm', context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
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

  Widget _buildSetupButton(BuildContext context) {
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
        label: Text(device.isSetupComplete ? 'Configure' : 'Connect to Device'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
