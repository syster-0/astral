import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

// 全局配置实例
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig());

enum VpnRunningState {
  stopped, // VPN已停止
  starting, // VPN正在启动
  running, // VPN正在运行
}

class VpnStatus {
  final VpnRunningState state;
  final String? ipv4Addr; // null 表示未定义
  final int? ipv4Cidr; // null 表示未定义
  final List<String> routes;

  const VpnStatus({
    this.state = VpnRunningState.stopped,
    this.ipv4Addr,
    this.ipv4Cidr,
    this.routes = const [],
  });
}

// 计数器相关
class CountNotifier extends StateNotifier<int> {
  CountNotifier() : super(0);

  void increment() => state++;
}

final countProvider =
    StateNotifierProvider<CountNotifier, int>((ref) => CountNotifier());

// 房间名相关
class RoomNameNotifier extends StateNotifier<String> {
  final AppConfig _config;

  RoomNameNotifier(this._config) : super(_config.roomName);

  void setRoomName(String value) {
    _config.setRoomName(value);
    state = value;
  }
}

final roomNameProvider = StateNotifierProvider<RoomNameNotifier, String>((ref) {
  return RoomNameNotifier(ref.watch(appConfigProvider));
});

// 房间密码相关
class RoomPasswordNotifier extends StateNotifier<String> {
  final AppConfig _config;

  RoomPasswordNotifier(this._config) : super(_config.roomPassword);

  void setRoomPassword(String value) {
    _config.setRoomPassword(value);
    state = value;
  }
}

final roomPasswordProvider =
    StateNotifierProvider<RoomPasswordNotifier, String>((ref) {
  return RoomPasswordNotifier(ref.watch(appConfigProvider));
});

// 用户名相关
class UsernameNotifier extends StateNotifier<String> {
  final AppConfig _config;

  UsernameNotifier(this._config) : super(_config.username);

  void setUsername(String value) {
    _config.setUsername(value);
    state = value;
  }
}

final usernameProvider = StateNotifierProvider<UsernameNotifier, String>((ref) {
  return UsernameNotifier(ref.watch(appConfigProvider));
});

// 虚拟IP相关
class VirtualIPNotifier extends StateNotifier<String> {
  final AppConfig _config;

  VirtualIPNotifier(this._config) : super(_config.virtualIP);

  void setVirtualIP(String value) {
    _config.setVirtualIP(value);
    state = value;
  }
}

final virtualIPProvider =
    StateNotifierProvider<VirtualIPNotifier, String>((ref) {
  return VirtualIPNotifier(ref.watch(appConfigProvider));
});

// 动态获取IP设置相关
class DynamicIPNotifier extends StateNotifier<bool> {
  final AppConfig _config;

  DynamicIPNotifier(this._config) : super(_config.dynamicIP);

  void setDynamicIP(bool value) {
    _config.setDynamicIP(value);
    state = value;
  }
}

final dynamicIPProvider = StateNotifierProvider<DynamicIPNotifier, bool>((ref) {
  return DynamicIPNotifier(ref.watch(appConfigProvider));
});

// 服务器列表相关
class ServerListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final AppConfig _config;

  ServerListNotifier(this._config) : super(_config.serverList);

  void setServerList(List<Map<String, dynamic>> value) {
    List<Map<String, dynamic>> convertedList = value.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
    _config.setServerList(convertedList);
    state = convertedList;
  }

  void setServerSelected(String url, bool selected) {
    final servers = [...state];
    for (var i = 0; i < servers.length; i++) {
      if (servers[i]['url'] == url) {
        servers[i]['selected'] = selected;
      }
    }
    setServerList(servers);
  }
}

final serverListProvider =
    StateNotifierProvider<ServerListNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return ServerListNotifier(ref.watch(appConfigProvider));
});

// 选中的服务器IP
final serverIPProvider = Provider<List<String>>((ref) {
  final serverList = ref.watch(serverListProvider);

  try {
    final selected =
        serverList.where((server) => server['selected'] == true).toList();

    if (selected.isEmpty && serverList.isNotEmpty) {
      final firstServer = serverList.first;
      if (firstServer['url'] is String) {
        return [firstServer['url'] as String];
      }
      return [];
    }

    return selected
        .where((server) => server['url'] is String)
        .map((server) => server['url'] as String)
        .toList();
  } catch (e) {
    debugPrint('获取服务器IP时出错: $e');
    return [];
  }
});

//返回选中的服务器
final selectedServerProvider = Provider<List<ServerConfig>>((ref) {
  final serverList = ref.watch(serverListProvider);
  final selected =
      serverList.where((server) => server['selected'] == true).toList();
  if (selected.isEmpty) {
    return [];
  }

  // 将选中的服务器转换为ServerConfig对象列表
  return selected
      .map((server) => ServerConfig(
            url: server['url'] ?? '',
            name: server['name'] ?? '',
            selected: true,
            tcp: server['tcp'] ?? true,
            udp: server['udp'] ?? true,
            ws: server['ws'] ?? false,
            wss: server['wss'] ?? false,
            quic: server['quic'] ?? false,
          ))
      .toList();
});

// 节点列表相关
class NodesNotifier extends StateNotifier<List<KVNodeInfo>> {
  NodesNotifier() : super([]);

  void setNodes(List<KVNodeInfo> value) {
    state = value;
  }
}

final nodesProvider = StateNotifierProvider<NodesNotifier, List<KVNodeInfo>>(
    (ref) => NodesNotifier());

// 高级配置相关
class AdvancedConfigNotifier extends StateNotifier<Map<String, dynamic>> {
  final AppConfig _config;

  AdvancedConfigNotifier(this._config)
      : super({
          'defaultProtocol': _config.advanced.defaultProtocol,
          'devName': _config.advanced.devName,
          'enableEncryption': _config.advanced.enableEncryption,
          'enableIpv6': _config.advanced.enableIpv6,
          'mtu': _config.advanced.mtu,
          'latencyFirst': _config.advanced.latencyFirst,
          'enableExitNode': _config.advanced.enableExitNode,
          'proxyForwardBySystem': _config.advanced.proxyForwardBySystem,
          'noTun': _config.advanced.noTun,
          'useSmoltcp': _config.advanced.useSmoltcp,
          'relayNetworkWhitelist': _config.advanced.relayNetworkWhitelist,
          'disableP2p': _config.advanced.disableP2p,
          'relayAllPeerRpc': _config.advanced.relayAllPeerRpc,
          'disableUdpHolePunching': _config.advanced.disableUdpHolePunching,
          'multiThread': _config.advanced.multiThread,
          'dataCompressAlgo': _config.advanced.dataCompressAlgo,
          'bindDevice': _config.advanced.bindDevice,
          'enableKcpProxy': _config.advanced.enableKcpProxy,
          'disableKcpInput': _config.advanced.disableKcpInput,
          'disableRelayKcp': _config.advanced.disableRelayKcp,
        });

  // 更新单个配置项
  Future<void> updateConfig(String key, dynamic value) async {
    if (state.containsKey(key) && state[key] != value) {
      final newState = {...state, key: value};
      state = newState;

      // 使用通用方法更新配置
      await _config.updateAdvancedConfig(
        defaultProtocol: key == 'defaultProtocol' ? value : null,
        devName: key == 'devName' ? value : null,
        enableEncryption: key == 'enableEncryption' ? value : null,
        enableIpv6: key == 'enableIpv6' ? value : null,
        mtu: key == 'mtu' ? value : null,
        latencyFirst: key == 'latencyFirst' ? value : null,
        enableExitNode: key == 'enableExitNode' ? value : null,
        proxyForwardBySystem: key == 'proxyForwardBySystem' ? value : null,
        noTun: key == 'noTun' ? value : null,
        useSmoltcp: key == 'useSmoltcp' ? value : null,
        relayNetworkWhitelist: key == 'relayNetworkWhitelist' ? value : null,
        disableP2p: key == 'disableP2p' ? value : null,
        relayAllPeerRpc: key == 'relayAllPeerRpc' ? value : null,
        disableUdpHolePunching: key == 'disableUdpHolePunching' ? value : null,
        multiThread: key == 'multiThread' ? value : null,
        dataCompressAlgo: key == 'dataCompressAlgo' ? value : null,
        bindDevice: key == 'bindDevice' ? value : null,
        enableKcpProxy: key == 'enableKcpProxy' ? value : null,
        disableKcpInput: key == 'disableKcpInput' ? value : null,
        disableRelayKcp: key == 'disableRelayKcp' ? value : null,
      );
    }
  }

  // 批量更新配置
  Future<void> updateMultipleConfigs(Map<String, dynamic> updates) async {
    final newState = {...state, ...updates};
    state = newState;

    // 使用通用方法更新配置
    await _config.updateAdvancedConfig(
      defaultProtocol: updates.containsKey('defaultProtocol')
          ? updates['defaultProtocol']
          : null,
      devName: updates.containsKey('devName') ? updates['devName'] : null,
      enableEncryption: updates.containsKey('enableEncryption')
          ? updates['enableEncryption']
          : null,
      enableIpv6:
          updates.containsKey('enableIpv6') ? updates['enableIpv6'] : null,
      mtu: updates.containsKey('mtu') ? updates['mtu'] : null,
      latencyFirst:
          updates.containsKey('latencyFirst') ? updates['latencyFirst'] : null,
      enableExitNode: updates.containsKey('enableExitNode')
          ? updates['enableExitNode']
          : null,
      proxyForwardBySystem: updates.containsKey('proxyForwardBySystem')
          ? updates['proxyForwardBySystem']
          : null,
      noTun: updates.containsKey('noTun') ? updates['noTun'] : null,
      useSmoltcp:
          updates.containsKey('useSmoltcp') ? updates['useSmoltcp'] : null,
      relayNetworkWhitelist: updates.containsKey('relayNetworkWhitelist')
          ? updates['relayNetworkWhitelist']
          : null,
      disableP2p:
          updates.containsKey('disableP2p') ? updates['disableP2p'] : null,
      relayAllPeerRpc: updates.containsKey('relayAllPeerRpc')
          ? updates['relayAllPeerRpc']
          : null,
      disableUdpHolePunching: updates.containsKey('disableUdpHolePunching')
          ? updates['disableUdpHolePunching']
          : null,
      multiThread:
          updates.containsKey('multiThread') ? updates['multiThread'] : null,
      dataCompressAlgo: updates.containsKey('dataCompressAlgo')
          ? updates['dataCompressAlgo']
          : null,
      bindDevice:
          updates.containsKey('bindDevice') ? updates['bindDevice'] : null,
      enableKcpProxy: updates.containsKey('enableKcpProxy')
          ? updates['enableKcpProxy']
          : null,
      disableKcpInput: updates.containsKey('disableKcpInput')
          ? updates['disableKcpInput']
          : null,
      disableRelayKcp: updates.containsKey('disableRelayKcp')
          ? updates['disableRelayKcp']
          : null,
    );
  }

  // 为每个配置项提供单独的更新方法
  Future<void> setDefaultProtocol(String value) async =>
      updateConfig('defaultProtocol', value);
  Future<void> setDevName(String value) async => updateConfig('devName', value);
  Future<void> setEnableEncryption(bool value) async =>
      updateConfig('enableEncryption', value);
  Future<void> setEnableIpv6(bool value) async =>
      updateConfig('enableIpv6', value);
  Future<void> setMtu(int value) async => updateConfig('mtu', value);
  Future<void> setLatencyFirst(bool value) async =>
      updateConfig('latencyFirst', value);
  Future<void> setEnableExitNode(bool value) async =>
      updateConfig('enableExitNode', value);
  Future<void> setProxyForwardBySystem(bool value) async =>
      updateConfig('proxyForwardBySystem', value);
  Future<void> setNoTun(bool value) async => updateConfig('noTun', value);
  Future<void> setUseSmoltcp(bool value) async =>
      updateConfig('useSmoltcp', value);
  Future<void> setRelayNetworkWhitelist(String value) async =>
      updateConfig('relayNetworkWhitelist', value);
  Future<void> setDisableP2p(bool value) async =>
      updateConfig('disableP2p', value);
  Future<void> setRelayAllPeerRpc(bool value) async =>
      updateConfig('relayAllPeerRpc', value);
  Future<void> setDisableUdpHolePunching(bool value) async =>
      updateConfig('disableUdpHolePunching', value);
  Future<void> setMultiThread(bool value) async =>
      updateConfig('multiThread', value);
  Future<void> setDataCompressAlgo(String value) async =>
      updateConfig('dataCompressAlgo', value);
  Future<void> setBindDevice(bool value) async =>
      updateConfig('bindDevice', value);
  Future<void> setEnableKcpProxy(bool value) async =>
      updateConfig('enableKcpProxy', value);
  Future<void> setDisableKcpInput(bool value) async =>
      updateConfig('disableKcpInput', value);
  Future<void> setDisableRelayKcp(bool value) async =>
      updateConfig('disableRelayKcp', value);
}

final advancedConfigProvider =
    StateNotifierProvider<AdvancedConfigNotifier, Map<String, dynamic>>((ref) {
  return AdvancedConfigNotifier(ref.watch(appConfigProvider));
});

// 为每个高级配置项创建单独的Provider，方便在UI中使用
final defaultProtocolProvider = Provider<String>((ref) {
  return ref.watch(advancedConfigProvider)['defaultProtocol'];
});

final devNameProvider = Provider<String>((ref) {
  return ref.watch(advancedConfigProvider)['devName'];
});

final enableEncryptionProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['enableEncryption'];
});

final enableIpv6Provider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['enableIpv6'];
});

final mtuProvider = Provider<int>((ref) {
  return ref.watch(advancedConfigProvider)['mtu'];
});

final latencyFirstProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['latencyFirst'];
});

final enableExitNodeProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['enableExitNode'];
});

final proxyForwardBySystemProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['proxyForwardBySystem'];
});

final noTunProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['noTun'];
});

final useSmoltcpProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['useSmoltcp'];
});

final relayNetworkWhitelistProvider = Provider<String>((ref) {
  return ref.watch(advancedConfigProvider)['relayNetworkWhitelist'];
});

final disableP2pProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['disableP2p'];
});

final relayAllPeerRpcProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['relayAllPeerRpc'];
});

final disableUdpHolePunchingProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['disableUdpHolePunching'];
});

final multiThreadProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['multiThread'];
});

final dataCompressAlgoProvider = Provider<String>((ref) {
  return ref.watch(advancedConfigProvider)['dataCompressAlgo'];
});

final bindDeviceProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['bindDevice'];
});

final enableKcpProxyProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['enableKcpProxy'];
});

final disableKcpInputProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['disableKcpInput'];
});

final disableRelayKcpProvider = Provider<bool>((ref) {
  return ref.watch(advancedConfigProvider)['disableRelayKcp'];
});

class VpnStatusNotifier extends StateNotifier<VpnStatus> {
  VpnStatusNotifier() : super(const VpnStatus());

  @override
  set state(VpnStatus value) {
    VpnStatus previous = state;
    super.state = value;

    // 状态发生变化时的处理
    if (previous.state != value.state) {
      debugPrint('VPN状态变化: ${previous.state} -> ${value.state}');
    }
    if (previous.ipv4Addr != value.ipv4Addr) {
      debugPrint('IPv4地址变化: ${previous.ipv4Addr} -> ${value.ipv4Addr}');
    }
    if (previous.ipv4Cidr != value.ipv4Cidr) {
      debugPrint('CIDR变化: ${previous.ipv4Cidr} -> ${value.ipv4Cidr}');
    }
    if (!listEquals(previous.routes, value.routes)) {
      debugPrint('路由变化: ${previous.routes} -> ${value.routes}');
    }
  }

  void updateStatus({
    VpnRunningState? state,
    String? ipv4Addr,
    int? ipv4Cidr,
    List<String>? routes,
  }) {
    this.state = VpnStatus(
      state: state ?? this.state.state,
      ipv4Addr: ipv4Addr ?? this.state.ipv4Addr,
      ipv4Cidr: ipv4Cidr ?? this.state.ipv4Cidr,
      routes: routes ?? this.state.routes,
    );
  }
}

final vpnStatusProvider =
    StateNotifierProvider<VpnStatusNotifier, VpnStatus>((ref) {
  return VpnStatusNotifier();
});

// 网卡越点配置相关
class NetworkOverlapNotifier extends StateNotifier<Map<String, dynamic>> {
  final AppConfig _config;

  NetworkOverlapNotifier(this._config)
      : super({
          'enabled': _config.networkOverlapEnabled,
          'value': _config.networkOverlapValue,
        });

  void setEnabled(bool value) {
    _config.setNetworkOverlapEnabled(value);
    state = {...state, 'enabled': value};
  }

  void setValue(int value) {
    _config.setNetworkOverlapValue(value);
    state = {...state, 'value': value};
  }
}

final networkOverlapProvider =
    StateNotifierProvider<NetworkOverlapNotifier, Map<String, dynamic>>((ref) {
  return NetworkOverlapNotifier(ref.watch(appConfigProvider));
});

// 为enabled和value创建单独的Provider以方便使用
final networkOverlapEnabledProvider = Provider<bool>((ref) {
  return ref.watch(networkOverlapProvider)['enabled'] ?? false;
});

final networkOverlapValueProvider = Provider<int>((ref) {
  return ref.watch(networkOverlapProvider)['value'] ?? 0;
});
