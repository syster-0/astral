import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astral/model/config_model.dart';

class KV {
  final Map<String, dynamic> values;

  const KV({Map<String, dynamic>? initialValues})
      : values = initialValues ?? const {};

  T? getValue<T>(String key) => values[key] as T?;

  KV copyWith(String key, dynamic value) {
    return KV(
      initialValues: {...values, key: value},
    );
  }
}

final KP = StateNotifierProvider<K, KV>((ref) {
  return K();
});

class K extends StateNotifier<KV> {
  K()
      : super(const KV(initialValues: {
          'networkStatus': null,
        }));

  void setValue<T>(String key, T value) {
    state = state.copyWith(key, value);
  }

  T? getValue<T>(String key) => state.getValue<T>(key);
}

// 配置状态管理类
class KConfig extends StateNotifier<ConfigModel> {
  // 单例实例
  static final provider = StateNotifierProvider<KConfig, ConfigModel>((ref) {
    return KConfig._internal();
  });

  // 私有构造函数
  KConfig._internal() : super(ConfigModel());
  KConfig(super.state);

  void setConfig(Map<String, dynamic> updates) {
    state = ConfigModel(
      roompass: updates['roompass'] ?? state.roompass,
      roomname: updates['roomname'] ?? state.roomname,
      username: updates['Username'] ?? state.username,
      virtualIP: updates['virtualIP'] ?? state.virtualIP,
      enableOverlap: updates['overlap'] ?? state.enableOverlap,
      overlapValue: updates['overlapValue'] ?? state.overlapValue,
      closeToTray: updates['closeToTray'] ?? state.closeToTray,
      pingEnabled: updates['pingEnabled'] ?? state.pingEnabled,
      themeMode: updates['mode'] ?? state.themeMode,
      seedColor: updates['seedColor'] ?? state.seedColor,
      defaultProtocol: updates['defaultProtocol'] ?? state.defaultProtocol,
      devName: updates['devName'] ?? state.devName,
      enableEncryption: updates['enableEncryption'] ?? state.enableEncryption,
      enableIpv6: updates['enableIpv6'] ?? state.enableIpv6,
      mtu: updates['mtu'] ?? state.mtu,
      latencyFirst: updates['latencyFirst'] ?? state.latencyFirst,
      enableExitNode: updates['enableExitNode'] ?? state.enableExitNode,
      proxyForwardBySystem:
          updates['proxyForwardBySystem'] ?? state.proxyForwardBySystem,
      noTun: updates['noTun'] ?? state.noTun,
      useSmoltcp: updates['useSmoltcp'] ?? state.useSmoltcp,
      relayNetworkWhitelist:
          updates['relayNetworkWhitelist'] ?? state.relayNetworkWhitelist,
      disableP2p: updates['disableP2p'] ?? state.disableP2p,
      relayAllPeerRpc: updates['relayAllPeerRpc'] ?? state.relayAllPeerRpc,
      disableUdpHolePunching:
          updates['disableUdpHolePunching'] ?? state.disableUdpHolePunching,
      multiThread: updates['multiThread'] ?? state.multiThread,
      dataCompressAlgo: updates['dataCompressAlgo'] ?? state.dataCompressAlgo,
      bindDevice: updates['bindDevice'] ?? state.bindDevice,
      enableKcpProxy: updates['enableKcpProxy'] ?? state.enableKcpProxy,
      disableKcpInput: updates['disableKcpInput'] ?? state.disableKcpInput,
      disableRelayKcp: updates['disableRelayKcp'] ?? state.disableRelayKcp,
      servers: updates['servers'] ?? state.servers,
    );
  }

  void setRoompass(String roompass) {
    setConfig({'roompass': roompass});
  }

  void setRoomname(String roomname) {
    setConfig({'roomname': roomname});
  }

  void setUsername(String username) {
    setConfig({'username': username});
  }

  void setVirtualIP(String ip) {
    setConfig({'virtualIP': ip});
  }

  void setoverlap(bool enable) {
    setConfig({'overlap': enable});
  }

  void setoverlapValue(int value) {
    setConfig({'overlapValue': value});
  }

  void setCloseToTray(bool enable) {
    setConfig({'closeToTray': enable});
  }

  void setPingEnabled(bool enable) {
    setConfig({'pingEnabled': enable});
  }

  void setThemeMode(ThemeMode mode) {
    setConfig({'mode': mode});
  }

  void setSeedColor(Color color) {
    setConfig({'seedColor': color});
  }

  void setDefaultProtocol(String protocol) {
    setConfig({'defaultProtocol': protocol});
  }

  void setDevName(String name) {
    setConfig({'devName': name});
  }

  void setEnableEncryption(bool enable) {
    setConfig({'enableEncryption': enable});
  }

  void setEnableIpv6(bool enable) {
    setConfig({'enableIpv6': enable});
  }

  void setMtu(int value) {
    setConfig({'mtu': value});
  }

  void setLatencyFirst(bool enable) {
    setConfig({'latencyFirst': enable});
  }

  void setEnableExitNode(bool enable) {
    setConfig({'enableExitNode': enable});
  }

  void setProxyForwardBySystem(bool enable) {
    setConfig({'proxyForwardBySystem': enable});
  }

  void setNoTun(bool enable) {
    setConfig({'noTun': enable});
  }

  void setUseSmoltcp(bool enable) {
    setConfig({'useSmoltcp': enable});
  }

  void setRelayNetworkWhitelist(List<String> whitelist) {
    setConfig({'relayNetworkWhitelist': whitelist});
  }

  void setDisableP2p(bool disable) {
    setConfig({'disableP2p': disable});
  }

  void setRelayAllPeerRpc(bool enable) {
    setConfig({'relayAllPeerRpc': enable});
  }

  void setDisableUdpHolePunching(bool disable) {
    setConfig({'disableUdpHolePunching': disable});
  }

  void setMultiThread(bool enable) {
    setConfig({'multiThread': enable});
  }

  void setDataCompressAlgo(String algo) {
    setConfig({'dataCompressAlgo': algo});
  }

  void setBindDevice(String device) {
    setConfig({'bindDevice': device});
  }

  void setEnableKcpProxy(bool enable) {
    setConfig({'enableKcpProxy': enable});
  }

  void setDisableKcpInput(bool disable) {
    setConfig({'disableKcpInput': disable});
  }

  void setDisableRelayKcp(bool disable) {
    setConfig({'disableRelayKcp': disable});
  }

  // 添加单个服务器
  void addServer(ServerConfig server) {
    List<ServerConfig> currentServers = List.from(state.servers);
    if (!currentServers.contains(server)) {
      currentServers.add(server);
      setConfig({'servers': currentServers});
    }
  }

  // 移除单个服务器
  void removeServer(ServerConfig server) {
    List<ServerConfig> currentServers = List.from(state.servers);
    currentServers.remove(server);
    setConfig({'servers': currentServers});
  }

  // 修改单个服务器
  void updateServer(ServerConfig oldServer, ServerConfig newServer) {
    List<ServerConfig> currentServers = List.from(state.servers);
    int index = currentServers.indexOf(oldServer);
    if (index != -1) {
      currentServers[index] = newServer;
      setConfig({'servers': currentServers});
    }
  }

  // 传入 id设置服务器
  void setServerById(int id, ServerConfig server) {
    List<ServerConfig> currentServers = List.from(state.servers);
    if (id >= 0 && id < currentServers.length) {
      currentServers[id] = server;
      setConfig({'servers': currentServers});
    }
  }

  // 批量设置服务器列表
  void setServers(List<ServerConfig> serverList) {
    setConfig({'servers': serverList});
  }

  // 清空服务器列表
  void clearServers() {
    setConfig({'servers': []});
  }
}
