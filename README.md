# Flutter Network Diagnostics

A comprehensive Flutter plugin for network diagnostics and monitoring. Get detailed information about WiFi, mobile networks, DNS, gateways, and real-time signal strength monitoring.

[![pub package](https://img.shields.io/pub/v/flutter_network_diagnostics.svg)](https://pub.dev/packages/flutter_network_diagnostics)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue.svg)](https://github.com/iqbalnova/flutter_network_diagnostics)

## ✨ Features

### 📡 Network Information

- ✅ WiFi SSID, BSSID, and vendor information
- ✅ WiFi security type and IP addresses (IPv4/IPv6)
- ✅ Default gateway and DNS servers
- ✅ Subnet mask and broadcast address
- ✅ HTTP proxy configuration
- ✅ External IP address (IPv4/IPv6)
- ✅ Network connectivity status

### 📶 Real-Time Signal Monitoring (Android Only)

- ✅ WiFi signal strength (RSSI, link speed, frequency)
- ✅ Mobile/Cellular signal strength (dBm, network type, operator)
- ✅ Stream-based real-time monitoring
- ✅ Configurable update intervals

### 🎯 Platform Support

| Feature                  | Android | iOS |
| ------------------------ | ------- | --- |
| WiFi Information         | ✅      | ✅  |
| Network Information      | ✅      | ✅  |
| WiFi Signal Monitoring   | ✅      | ❌  |
| Mobile Signal Monitoring | ✅      | ❌  |

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_network_diagnostics: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## ⚙️ Platform Setup

### Android Configuration

#### 1. Add Permissions

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- Your existing app configuration -->
    </application>

    <!-- Basic network information -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Required for WiFi SSID/BSSID on Android 8.1+ (API 27+) -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Required for WiFi SSID/BSSID on Android 10+ (API 29+) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <!-- Optional: For mobile signal monitoring -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />

    <!-- Optional: For changing WiFi state -->
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
</manifest>
```

#### 2. Request Runtime Permissions

For Android 6.0+ (API 23+), you need to request location permissions at runtime:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Request location permission (required for WiFi info)
  await Permission.location.request();

  // Optional: Request phone state permission (for mobile signal)
  await Permission.phone.request();
}
```

**Add to `pubspec.yaml`:**

```yaml
dependencies:
  permission_handler: ^11.0.0
```

#### 3. Minimum SDK Version

Ensure your `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Android 5.0+
        targetSdkVersion 34
    }
}
```

---

### iOS Configuration

#### 1. Add Entitlement

Create or update `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Required for WiFi SSID/BSSID access -->
    <key>com.apple.developer.networking.wifi-info</key>
    <true/>
</dict>
</plist>
```

#### 2. Update Info.plist

Add location usage descriptions to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Existing keys... -->

    <!-- Required for WiFi information access -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to read Wi-Fi information</string>

    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to read Wi-Fi information</string>
</dict>
```

#### 3. Enable Capability in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **"Access WiFi Information"**

![Xcode Capability](https://docs-assets.developer.apple.com/published/b0e0deb7a5/rendered2x-1634664344.png)

#### 4. Request Location Permission

iOS requires location permission to access WiFi information:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestiOSPermissions() async {
  final status = await Permission.locationWhenInUse.request();

  if (status.isGranted) {
    print('Location permission granted');
  } else if (status.isDenied) {
    print('Location permission denied');
  } else if (status.isPermanentlyDenied) {
    // Open app settings
    await openAppSettings();
  }
}
```

#### 5. Minimum iOS Version

Ensure your `ios/Podfile` has:

```ruby
platform :ios, '12.0'
```

---

## 🚀 Usage

### Basic Network Information

```dart
import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';

final diagnostics = FlutterNetworkDiagnosticsService();

// Get WiFi SSID
String? ssid = await diagnostics.getWifiSSID();
print('WiFi Name: $ssid');

// Get WiFi BSSID (MAC address of router)
String? bssid = await diagnostics.getWifiBSSID();
print('Router MAC: $bssid');

// Get IP address
String? ipAddress = await diagnostics.getWifiIPv4Address();
print('IP Address: $ipAddress');

// Get default gateway
String? gateway = await diagnostics.getDefaultGatewayIP();
print('Gateway: $gateway');

// Get DNS servers
String? dns1 = await diagnostics.getDnsServerPrimary();
String? dns2 = await diagnostics.getDnsServerSecondary();
print('DNS: $dns1, $dns2');

// Get subnet mask
String? subnet = await diagnostics.getSubnetMask();
print('Subnet Mask: $subnet');

// Check network connectivity
bool isConnected = await diagnostics.isNetworkConnected();
print('Connected: $isConnected');
```

### Get All Network Info at Once

```dart
final allInfo = await diagnostics.getAllNetworkInfo();

print('SSID: ${allInfo.wifiSSID}');
print('BSSID: ${allInfo.wifiBSSID}');
print('IP: ${allInfo.wifiIPv4Address}');
print('Gateway: ${allInfo.defaultGatewayIP}');
print('DNS: ${allInfo.dnsServerPrimary}');
print('Subnet: ${allInfo.subnetMask}');
print('Broadcast: ${allInfo.broadcastAddress}');
print('IPv6: ${allInfo.wifiIPv6Addresses}');
```

### Real-Time WiFi Signal Monitoring (Android Only)

```dart
import 'dart:async';

StreamSubscription<WifiSignalInfo>? _wifiSubscription;

void startWifiMonitoring() {
  _wifiSubscription = diagnostics.getWifiSignalStream(
    intervalMs: 1000, // Update every second
  ).listen(
    (info) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('SSID: ${info.ssid}');
      print('BSSID: ${info.bssid}');
      print('RSSI: ${info.rssi} dBm');
      print('Signal Strength: ${info.signalStrengthPercent}%');
      print('Link Speed: ${info.linkSpeed} Mbps');
      print('Frequency: ${info.frequency} MHz');
      print('Band: ${info.band.label}'); // 2.4GHz, 5GHz, 6GHz
      print('WiFi Standard: ${info.wifiStandard?.label}'); // WiFi 4, 5, 6, 6E, 7
      print('Channel: ${info.channel}');
      print('Channel Width: ${info.channelWidth} MHz');

      // Signal quality indicator
      if (info.signalStrengthPercent >= 75) {
        print('Quality: Excellent 🟢');
      } else if (info.signalStrengthPercent >= 50) {
        print('Quality: Good 🟡');
      } else {
        print('Quality: Poor 🔴');
      }
    },
    onError: (error) {
      print('WiFi monitoring error: $error');
    },
  );
}

void stopWifiMonitoring() {
  _wifiSubscription?.cancel();
  _wifiSubscription = null;
}

@override
void dispose() {
  stopWifiMonitoring();
  super.dispose();
}
```

### Real-Time Mobile Signal Monitoring (Android Only)

```dart
StreamSubscription<MobileSignalInfo>? _mobileSubscription;

void startMobileMonitoring() {
  _mobileSubscription = diagnostics.getMobileSignalStream(
    intervalMs: 1000,
  ).listen(
    (info) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Operator: ${info.operatorName}');
      print('Network: ${info.networkGeneration.label}'); // 2G, 3G, 4G, 5G
      print('Signal: ${info.signalStrength} dBm');
      print('Signal Quality: ${info.signalQuality}%');
      print('Cell ID: ${info.cellId}');
      print('Is Roaming: ${info.isRoaming}');

      // Network type specific info
      if (info.networkGeneration == NetworkGeneration.g5) {
        print('NR Band: ${info.nrBand}');
      }
    },
    onError: (error) {
      print('Mobile monitoring error: $error');
    },
  );
}

void stopMobileMonitoring() {
  _mobileSubscription?.cancel();
  _mobileSubscription = null;
}
```

### One-Time Signal Info (Snapshot)

```dart
// WiFi signal info (single read)
WifiSignalInfo? wifiInfo = await diagnostics.getWifiSignalInfo();
if (wifiInfo != null) {
  print('WiFi RSSI: ${wifiInfo.rssi} dBm');
  print('Link Speed: ${wifiInfo.linkSpeed} Mbps');
}

// Mobile signal info (single read)
MobileSignalInfo? mobileInfo = await diagnostics.getMobileSignalInfo();
if (mobileInfo != null) {
  print('Mobile Signal: ${mobileInfo.signalStrength} dBm');
  print('Network: ${mobileInfo.networkGeneration.label}');
}
```

---

## 🎨 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkDiagnosticsPage extends StatefulWidget {
  const NetworkDiagnosticsPage({super.key});

  @override
  State<NetworkDiagnosticsPage> createState() => _NetworkDiagnosticsPageState();
}

class _NetworkDiagnosticsPageState extends State<NetworkDiagnosticsPage> {
  final _diagnostics = FlutterNetworkDiagnosticsService();
  NetworkDiagnosticsData? _networkInfo;
  WifiSignalInfo? _wifiSignal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoad();
  }

  Future<void> _requestPermissionsAndLoad() async {
    // Request permissions
    await Permission.location.request();

    // Load data
    await _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    setState(() => _isLoading = true);

    try {
      final info = await _diagnostics.getAllNetworkInfo();
      final signal = await _diagnostics.getWifiSignalInfo();

      setState(() {
        _networkInfo = info;
        _wifiSignal = signal;
      });
    } catch (e) {
      print('Error loading network info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNetworkInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _networkInfo == null
              ? const Center(child: Text('No data'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection('WiFi Information', [
                      _buildRow('SSID', _networkInfo!.wifiSSID ?? 'N/A'),
                      _buildRow('BSSID', _networkInfo!.wifiBSSID ?? 'N/A'),
                      _buildRow('Security', _networkInfo!.wifiSecurityType ?? 'N/A'),
                      if (_wifiSignal != null) ...[
                        _buildRow('Signal', '${_wifiSignal!.rssi} dBm'),
                        _buildRow('Strength', '${_wifiSignal!.signalStrengthPercent}%'),
                        _buildRow('Link Speed', '${_wifiSignal!.linkSpeed} Mbps'),
                        _buildRow('Band', _wifiSignal!.band.label),
                      ],
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('IP Configuration', [
                      _buildRow('IPv4', _networkInfo!.wifiIPv4Address ?? 'N/A'),
                      _buildRow('Subnet Mask', _networkInfo!.subnetMask ?? 'N/A'),
                      _buildRow('Gateway', _networkInfo!.defaultGatewayIP ?? 'N/A'),
                      _buildRow('Broadcast', _networkInfo!.broadcastAddress ?? 'N/A'),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('DNS Servers', [
                      _buildRow('Primary', _networkInfo!.dnsServerPrimary ?? 'N/A'),
                      _buildRow('Secondary', _networkInfo!.dnsServerSecondary ?? 'N/A'),
                    ]),
                  ],
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
```

---

## 📱 Platform-Specific Notes

### Android

- **WiFi SSID/BSSID**: Requires location permission on Android 8.1+ (API 27+)
- **Fine Location**: Required on Android 10+ (API 29+) for SSID/BSSID
- **Signal Monitoring**: Only available on Android
- **Phone State**: Required for mobile signal monitoring

### iOS

- **WiFi SSID/BSSID**: Requires:
  - Access WiFi Information entitlement
  - Location permission (when in use)
  - Location services enabled on device
- **Signal Monitoring**: Not supported (iOS restrictions)
- **Async Behavior**: WiFi info requests are async due to permission checks

---

## ⚠️ Common Issues

### Issue: WiFi SSID returns `null` on Android

**Solutions:**

1. Request location permission at runtime
2. Enable location services on device
3. Ensure WiFi is connected
4. Check `ACCESS_FINE_LOCATION` permission is in manifest

### Issue: WiFi SSID returns `null` on iOS

**Solutions:**

1. Add `com.apple.developer.networking.wifi-info` entitlement
2. Add location usage descriptions to Info.plist
3. Enable "Access WiFi Information" capability in Xcode
4. Request location permission at runtime
5. Ensure location services are enabled
6. Clean build: `flutter clean && flutter pub get`

### Issue: Signal monitoring doesn't work

**Cause:** Signal monitoring is Android-only

**Solution:** Check platform before using:

```dart
import 'dart:io';

if (Platform.isAndroid) {
  final stream = diagnostics.getWifiSignalStream();
  // Use stream...
} else {
  print('Signal monitoring not supported on iOS');
}
```

### Issue: `UnsupportedError` on iOS signal monitoring

**Expected behavior:** iOS doesn't provide APIs for signal monitoring

**Solution:** Wrap in try-catch or check platform

---

## 🔐 Privacy & Permissions

### Why Location Permission?

Both Android and iOS require location permission to access WiFi SSID/BSSID because:

- MAC addresses (BSSID) can be used for location tracking
- Apple and Google enforce privacy restrictions
- This is required by platform APIs, not the plugin

### Minimal Permissions Setup

For basic network info without WiFi details:

**Android:**

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS:** No special setup needed

---

## 📚 API Reference

### Available Methods

| Method                    | Android | iOS | Description             |
| ------------------------- | ------- | --- | ----------------------- |
| `getWifiSSID()`           | ✅      | ✅  | WiFi network name       |
| `getWifiBSSID()`          | ✅      | ✅  | Router MAC address      |
| `getWifiVendor()`         | ✅      | ❌  | Router manufacturer     |
| `getWifiSecurityType()`   | ✅      | ❌  | WPA2, WPA3, etc.        |
| `getWifiIPv4Address()`    | ✅      | ✅  | Local IP address        |
| `getWifiIPv6Addresses()`  | ✅      | ✅  | IPv6 addresses          |
| `getSubnetMask()`         | ✅      | ✅  | Subnet mask             |
| `getBroadcastAddress()`   | ✅      | ✅  | Broadcast address       |
| `getDefaultGatewayIP()`   | ✅      | ✅  | Router IP               |
| `getDnsServerPrimary()`   | ✅      | ✅  | Primary DNS             |
| `getDnsServerSecondary()` | ✅      | ✅  | Secondary DNS           |
| `getHttpProxy()`          | ✅      | ✅  | HTTP proxy config       |
| `isNetworkConnected()`    | ✅      | ✅  | Network status          |
| `getWifiSignalStream()`   | ✅      | ❌  | Real-time WiFi signal   |
| `getMobileSignalStream()` | ✅      | ❌  | Real-time mobile signal |
| `getWifiSignalInfo()`     | ✅      | ❌  | WiFi signal snapshot    |
| `getMobileSignalInfo()`   | ✅      | ❌  | Mobile signal snapshot  |

---

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guide](CONTRIBUTING.md).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- Inspired by [network_info_plus](https://pub.dev/packages/network_info_plus)
- Built with ❤️ for the Flutter community

---

## 📞 Support

- 🐛 [Report Issues](https://github.com/iqbalnova/flutter_network_diagnostics/issues)
- 💬 [Discussions](https://github.com/iqbalnova/flutter_network_diagnostics/discussions)
- 📧 [Email Support](mailto:support@example.com)
