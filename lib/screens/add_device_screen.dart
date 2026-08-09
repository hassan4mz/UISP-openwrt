import 'package:flutter/material.dart';
import '../../services/services.dart';

/// Screen for manually adding a device by IP or MAC address
class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _macController = TextEditingController();
  final _tokenController = TextEditingController();
  final DiscoveryService _discoveryService = DiscoveryService();
  
  bool _isAdding = false;
  String? _error;

  @override
  void dispose() {
    _ipController.dispose();
    _macController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _addByIp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
      _error = null;
    });

    try {
      await _discoveryService.addDeviceByIp(
        _ipController.text.trim(),
        setupToken: _tokenController.text.trim().isEmpty ? null : _tokenController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _addByMac() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
      _error = null;
    });

    try {
      await _discoveryService.addDeviceByMac(_macController.text.trim());

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device Manually'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter IP Address',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'IP Address',
                          hintText: '192.168.99.1',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.dns),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an IP address';
                          }
                          final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                          if (!ipRegex.hasMatch(value)) {
                            return 'Invalid IP address format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tokenController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Setup Password (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAdding ? null : _addByIp,
                          child: _isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Connect to Device'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter MAC Address',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _macController,
                        decoration: const InputDecoration(
                          labelText: 'MAC Address',
                          hintText: 'AA:BB:CC:DD:EE:FF',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.devices),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a MAC address';
                          }
                          final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]?){5}[0-9A-Fa-f]{2}$');
                          if (!macRegex.hasMatch(value)) {
                            return 'Invalid MAC address format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAdding ? null : _addByMac,
                          child: _isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Connect to Device'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
