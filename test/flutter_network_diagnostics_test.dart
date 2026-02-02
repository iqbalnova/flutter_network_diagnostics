// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_network_diagnostics/flutter_network_diagnostics.dart';
// import 'package:flutter_network_diagnostics/src/platform/flutter_network_diagnostics_platform_interface.dart';
// import 'package:flutter_network_diagnostics/src/platform/flutter_network_diagnostics_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterNetworkDiagnosticsPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterNetworkDiagnosticsPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterNetworkDiagnosticsPlatform initialPlatform =
//       FlutterNetworkDiagnosticsPlatform.instance;

//   test('$MethodChannelFlutterNetworkDiagnostics is the default instance', () {
//     expect(
//       initialPlatform,
//       isInstanceOf<MethodChannelFlutterNetworkDiagnostics>(),
//     );
//   });

//   test('getPlatformVersion', () async {
//     FlutterNetworkDiagnostics flutterNetworkDiagnosticsPlugin =
//         FlutterNetworkDiagnostics();
//     MockFlutterNetworkDiagnosticsPlatform fakePlatform =
//         MockFlutterNetworkDiagnosticsPlatform();
//     FlutterNetworkDiagnosticsPlatform.instance = fakePlatform;

//     expect(await flutterNetworkDiagnosticsPlugin.getPlatformVersion(), '42');
//   });
// }
