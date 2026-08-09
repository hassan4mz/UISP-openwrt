# OpenWrt Setup

A Flutter mobile application for discovering and configuring OpenWrt devices. This app provides a user-friendly interface for initial device setup, WiFi configuration, and basic administration.

## Features

- **Device Discovery**
  - mDNS/DNS-SD discovery for `_openwrt-setup._tcp` service
  - Manual IP address entry (e.g., https://192.168.99.1)
  - MAC address entry
  - QR code scanning for quick setup
  - Support for hidden SSID networks with manual connection instructions

- **Setup Wizard**
  - Connect to device setup WiFi or same LAN
  - HTTPS with self-signed certificate warning
  - Authentication with setup password/token
  - WiFi AP configuration (SSID, password, security, channel, country code)
  - Optional station/uplink WiFi configuration
  - Admin password and hostname settings
  - Apply configuration and reboot with progress tracking

- **Security**
  - HTTPS-only communication
  - Self-signed certificate acceptance with explicit warning
  - Secure storage for tokens (flutter_secure_storage)
  - No external server communication (offline/local only)
  - Input validation to prevent SSRF and unsafe redirects

- **UI/UX**
  - Modern Material Design 3 UI
  - Dark mode support
  - Multi-language support (English, Arabic)
  - Responsive design with empty states
  - Troubleshooting guide built-in

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── device_info.dart
│   ├── wifi_config.dart
│   ├── station_config.dart
│   ├── admin_config.dart
│   ├── setup_status.dart
│   └── api_error.dart
├── services/                 # Business logic
│   ├── discovery_service.dart
│   └── api_client.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── device_detail_screen.dart
│   ├── add_device_screen.dart
│   ├── qr_scan_screen.dart
│   ├── setup_wizard_screen.dart
│   └── troubleshooting_screen.dart
├── widgets/                  # Reusable components
├── utils/                    # Helper utilities
└── l10n/                     # Localization files
    ├── app_en.arb
    └── app_ar.arb
```

## API Endpoints

The app communicates with OpenWrt devices using these endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/info` | Get device information |
| GET | `/api/v1/status` | Get setup status |
| POST | `/api/v1/wifi` | Configure WiFi AP |
| POST | `/api/v1/station` | Configure uplink WiFi |
| POST | `/api/v1/admin` | Set admin credentials |
| POST | `/api/v1/apply` | Apply and reboot |

## Android Permissions

| Permission | Purpose |
|------------|---------|
| INTERNET | Network communication |
| ACCESS_NETWORK_STATE | Check network connectivity |
| CHANGE_NETWORK_STATE | Modify network settings |
| ACCESS_WIFI_STATE | Read WiFi state |
| CHANGE_WIFI_STATE | Modify WiFi settings |
| ACCESS_FINE_LOCATION | Required for WiFi scanning on Android |
| ACCESS_COARSE_LOCATION | Location permission fallback |
| CAMERA | QR code scanning |
| NEARBY_WIFI_DEVICES | Android 13+ WiFi device access |

## iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan QR codes for device setup</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to discover WiFi devices</string>
<key>NSLocalNetworkUsageDescription</key>
<string>Local network access is required to discover and configure OpenWrt devices</string>
<key>NSBonjourServices</key>
<array>
    <string>_openwrt-setup._tcp</string>
</array>
```

## Build Instructions

### Prerequisites

- Flutter SDK 3.0+
- Android Studio / Xcode
- Java JDK 11+

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/openwrt-setup.git
cd openwrt-setup

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Testing Checklist

### Device Discovery
- [ ] mDNS discovery finds devices on local network
- [ ] Manual IP addition works with valid IPs
- [ ] MAC address entry validates format correctly
- [ ] QR code scanner reads valid codes
- [ ] Empty state displays when no devices found

### Setup Wizard
- [ ] WiFi configuration accepts valid SSID/password
- [ ] Security options (WPA2/WPA3) work correctly
- [ ] Country code selection persists
- [ ] Hidden SSID toggle functions
- [ ] Station mode configuration optional
- [ ] Admin password validation (match confirmation)
- [ ] Hostname update works
- [ ] Apply/reboot shows progress
- [ ] Success/error states display correctly

### Security
- [ ] HTTPS connections only
- [ ] Certificate warning shows for self-signed certs
- [ ] Tokens stored securely (not in plain text)
- [ ] No data sent to external servers
- [ ] Input validation prevents injection attacks

### Localization
- [ ] English translations complete
- [ ] Arabic translations complete (RTL support)
- [ ] Language switch works at runtime

### UI/UX
- [ ] Dark mode toggles correctly
- [ ] Responsive layout on different screen sizes
- [ ] Loading states show during operations
- [ ] Error messages are user-friendly
- [ ] Troubleshooting tips are helpful

## Architecture

This app follows a clean architecture pattern:

1. **Presentation Layer**: Screens and widgets handle UI rendering
2. **Business Logic Layer**: Services handle discovery and API communication
3. **Data Layer**: Models represent domain entities

State management uses Provider for reactive UI updates.

## License

MIT License - See LICENSE file for details.

## Disclaimer

This app is not affiliated with OpenWrt.org. OpenWrt is a registered trademark of its respective owners.
