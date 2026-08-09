import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Setup wizard for configuring OpenWrt devices
class SetupWizardScreen extends StatefulWidget {
  final DeviceInfo device;

  const SetupWizardScreen({super.key, required this.device});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0;
  bool _isApplying = false;
  String? _error;
  
  // Form controllers
  final _ssidController = TextEditingController(text: 'OpenWrt-5G');
  final _passwordController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _hostnameController = TextEditingController();
  
  String _security = 'WPA2';
  String _countryCode = 'US';
  bool _hiddenSsid = false;
  bool _enableStation = false;
  final _stationSsidController = TextEditingController();
  final _stationPasswordController = TextEditingController();

  late OpenWrtApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = OpenWrtApiClient(
      baseUrl: 'https://${widget.device.ipAddress}',
      setupToken: null,
    );
    _hostnameController.text = widget.device.hostname;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _adminPasswordController.dispose();
    _confirmPasswordController.dispose();
    _hostnameController.dispose();
    _stationSsidController.dispose();
    _stationPasswordController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup ${widget.device.hostname}'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: _buildStepContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWifiStep();
      case 1:
        return _buildStationStep();
      case 2:
        return _buildAdminStep();
      case 3:
        return _buildConfirmStep();
      case 4:
        return _buildProgressStep();
      default:
        return Container();
    }
  }

  Widget _buildWifiStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('WiFi Configuration', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: _ssidController,
            decoration: InputDecoration(
              labelText: 'SSID',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.wifi),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _security,
            decoration: InputDecoration(
              labelText: 'Security',
              border: const OutlineInputBorder(),
            ),
            items: ['WPA2', 'WPA3', 'WPA2/WPA3'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _security = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Hidden SSID'),
            value: _hiddenSsid,
            onChanged: (v) => setState(() => _hiddenSsid = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _countryCode,
            decoration: InputDecoration(
              labelText: 'Country Code',
              border: const OutlineInputBorder(),
            ),
            items: ['US', 'GB', 'DE', 'FR', 'SA', 'AE'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _countryCode = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildStationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Station Configuration', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable Station Mode'),
            value: _enableStation,
            onChanged: (v) => setState(() => _enableStation = v),
          ),
          if (_enableStation) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _stationSsidController,
              decoration: InputDecoration(
                labelText: 'Station SSID',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stationPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Station Password',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Admin Configuration', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: _adminPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Admin Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.admin_panel_settings),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hostnameController,
            decoration: InputDecoration(
              labelText: 'Hostname',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.dns),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Configuration', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow('SSID', _ssidController.text),
                  _buildSummaryRow('Security', _security),
                  _buildSummaryRow('Hidden', _hiddenSsid ? 'Yes' : 'No'),
                  _buildSummaryRow('Country', _countryCode),
                  _buildSummaryRow('Station', _enableStation ? 'Enabled' : 'Disabled'),
                  _buildSummaryRow('Hostname', _hostnameController.text),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Device will reboot after applying. You will need to reconnect to the new network.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildProgressStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isApplying) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('Applying Configuration...', style: Theme.of(context).textTheme.titleMedium),
            ] else if (_error != null) ...[
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() { _currentStep = 3; _error = null; }),
                child: const Text('Try Again'),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              Text('Configuration Applied!', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              const Text('Please reconnect to the new network', textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentStep == 4) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _currentStep == 3 ? _applyConfiguration : () => setState(() => _currentStep++),
            child: Text(_currentStep == 3 ? 'Apply Configuration' : 'Next'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyConfiguration() async {
    if (_adminPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isApplying = true;
      _currentStep = 4;
    });

    try {
      // Configure WiFi
      await _apiClient.configureWifi(WifiConfig(
        ssid: _ssidController.text,
        password: _passwordController.text,
        security: _security,
        hiddenSsid: _hiddenSsid,
        countryCode: _countryCode,
      ));

      // Configure station if enabled
      if (_enableStation) {
        await _apiClient.configureStation(StationConfig(
          ssid: _stationSsidController.text,
          password: _stationPasswordController.text,
          enabled: true,
        ));
      }

      // Configure admin
      await _apiClient.configureAdmin(AdminConfig(
        adminPassword: _adminPasswordController.text,
        hostname: _hostnameController.text,
      ));

      // Apply and reboot
      await _apiClient.applyConfiguration();

      setState(() => _isApplying = false);
    } catch (e) {
      setState(() {
        _isApplying = false;
        _error = e.toString();
      });
    }
  }
}
