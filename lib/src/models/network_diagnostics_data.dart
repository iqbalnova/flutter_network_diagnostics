/// Represents all network diagnostic information
class NetworkDiagnosticsData {
  // Connection Information
  final String? defaultGatewayIP;
  final String? dnsServerPrimary;
  final String? dnsServerSecondary;
  final String? externalIPv4;
  final String? defaultGatewayIPv6;
  final String? dnsServerIPv6;
  final String? externalIPv6;
  final String? httpProxy;

  // WiFi Information
  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final String? vendor;
  final String? securityType;
  final String? ipAddressIPv4;
  final String? subnetMask;
  final List<String>? ipv6Addresses;
  final String? broadcastAddress;

  NetworkDiagnosticsData({
    // Connection
    this.defaultGatewayIP,
    this.dnsServerPrimary,
    this.dnsServerSecondary,
    this.externalIPv4,
    this.defaultGatewayIPv6,
    this.dnsServerIPv6,
    this.externalIPv6,
    this.httpProxy,

    // WiFi
    this.isConnected = false,
    this.ssid,
    this.bssid,
    this.vendor,
    this.securityType,
    this.ipAddressIPv4,
    this.subnetMask,
    this.ipv6Addresses,
    this.broadcastAddress,
  });

  @override
  String toString() {
    return '''
SECTION: Connection
-------------------
Default Gateway IP        : ${defaultGatewayIP ?? 'N/A'}
DNS Server IP (Primary)   : ${dnsServerPrimary ?? 'N/A'}
DNS Server IP (Secondary) : ${dnsServerSecondary ?? 'N/A'}
External IP (IPv4)        : ${externalIPv4 ?? 'N/A'}
Default Gateway IPv6      : ${defaultGatewayIPv6 ?? 'N/A'}
DNS Server IPv6           : ${dnsServerIPv6 ?? 'N/A'}
External IP (IPv6)        : ${externalIPv6 ?? 'N/A'}
HTTP Proxy                : ${httpProxy ?? 'N/A'}

SECTION: Wi-Fi Information
--------------------------
Network Connected         : ${isConnected ? 'Yes' : 'No'}
SSID                      : ${ssid ?? 'N/A'}
BSSID                     : ${bssid ?? 'N/A'}
Vendor                    : ${vendor ?? 'N/A'}
Security Type             : ${securityType ?? 'N/A'}
IP Address (IPv4)         : ${ipAddressIPv4 ?? 'N/A'}
Subnet Mask               : ${subnetMask ?? 'N/A'}
IPv6 Address(es)          : ${ipv6Addresses?.join(', ') ?? 'N/A'}
Broadcast Address         : ${broadcastAddress ?? 'N/A'}
''';
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultGatewayIP': defaultGatewayIP,
      'dnsServerPrimary': dnsServerPrimary,
      'dnsServerSecondary': dnsServerSecondary,
      'externalIPv4': externalIPv4,
      'defaultGatewayIPv6': defaultGatewayIPv6,
      'dnsServerIPv6': dnsServerIPv6,
      'externalIPv6': externalIPv6,
      'httpProxy': httpProxy,
      'isConnected': isConnected,
      'ssid': ssid,
      'bssid': bssid,
      'vendor': vendor,
      'securityType': securityType,
      'ipAddressIPv4': ipAddressIPv4,
      'subnetMask': subnetMask,
      'ipv6Addresses': ipv6Addresses,
      'broadcastAddress': broadcastAddress,
    };
  }
}
