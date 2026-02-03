// lib/src/models/signal_info.dart

/// Base class for signal information
abstract class SignalInfo {
  final DateTime timestamp;
  final bool isConnected;

  const SignalInfo({required this.timestamp, required this.isConnected});

  Map<String, dynamic> toJson();
}

/// Wi-Fi frequency band
enum WifiFrequencyBand {
  band2_4GHz('2.4 GHz', 2400),
  band5GHz('5 GHz', 5000),
  band6GHz('6 GHz', 6000),
  unknown('Unknown', 0);

  final String label;
  final int frequencyMHz;

  const WifiFrequencyBand(this.label, this.frequencyMHz);

  static WifiFrequencyBand fromFrequency(int? frequency) {
    if (frequency == null) return unknown;
    if (frequency >= 2400 && frequency < 2500) return band2_4GHz;
    if (frequency >= 5000 && frequency < 6000) return band5GHz;
    if (frequency >= 5925 && frequency < 7125) return band6GHz;
    return unknown;
  }
}

/// Wi-Fi channel width
enum WifiChannelWidth {
  width20MHz('20 MHz', 20),
  width40MHz('40 MHz', 40),
  width80MHz('80 MHz', 80),
  width160MHz('160 MHz', 160),
  width80Plus80MHz('80+80 MHz', 160),
  unknown('Unknown', 0);

  final String label;
  final int widthMHz;

  const WifiChannelWidth(this.label, this.widthMHz);

  static WifiChannelWidth fromValue(int? width) {
    if (width == null) return unknown;
    switch (width) {
      case 20:
        return width20MHz;
      case 40:
        return width40MHz;
      case 80:
        return width80MHz;
      case 160:
        return width160MHz;
      default:
        return unknown;
    }
  }
}

/// Wi-Fi signal information
class WifiSignalInfo extends SignalInfo {
  /// Signal strength in dBm (typically -100 to -30)
  final int? rssi;

  /// Wi-Fi network SSID
  final String? ssid;

  /// Access point MAC address
  final String? bssid;

  /// Frequency in MHz
  final int? frequency;

  /// Frequency band (2.4/5/6 GHz)
  final WifiFrequencyBand band;

  /// Channel width
  final WifiChannelWidth channelWidth;

  /// Link speed in Mbps
  final int? linkSpeed;

  /// Max supported link speed in Mbps
  final int? maxLinkSpeed;

  /// TX link speed in Mbps (API 31+)
  final int? txLinkSpeed;

  /// RX link speed in Mbps (API 31+)
  final int? rxLinkSpeed;

  /// Wi-Fi standard (e.g., "Wi-Fi 6", "Wi-Fi 5")
  final String? wifiStandard;

  /// Signal level as percentage (0-100)
  int? get signalLevel {
    if (rssi == null) return null;
    // Convert dBm to percentage (rough approximation)
    // Assuming -100 dBm = 0%, -30 dBm = 100%
    final clamped = rssi!.clamp(-100, -30);
    return ((clamped + 100) * 100 / 70).round();
  }

  /// Signal quality description
  String get signalQuality {
    if (rssi == null) return 'Unknown';
    if (rssi! >= -50) return 'Excellent';
    if (rssi! >= -60) return 'Good';
    if (rssi! >= -70) return 'Fair';
    if (rssi! >= -80) return 'Weak';
    return 'Very Weak';
  }

  const WifiSignalInfo({
    required super.timestamp,
    required super.isConnected,
    this.rssi,
    this.ssid,
    this.bssid,
    this.frequency,
    this.band = WifiFrequencyBand.unknown,
    this.channelWidth = WifiChannelWidth.unknown,
    this.linkSpeed,
    this.maxLinkSpeed,
    this.txLinkSpeed,
    this.rxLinkSpeed,
    this.wifiStandard,
  });

  factory WifiSignalInfo.fromJson(Map<String, dynamic> json) {
    return WifiSignalInfo(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isConnected: json['isConnected'] as bool? ?? false,
      rssi: json['rssi'] as int?,
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String?,
      frequency: json['frequency'] as int?,
      band: WifiFrequencyBand.fromFrequency(json['frequency'] as int?),
      channelWidth: WifiChannelWidth.fromValue(json['channelWidth'] as int?),
      linkSpeed: json['linkSpeed'] as int?,
      maxLinkSpeed: json['maxLinkSpeed'] as int?,
      txLinkSpeed: json['txLinkSpeed'] as int?,
      rxLinkSpeed: json['rxLinkSpeed'] as int?,
      wifiStandard: json['wifiStandard'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isConnected': isConnected,
    'rssi': rssi,
    'ssid': ssid,
    'bssid': bssid,
    'frequency': frequency,
    'band': band.label,
    'channelWidth': channelWidth.label,
    'linkSpeed': linkSpeed,
    'maxLinkSpeed': maxLinkSpeed,
    'txLinkSpeed': txLinkSpeed,
    'rxLinkSpeed': rxLinkSpeed,
    'wifiStandard': wifiStandard,
    'signalLevel': signalLevel,
    'signalQuality': signalQuality,
  };

  WifiSignalInfo copyWith({
    DateTime? timestamp,
    bool? isConnected,
    int? rssi,
    String? ssid,
    String? bssid,
    int? frequency,
    WifiFrequencyBand? band,
    WifiChannelWidth? channelWidth,
    int? linkSpeed,
    int? maxLinkSpeed,
    int? txLinkSpeed,
    int? rxLinkSpeed,
    String? wifiStandard,
  }) {
    return WifiSignalInfo(
      timestamp: timestamp ?? this.timestamp,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      frequency: frequency ?? this.frequency,
      band: band ?? this.band,
      channelWidth: channelWidth ?? this.channelWidth,
      linkSpeed: linkSpeed ?? this.linkSpeed,
      maxLinkSpeed: maxLinkSpeed ?? this.maxLinkSpeed,
      txLinkSpeed: txLinkSpeed ?? this.txLinkSpeed,
      rxLinkSpeed: rxLinkSpeed ?? this.rxLinkSpeed,
      wifiStandard: wifiStandard ?? this.wifiStandard,
    );
  }
}

/// Mobile network generation
enum NetworkGeneration {
  unknown('Unknown'),
  gen2G('2G'),
  gen3G('3G'),
  gen4G('4G'),
  gen5G('5G');

  final String label;
  const NetworkGeneration(this.label);

  static NetworkGeneration fromString(String? value) {
    if (value == null) return unknown;
    switch (value.toUpperCase()) {
      case '2G':
        return gen2G;
      case '3G':
        return gen3G;
      case '4G':
      case 'LTE':
        return gen4G;
      case '5G':
      case 'NR':
        return gen5G;
      default:
        return unknown;
    }
  }
}

/// Mobile network technology
enum NetworkTechnology {
  unknown('Unknown'),
  gprs('GPRS'),
  edge('EDGE'),
  umts('UMTS'),
  hsdpa('HSDPA'),
  hsupa('HSUPA'),
  hspa('HSPA'),
  cdma('CDMA'),
  evdo('EVDO'),
  lte('LTE'),
  lteCa('LTE-CA'),
  nr('5G NR'),
  nrNsa('5G NSA'),
  nrSa('5G SA');

  final String label;
  const NetworkTechnology(this.label);

  static NetworkTechnology fromString(String? value) {
    if (value == null) return unknown;
    for (var tech in NetworkTechnology.values) {
      if (tech.label.toUpperCase() == value.toUpperCase()) {
        return tech;
      }
    }
    return unknown;
  }
}

/// Mobile (cellular) signal information
class MobileSignalInfo extends SignalInfo {
  /// Mobile operator name (e.g., "TELKOMSEL")
  final String? operatorName;

  /// Network generation (2G/3G/4G/5G)
  final NetworkGeneration networkGeneration;

  /// Network technology (LTE, NR, etc.)
  final NetworkTechnology networkTechnology;

  /// Signal strength in dBm
  /// - For GSM/UMTS: RSSI
  /// - For LTE: RSRP (Reference Signal Received Power)
  /// - For 5G NR: SS-RSRP
  final int? signalStrength;

  /// ASU (Arbitrary Strength Unit) level
  final int? asuLevel;

  /// Signal level (0-4 bars)
  final int? level;

  // Advanced metrics (LTE/5G specific)

  /// RSRP - Reference Signal Received Power (LTE/5G)
  final int? rsrp;

  /// RSRQ - Reference Signal Received Quality (LTE/5G)
  final int? rsrq;

  /// RSSNR/SINR - Signal to Interference plus Noise Ratio (LTE/5G)
  final int? sinr;

  /// Cell ID
  final String? cellId;

  /// Is roaming
  final bool isRoaming;

  /// Signal level as percentage (0-100)
  int? get signalLevel {
    if (signalStrength == null) return null;
    // Convert dBm to percentage
    // LTE: -140 to -44 dBm
    // 5G: -140 to -44 dBm
    final clamped = signalStrength!.clamp(-140, -44);
    return ((clamped + 140) * 100 / 96).round();
  }

  /// Signal quality description
  String get signalQuality {
    if (signalStrength == null) return 'Unknown';
    // For LTE/5G (RSRP-based)
    if (networkGeneration == NetworkGeneration.gen4G ||
        networkGeneration == NetworkGeneration.gen5G) {
      if (signalStrength! >= -80) return 'Excellent';
      if (signalStrength! >= -90) return 'Good';
      if (signalStrength! >= -100) return 'Fair';
      if (signalStrength! >= -110) return 'Weak';
      return 'Very Weak';
    }
    // For 2G/3G (RSSI-based)
    if (signalStrength! >= -70) return 'Excellent';
    if (signalStrength! >= -85) return 'Good';
    if (signalStrength! >= -100) return 'Fair';
    if (signalStrength! >= -110) return 'Weak';
    return 'Very Weak';
  }

  const MobileSignalInfo({
    required super.timestamp,
    required super.isConnected,
    this.operatorName,
    this.networkGeneration = NetworkGeneration.unknown,
    this.networkTechnology = NetworkTechnology.unknown,
    this.signalStrength,
    this.asuLevel,
    this.level,
    this.rsrp,
    this.rsrq,
    this.sinr,
    this.cellId,
    this.isRoaming = false,
  });

  factory MobileSignalInfo.fromJson(Map<String, dynamic> json) {
    return MobileSignalInfo(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isConnected: json['isConnected'] as bool? ?? false,
      operatorName: json['operatorName'] as String?,
      networkGeneration: NetworkGeneration.fromString(
        json['networkGeneration'] as String?,
      ),
      networkTechnology: NetworkTechnology.fromString(
        json['networkTechnology'] as String?,
      ),
      signalStrength: json['signalStrength'] as int?,
      asuLevel: json['asuLevel'] as int?,
      level: json['level'] as int?,
      rsrp: json['rsrp'] as int?,
      rsrq: json['rsrq'] as int?,
      sinr: json['sinr'] as int?,
      cellId: json['cellId'] as String?,
      isRoaming: json['isRoaming'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isConnected': isConnected,
    'operatorName': operatorName,
    'networkGeneration': networkGeneration.label,
    'networkTechnology': networkTechnology.label,
    'signalStrength': signalStrength,
    'asuLevel': asuLevel,
    'level': level,
    'rsrp': rsrp,
    'rsrq': rsrq,
    'sinr': sinr,
    'cellId': cellId,
    'isRoaming': isRoaming,
    'signalLevel': signalLevel,
    'signalQuality': signalQuality,
  };

  MobileSignalInfo copyWith({
    DateTime? timestamp,
    bool? isConnected,
    String? operatorName,
    NetworkGeneration? networkGeneration,
    NetworkTechnology? networkTechnology,
    int? signalStrength,
    int? asuLevel,
    int? level,
    int? rsrp,
    int? rsrq,
    int? sinr,
    String? cellId,
    bool? isRoaming,
  }) {
    return MobileSignalInfo(
      timestamp: timestamp ?? this.timestamp,
      isConnected: isConnected ?? this.isConnected,
      operatorName: operatorName ?? this.operatorName,
      networkGeneration: networkGeneration ?? this.networkGeneration,
      networkTechnology: networkTechnology ?? this.networkTechnology,
      signalStrength: signalStrength ?? this.signalStrength,
      asuLevel: asuLevel ?? this.asuLevel,
      level: level ?? this.level,
      rsrp: rsrp ?? this.rsrp,
      rsrq: rsrq ?? this.rsrq,
      sinr: sinr ?? this.sinr,
      cellId: cellId ?? this.cellId,
      isRoaming: isRoaming ?? this.isRoaming,
    );
  }
}
