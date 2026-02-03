// flutter_network_diagnostics_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network_diagnostics/src/models/network_diagnostics_data.dart';
import 'package:flutter_network_diagnostics/src/models/signal_info.dart';
import 'package:http/http.dart' as http;

import 'flutter_network_diagnostics_platform_interface.dart';

/// An implementation of [FlutterNetworkDiagnosticsPlatform] that uses method channels.
class MethodChannelFlutterNetworkDiagnostics
    extends FlutterNetworkDiagnosticsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_network_diagnostics');

  // Event channels for real-time monitoring
  static const EventChannel _wifiSignalEventChannel = EventChannel(
    'flutter_network_diagnostics/wifi_signal_stream',
  );

  static const EventChannel _mobileSignalEventChannel = EventChannel(
    'flutter_network_diagnostics/mobile_signal_stream',
  );

  // ============================================================================
  // CONNECTION METHODS
  // ============================================================================

  @override
  Future<String?> getDefaultGatewayIP() async {
    try {
      final String? gatewayIP = await methodChannel.invokeMethod(
        'getDefaultGatewayIP',
      );
      return gatewayIP;
    } on PlatformException catch (e) {
      debugPrint("Failed to get default gateway IP: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getDnsServerPrimary() async {
    try {
      final String? dnsServer = await methodChannel.invokeMethod(
        'getDnsServerPrimary',
      );
      return dnsServer;
    } on PlatformException catch (e) {
      debugPrint("Failed to get primary DNS server: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getDnsServerSecondary() async {
    try {
      final String? dnsServer = await methodChannel.invokeMethod(
        'getDnsServerSecondary',
      );
      return dnsServer;
    } on PlatformException catch (e) {
      debugPrint("Failed to get secondary DNS server: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getExternalIPv4() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=text'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return null;
    } catch (e) {
      debugPrint("Failed to get external IPv4: $e");
      return null;
    }
  }

  @override
  Future<String?> getDefaultGatewayIPv6() async {
    try {
      final String? gatewayIPv6 = await methodChannel.invokeMethod(
        'getDefaultGatewayIPv6',
      );
      return gatewayIPv6;
    } on PlatformException catch (e) {
      debugPrint("Failed to get default gateway IPv6: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getDnsServerIPv6() async {
    try {
      final String? dnsServerIPv6 = await methodChannel.invokeMethod(
        'getDnsServerIPv6',
      );
      return dnsServerIPv6;
    } on PlatformException catch (e) {
      debugPrint("Failed to get DNS server IPv6: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getExternalIPv6() async {
    try {
      final response = await http
          .get(Uri.parse('https://api6.ipify.org?format=text'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final ipAddress = response.body.trim();
        // Check if it's actually IPv6
        if (ipAddress.contains(':')) {
          return ipAddress;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Failed to get external IPv6: $e");
      return null;
    }
  }

  @override
  Future<String?> getHttpProxy() async {
    try {
      final String? httpProxy = await methodChannel.invokeMethod(
        'getHttpProxy',
      );
      return httpProxy;
    } on PlatformException catch (e) {
      debugPrint("Failed to get HTTP proxy: ${e.message}");
      return null;
    }
  }

  // ============================================================================
  // WI-FI INFORMATION METHODS
  // ============================================================================

  @override
  Future<bool> isNetworkConnected() async {
    try {
      final bool? isConnected = await methodChannel.invokeMethod(
        'isNetworkConnected',
      );
      return isConnected ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check network connection: ${e.message}");
      return false;
    }
  }

  @override
  Future<String?> getWifiSSID() async {
    try {
      final String? ssid = await methodChannel.invokeMethod('getWifiSSID');
      return ssid;
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi SSID: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getWifiBSSID() async {
    try {
      final String? bssid = await methodChannel.invokeMethod('getWifiBSSID');
      return bssid;
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi BSSID: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getWifiVendor() async {
    try {
      final String? vendor = await methodChannel.invokeMethod('getWifiVendor');
      return vendor;
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi vendor: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getWifiSecurityType() async {
    try {
      final String? securityType = await methodChannel.invokeMethod(
        'getWifiSecurityType',
      );
      return securityType;
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi security type: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getWifiIPv4Address() async {
    try {
      final String? ipv4 = await methodChannel.invokeMethod(
        'getWifiIPv4Address',
      );
      return ipv4;
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi IPv4 address: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getSubnetMask() async {
    try {
      final String? subnetMask = await methodChannel.invokeMethod(
        'getSubnetMask',
      );
      return subnetMask;
    } on PlatformException catch (e) {
      debugPrint("Failed to get subnet mask: ${e.message}");
      return null;
    }
  }

  @override
  Future<List<String>?> getWifiIPv6Addresses() async {
    try {
      final List<dynamic>? ipv6List = await methodChannel.invokeMethod(
        'getWifiIPv6Addresses',
      );
      return ipv6List?.cast<String>();
    } on PlatformException catch (e) {
      debugPrint("Failed to get WiFi IPv6 addresses: ${e.message}");
      return null;
    }
  }

  @override
  Future<String?> getBroadcastAddress() async {
    try {
      final String? broadcastAddr = await methodChannel.invokeMethod(
        'getBroadcastAddress',
      );
      return broadcastAddr;
    } on PlatformException catch (e) {
      debugPrint("Failed to get broadcast address: ${e.message}");
      return null;
    }
  }

  // ============================================================================
  // COMPREHENSIVE METHOD
  // ============================================================================

  @override
  Future<NetworkDiagnosticsData> getAllNetworkInfo() async {
    final results = await Future.wait([
      // Connection info
      getDefaultGatewayIP(),
      getDnsServerPrimary(),
      getDnsServerSecondary(),
      getExternalIPv4(),
      getDefaultGatewayIPv6(),
      getDnsServerIPv6(),
      getExternalIPv6(),
      getHttpProxy(),

      // WiFi info
      isNetworkConnected(),
      getWifiSSID(),
      getWifiBSSID(),
      getWifiVendor(),
      getWifiSecurityType(),
      getWifiIPv4Address(),
      getSubnetMask(),
      getWifiIPv6Addresses(),
      getBroadcastAddress(),
    ]);

    return NetworkDiagnosticsData(
      // Connection
      defaultGatewayIP: results[0] as String?,
      dnsServerPrimary: results[1] as String?,
      dnsServerSecondary: results[2] as String?,
      externalIPv4: results[3] as String?,
      defaultGatewayIPv6: results[4] as String?,
      dnsServerIPv6: results[5] as String?,
      externalIPv6: results[6] as String?,
      httpProxy: results[7] as String?,

      // WiFi
      isConnected: results[8] as bool,
      ssid: results[9] as String?,
      bssid: results[10] as String?,
      vendor: results[11] as String?,
      securityType: results[12] as String?,
      ipAddressIPv4: results[13] as String?,
      subnetMask: results[14] as String?,
      ipv6Addresses: results[15] as List<String>?,
      broadcastAddress: results[16] as String?,
    );
  }

  // ============================================================================
  // MARK: - REAL-TIME SIGNAL MONITORING
  // ============================================================================

  @override
  Stream<WifiSignalInfo> getWifiSignalStream({int intervalMs = 1000}) {
    return _wifiSignalEventChannel
        .receiveBroadcastStream({'intervalMs': intervalMs})
        .map((event) {
          if (event is Map) {
            final data = Map<String, dynamic>.from(event);
            return WifiSignalInfo.fromJson(data);
          }
          throw Exception('Invalid Wi-Fi signal data format');
        })
        .handleError((error) {
          debugPrint('Wi-Fi signal stream error: $error');
          if (error is PlatformException && error.code == 'UNSUPPORTED') {
            throw UnsupportedError(
              'Wi-Fi signal monitoring is not supported on this platform',
            );
          }
          throw error;
        });
  }

  @override
  Stream<MobileSignalInfo> getMobileSignalStream({int intervalMs = 1000}) {
    return _mobileSignalEventChannel
        .receiveBroadcastStream({'intervalMs': intervalMs})
        .map((event) {
          if (event is Map) {
            final data = Map<String, dynamic>.from(event);
            return MobileSignalInfo.fromJson(data);
          }
          throw Exception('Invalid mobile signal data format');
        })
        .handleError((error) {
          debugPrint('Mobile signal stream error: $error');
          if (error is PlatformException && error.code == 'UNSUPPORTED') {
            throw UnsupportedError(
              'Mobile signal monitoring is not supported on this platform',
            );
          }
          throw error;
        });
  }

  @override
  Future<WifiSignalInfo?> getWifiSignalInfo() async {
    try {
      final Map<dynamic, dynamic>? result = await methodChannel.invokeMethod(
        'getWifiSignalInfo',
      );
      if (result == null) return null;
      return WifiSignalInfo.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      debugPrint('Failed to get Wi-Fi signal info: ${e.message}');
      return null;
    }
  }

  @override
  Future<MobileSignalInfo?> getMobileSignalInfo() async {
    try {
      final Map<dynamic, dynamic>? result = await methodChannel.invokeMethod(
        'getMobileSignalInfo',
      );
      if (result == null) return null;
      return MobileSignalInfo.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      debugPrint('Failed to get mobile signal info: ${e.message}');
      return null;
    }
  }
}
