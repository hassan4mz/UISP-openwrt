import 'package:flutter_test/flutter_test.dart';
import 'package:openwrt_setup/models/models.dart';

void main() {
  group('Model Tests', () {
    test('DeviceInfo fromJson parses correctly', () {
      final json = {
        'hostname': 'test-device',
        'mac': 'AA:BB:CC:DD:EE:FF',
        'model': 'Test Model',
        'openwrt_version': '23.05.0',
        'ip_address': '192.168.1.1',
        'signal_strength': -50,
        'is_setup_complete': false,
      };

      final device = DeviceInfo.fromJson(json);

      expect(device.hostname, 'test-device');
      expect(device.macAddress, 'AA:BB:CC:DD:EE:FF');
      expect(device.model, 'Test Model');
      expect(device.openwrtVersion, '23.05.0');
      expect(device.ipAddress, '192.168.1.1');
      expect(device.signalStrength, -50);
      expect(device.isSetupComplete, false);
    });

    test('WifiConfig toJson serializes correctly', () {
      final config = WifiConfig(
        ssid: 'MyNetwork',
        password: 'SecurePass123',
        security: 'WPA3',
        hiddenSsid: true,
        countryCode: 'US',
        channel: 36,
        channelWidth: '80MHz',
      );

      final json = config.toJson();

      expect(json['ssid'], 'MyNetwork');
      expect(json['password'], 'SecurePass123');
      expect(json['security'], 'WPA3');
      expect(json['hidden_ssid'], true);
      expect(json['country_code'], 'US');
      expect(json['channel'], 36);
      expect(json['channel_width'], '80MHz');
    });

    test('AdminConfig copyWith creates new instance', () {
      final original = AdminConfig(
        adminPassword: 'oldPass',
        hostname: 'old-hostname',
      );

      final modified = original.copyWith(
        adminPassword: 'newPass',
      );

      expect(original.adminPassword, 'oldPass');
      expect(modified.adminPassword, 'newPass');
      expect(modified.hostname, 'old-hostname');
    });

    test('ApiError toString returns formatted string', () {
      final error = ApiError(
        message: 'Test error',
        code: 'TEST_ERROR',
        statusCode: 500,
      );

      expect(error.toString(), contains('Test error'));
      expect(error.toString(), contains('TEST_ERROR'));
    });
  });
}
