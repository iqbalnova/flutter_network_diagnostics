// flutter_network_diagnostics_service.dart (updated main service)
import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';
import 'package:flutter_network_diagnostics/src/models/signal_info.dart';

/// Main class for Flutter Network Diagnostics
class FlutterNetworkDiagnosticsService {
  // Delegate all methods to the platform interface

  Future<String?> getDefaultGatewayIP() {
    return FlutterNetworkDiagnosticsPlatform.instance.getDefaultGatewayIP();
  }

  Future<String?> getDnsServerPrimary() {
    return FlutterNetworkDiagnosticsPlatform.instance.getDnsServerPrimary();
  }

  Future<String?> getDnsServerSecondary() {
    return FlutterNetworkDiagnosticsPlatform.instance.getDnsServerSecondary();
  }

  Future<String?> getExternalIPv4() {
    return FlutterNetworkDiagnosticsPlatform.instance.getExternalIPv4();
  }

  Future<String?> getDefaultGatewayIPv6() {
    return FlutterNetworkDiagnosticsPlatform.instance.getDefaultGatewayIPv6();
  }

  Future<String?> getDnsServerIPv6() {
    return FlutterNetworkDiagnosticsPlatform.instance.getDnsServerIPv6();
  }

  Future<String?> getExternalIPv6() {
    return FlutterNetworkDiagnosticsPlatform.instance.getExternalIPv6();
  }

  Future<String?> getHttpProxy() {
    return FlutterNetworkDiagnosticsPlatform.instance.getHttpProxy();
  }

  Future<bool> isNetworkConnected() {
    return FlutterNetworkDiagnosticsPlatform.instance.isNetworkConnected();
  }

  Future<String?> getWifiSSID() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiSSID();
  }

  Future<String?> getWifiBSSID() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiBSSID();
  }

  Future<String?> getWifiVendor() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiVendor();
  }

  Future<String?> getWifiSecurityType() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiSecurityType();
  }

  Future<String?> getWifiIPv4Address() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiIPv4Address();
  }

  Future<String?> getSubnetMask() {
    return FlutterNetworkDiagnosticsPlatform.instance.getSubnetMask();
  }

  Future<List<String>?> getWifiIPv6Addresses() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiIPv6Addresses();
  }

  Future<String?> getBroadcastAddress() {
    return FlutterNetworkDiagnosticsPlatform.instance.getBroadcastAddress();
  }

  Future<NetworkDiagnosticsData> getAllNetworkInfo() {
    return FlutterNetworkDiagnosticsPlatform.instance.getAllNetworkInfo();
  }

  // ============================================================================
  // MARK: - REAL-TIME SIGNAL MONITORING (Android-only)
  // ============================================================================

  /// Monitor Wi-Fi signal strength in real-time
  ///
  /// Returns a stream that emits [WifiSignalInfo] at the specified interval.
  ///
  /// **Platform Support:**
  /// - ✅ Android (API 21+)
  /// - ❌ iOS (throws [UnsupportedError])
  ///
  /// **Required Permissions (Android):**
  /// ```xml
  /// <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  /// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  /// ```
  ///
  /// **Example:**
  /// ```dart
  /// final service = FlutterNetworkDiagnosticsService();
  /// final subscription = service.getWifiSignalStream().listen((info) {
  ///   print('Wi-Fi Signal: ${info.rssi} dBm');
  ///   print('Band: ${info.band.label}');
  ///   print('Speed: ${info.linkSpeed} Mbps');
  /// });
  ///
  /// // Don't forget to cancel when done
  /// subscription.cancel();
  /// ```
  Stream<WifiSignalInfo> getWifiSignalStream({int intervalMs = 1000}) {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiSignalStream(
      intervalMs: intervalMs,
    );
  }

  /// Monitor mobile (cellular) signal strength in real-time
  ///
  /// Returns a stream that emits [MobileSignalInfo] at the specified interval.
  ///
  /// **Platform Support:**
  /// - ✅ Android (API 21+)
  /// - ❌ iOS (throws [UnsupportedError])
  ///
  /// **Required Permissions (Android):**
  /// ```xml
  /// <uses-permission android:name="android.permission.READ_PHONE_STATE" />
  /// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  /// ```
  ///
  /// **Example:**
  /// ```dart
  /// final service = FlutterNetworkDiagnosticsService();
  /// final subscription = service.getMobileSignalStream().listen((info) {
  ///   print('Operator: ${info.operatorName}');
  ///   print('Network: ${info.networkGeneration.label}');
  ///   print('Signal: ${info.signalStrength} dBm');
  /// });
  ///
  /// subscription.cancel();
  /// ```
  Stream<MobileSignalInfo> getMobileSignalStream({int intervalMs = 1000}) {
    return FlutterNetworkDiagnosticsPlatform.instance.getMobileSignalStream(
      intervalMs: intervalMs,
    );
  }

  /// Get current Wi-Fi signal information (one-time snapshot)
  ///
  /// Returns `null` if:
  /// - Platform is iOS
  /// - Wi-Fi is not connected
  /// - Permissions are not granted
  Future<WifiSignalInfo?> getWifiSignalInfo() {
    return FlutterNetworkDiagnosticsPlatform.instance.getWifiSignalInfo();
  }

  /// Get current mobile signal information (one-time snapshot)
  ///
  /// Returns `null` if:
  /// - Platform is iOS
  /// - Mobile data is not connected
  /// - Permissions are not granted
  Future<MobileSignalInfo?> getMobileSignalInfo() {
    return FlutterNetworkDiagnosticsPlatform.instance.getMobileSignalInfo();
  }
}
