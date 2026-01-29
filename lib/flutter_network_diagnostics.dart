
import 'flutter_network_diagnostics_platform_interface.dart';

class FlutterNetworkDiagnostics {
  Future<String?> getPlatformVersion() {
    return FlutterNetworkDiagnosticsPlatform.instance.getPlatformVersion();
  }
}
