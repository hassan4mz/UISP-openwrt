import 'package:flutter/material.dart';

/// Troubleshooting screen with helpful tips
class TroubleshootingScreen extends StatelessWidget {
  const TroubleshootingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshooting'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            context,
            Icons.wifi,
            'Connect to Setup WiFi',
            'Make sure your device is connected to the OpenWrt setup WiFi network or the same LAN.',
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.signal_cellular_off,
            'Disable Mobile Data',
            'Turn off mobile data during setup to ensure the app uses the local WiFi connection.',
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.location_on,
            'Enable Location Services',
            'On Android, location permission is required for WiFi scanning. Please enable location services in your device settings.',
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.wifi_lock,
            'Hidden SSID Warning',
            'If your setup WiFi network is hidden, it may not appear automatically. You will need to manually enter the SSID and password.',
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.security,
            'Certificate Warning',
            'OpenWrt devices use self-signed certificates. You may see a security warning - this is normal. Only proceed if you trust the device.',
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            Icons.refresh,
            'Refresh Discovery',
            'Pull down on the home screen to refresh the device discovery scan.',
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
