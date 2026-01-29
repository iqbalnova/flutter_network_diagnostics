import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_network_diagnostics_method_channel.dart';

abstract class FlutterNetworkDiagnosticsPlatform extends PlatformInterface {
  /// Constructs a FlutterNetworkDiagnosticsPlatform.
  FlutterNetworkDiagnosticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNetworkDiagnosticsPlatform _instance = MethodChannelFlutterNetworkDiagnostics();

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
