// flutter_network_diagnostics_platform_interface.dart
import 'package:flutter_network_diagnostics/src/models/network_diagnostics_data.dart';
import 'package:flutter_network_diagnostics/src/models/signal_info.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_network_diagnostics_method_channel.dart';

abstract class FlutterNetworkDiagnosticsPlatform extends PlatformInterface {
  /// Constructs a FlutterNetworkDiagnosticsPlatform.
  FlutterNetworkDiagnosticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNetworkDiagnosticsPlatform _instance =
      MethodChannelFlutterNetworkDiagnostics();

  /// The default instance of [FlutterNetworkDiagnosticsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNetworkDiagnostics].
  static FlutterNetworkDiagnosticsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNetworkDiagnosticsPlatform] when
  /// they register themselves.
  static set instance(FlutterNetworkDiagnosticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ============================================================================
  // CONNECTION METHODS
  // ============================================================================

  /// Get the default gateway IP address (IPv4)
  Future<String?> getDefaultGatewayIP() {
    throw UnimplementedError('getDefaultGatewayIP() has not been implemented.');
  }

  /// Get the primary DNS server IP address
  Future<String?> getDnsServerPrimary() {
    throw UnimplementedError('getDnsServerPrimary() has not been implemented.');
  }

  /// Get the secondary DNS server IP address
  Future<String?> getDnsServerSecondary() {
    throw UnimplementedError(
      'getDnsServerSecondary() has not been implemented.',
    );
  }

  /// Get the external public IPv4 address
  Future<String?> getExternalIPv4() {
    throw UnimplementedError('getExternalIPv4() has not been implemented.');
  }

  /// Get the default gateway IPv6 address
  Future<String?> getDefaultGatewayIPv6() {
    throw UnimplementedError(
      'getDefaultGatewayIPv6() has not been implemented.',
    );
  }

  /// Get the DNS server IPv6 address
  Future<String?> getDnsServerIPv6() {
    throw UnimplementedError('getDnsServerIPv6() has not been implemented.');
  }

  /// Get the external public IPv6 address
  Future<String?> getExternalIPv6() {
    throw UnimplementedError('getExternalIPv6() has not been implemented.');
  }

  /// Get HTTP proxy configuration
  Future<String?> getHttpProxy() {
    throw UnimplementedError('getHttpProxy() has not been implemented.');
  }

  // ============================================================================
  // WI-FI INFORMATION METHODS
  // ============================================================================

  /// Check if device is connected to a network
  Future<bool> isNetworkConnected() {
    throw UnimplementedError('isNetworkConnected() has not been implemented.');
  }

  /// Get the WiFi network name (SSID)
  Future<String?> getWifiSSID() {
    throw UnimplementedError('getWifiSSID() has not been implemented.');
  }

  /// Get the WiFi BSSID (Basic Service Set Identifier)
  Future<String?> getWifiBSSID() {
    throw UnimplementedError('getWifiBSSID() has not been implemented.');
  }

  /// Get the vendor/manufacturer of the WiFi access point
  Future<String?> getWifiVendor() {
    throw UnimplementedError('getWifiVendor() has not been implemented.');
  }

  /// Get the WiFi security type
  Future<String?> getWifiSecurityType() {
    throw UnimplementedError('getWifiSecurityType() has not been implemented.');
  }

  /// Get the device's IPv4 address on the local network
  Future<String?> getWifiIPv4Address() {
    throw UnimplementedError('getWifiIPv4Address() has not been implemented.');
  }

  /// Get the subnet mask of the local network
  Future<String?> getSubnetMask() {
    throw UnimplementedError('getSubnetMask() has not been implemented.');
  }

  /// Get all IPv6 addresses assigned to the device
  Future<List<String>?> getWifiIPv6Addresses() {
    throw UnimplementedError(
      'getWifiIPv6Addresses() has not been implemented.',
    );
  }

  /// Get the broadcast address of the local network
  Future<String?> getBroadcastAddress() {
    throw UnimplementedError('getBroadcastAddress() has not been implemented.');
  }

  // ============================================================================
  // COMPREHENSIVE METHOD
  // ============================================================================

  /// Get all network diagnostic information at once
  Future<NetworkDiagnosticsData> getAllNetworkInfo() {
    throw UnimplementedError('getAllNetworkInfo() has not been implemented.');
  }

  // ============================================================================
  // MARK: -REAL-TIME SIGNAL MONITORING (Android-only)
  // ============================================================================

  /// Start monitoring Wi-Fi signal strength in real-time
  ///
  /// Returns a stream of [WifiSignalInfo] with the specified update interval.
  /// On iOS, this returns a stream with a single error event indicating
  /// the feature is not supported.
  ///
  /// [intervalMs] - Update interval in milliseconds (default: 1000ms)
  ///
  /// Required Android permissions:
  /// - ACCESS_FINE_LOCATION (Android 8.1+)
  /// - ACCESS_WIFI_STATE
  Stream<WifiSignalInfo> getWifiSignalStream({int intervalMs = 1000}) {
    throw UnimplementedError('getWifiSignalStream() has not been implemented.');
  }

  /// Start monitoring mobile (cellular) signal strength in real-time
  ///
  /// Returns a stream of [MobileSignalInfo] with the specified update interval.
  /// On iOS, this returns a stream with a single error event indicating
  /// the feature is not supported.
  ///
  /// [intervalMs] - Update interval in milliseconds (default: 1000ms)
  ///
  /// Required Android permissions:
  /// - ACCESS_FINE_LOCATION (Android 8.1+)
  /// - READ_PHONE_STATE
  Stream<MobileSignalInfo> getMobileSignalStream({int intervalMs = 1000}) {
    throw UnimplementedError(
      'getMobileSignalStream() has not been implemented.',
    );
  }

  Future<WifiSignalInfo?> getWifiSignalInfo() {
    throw UnimplementedError('getWifiSignalInfo() has not been implemented.');
  }

  Future<MobileSignalInfo?> getMobileSignalInfo() {
    throw UnimplementedError('getMobileSignalInfo() has not been implemented.');
  }
}
