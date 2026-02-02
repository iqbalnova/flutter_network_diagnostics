// flutter_network_diagnostics_service.dart (updated main service)
import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';

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
}
