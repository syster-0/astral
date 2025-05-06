import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vpn_service_plugin/vpn_service_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final VpnServicePlugin plugin = VpnServicePlugin();

  testWidgets('VPN Service basic flow test', (WidgetTester tester) async {
    // Test VPN preparation
    final prepareResult = await plugin.prepareVpn();
    expect(prepareResult, isA<Map<String, dynamic>>());

    // Test VPN start
    final startResult = await plugin.startVpn(
      ipv4Addr: "10.126.126.1/24",
      dns: "114.114.114.114",
      routes: ["0.0.0.0/0"],
      mtu: 1500,
    );
    expect(startResult, isA<Map<String, dynamic>>());

    // Give some time for VPN to establish
    await Future.delayed(const Duration(seconds: 2));

    // Test VPN stop
    await plugin.stopVpn();
  });

  testWidgets('VPN Service error handling test', (WidgetTester tester) async {
    // Test invalid IP address format
    expect(
      () => plugin.startVpn(ipv4Addr: "invalid_ip"),
      throwsA(isA<Exception>()),
    );

    // Test invalid route format
    expect(
      () => plugin.startVpn(
        ipv4Addr: "10.126.126.1/24",
        routes: ["invalid_route"],
      ),
      throwsA(isA<Exception>()),
    );
  });
}
