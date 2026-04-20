import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Diagnostics Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MyHomePage(title: 'Flutter Network Diagnostics'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterNetworkDiagnosticsService _diagnosticsService =
      FlutterNetworkDiagnosticsService();

  StreamSubscription<MobileSignalInfo>? _mobileSignalSubscription;
  MobileSignalInfo? _mobileSignalInfo;
  bool _isMonitoring = false;
  bool _isLoading = false;
  String _statusMessage =
      'Tekan "Request Permission" lalu "Start Monitoring" untuk mulai.';

  @override
  void dispose() {
    _mobileSignalSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _statusMessage =
            'Demo permission ini hanya untuk Android/iOS. Platform sekarang: ${Platform.operatingSystem}.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Meminta permission location dan phone...';
    });

    try {
      final locationStatus = await Permission.location.request();
      final phoneStatus = await Permission.phone.request();

      if (!mounted) {
        return;
      }

      if (locationStatus.isGranted && phoneStatus.isGranted) {
        setState(() {
          _statusMessage =
              'Permission granted ✅ Kamu bisa mulai monitoring signal mobile.';
        });
        return;
      }

      if (locationStatus.isPermanentlyDenied ||
          phoneStatus.isPermanentlyDenied) {
        setState(() {
          _statusMessage =
              'Permission ditolak permanen. Membuka pengaturan aplikasi...';
        });
        await openAppSettings();
        return;
      }

      setState(() {
        _statusMessage =
            'Permission belum lengkap. Location: ${locationStatus.name}, Phone: ${phoneStatus.name}.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Gagal request permission: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _hasRequiredPermissions() async {
    final locationStatus = await Permission.location.status;
    final phoneStatus = await Permission.phone.status;
    return locationStatus.isGranted && phoneStatus.isGranted;
  }

  Future<void> _startMobileMonitoring() async {
    if (!Platform.isAndroid) {
      setState(() {
        _statusMessage =
            'getMobileSignalStream saat ini hanya didukung di Android.';
      });
      return;
    }

    final hasPermissions = await _hasRequiredPermissions();
    if (!hasPermissions) {
      setState(() {
        _statusMessage =
            'Permission belum diberikan. Jalankan Request Permission dulu.';
      });
      return;
    }

    await _mobileSignalSubscription?.cancel();

    _mobileSignalSubscription = _diagnosticsService
        .getMobileSignalStream(intervalMs: 1500)
        .listen(
          (info) {
            if (!mounted) {
              return;
            }
            setState(() {
              _mobileSignalInfo = info;
              _isMonitoring = true;
              _statusMessage =
                  'Monitoring berjalan • Update terakhir: ${info.timestamp.toLocal()}';
            });
          },
          onError: (Object error) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isMonitoring = false;
              _statusMessage = 'Error stream mobile signal: $error';
            });
          },
          onDone: () {
            if (!mounted) {
              return;
            }

            setState(() {
              _isMonitoring = false;
              _statusMessage = 'Monitoring selesai.';
            });
          },
        );

    setState(() {
      _isMonitoring = true;
      _statusMessage = 'Mulai subscribe stream mobile signal...';
    });
  }

  Future<void> _stopMobileMonitoring() async {
    await _mobileSignalSubscription?.cancel();
    _mobileSignalSubscription = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _isMonitoring = false;
      _statusMessage = 'Monitoring dihentikan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _mobileSignalInfo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile Signal Monitor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_statusMessage),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _requestPermissions,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Request Permission'),
                      ),
                      FilledButton.icon(
                        onPressed: (_isLoading || _isMonitoring)
                            ? null
                            : _startMobileMonitoring,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Monitoring'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isMonitoring ? _stopMobileMonitoring : null,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signal Snapshot',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Connected',
                    value: '${info?.isConnected ?? false}',
                  ),
                  _InfoRow(label: 'Operator', value: info?.operatorName ?? '-'),
                  _InfoRow(
                    label: 'Generation',
                    value: info?.networkGeneration.label ?? '-',
                  ),
                  _InfoRow(
                    label: 'Technology',
                    value: info?.networkTechnology.label ?? '-',
                  ),
                  _InfoRow(
                    label: 'Signal Strength',
                    value: info?.signalStrength != null
                        ? '${info!.signalStrength} dBm'
                        : '-',
                  ),
                  _InfoRow(
                    label: 'Signal Quality',
                    value: info?.signalQuality ?? '-',
                  ),
                  _InfoRow(
                    label: 'Signal Level',
                    value: info?.signalLevel != null
                        ? '${info!.signalLevel}%'
                        : '-',
                  ),
                  _InfoRow(
                    label: 'RSRP',
                    value: info?.rsrp != null ? '${info!.rsrp} dBm' : '-',
                  ),
                  _InfoRow(label: 'RSRQ', value: info?.rsrq?.toString() ?? '-'),
                  _InfoRow(label: 'SINR', value: info?.sinr?.toString() ?? '-'),
                  _InfoRow(label: 'Cell ID', value: info?.cellId ?? '-'),
                  _InfoRow(
                    label: 'Roaming',
                    value: '${info?.isRoaming ?? false}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
