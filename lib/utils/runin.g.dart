// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ipv4Addr _$Ipv4AddrFromJson(Map<String, dynamic> json) => Ipv4Addr(
      addr: (json['addr'] as num).toInt(),
    );

Map<String, dynamic> _$Ipv4AddrToJson(Ipv4Addr instance) => <String, dynamic>{
      'addr': instance.addr,
    };

Ipv4Inet _$Ipv4InetFromJson(Map<String, dynamic> json) => Ipv4Inet(
      address: json['address'] == null
          ? null
          : Ipv4Addr.fromJson(json['address'] as Map<String, dynamic>),
      networkLength: (json['network_length'] as num).toInt(),
    );

Map<String, dynamic> _$Ipv4InetToJson(Ipv4Inet instance) => <String, dynamic>{
      'address': instance.address,
      'network_length': instance.networkLength,
    };

StunInfo _$StunInfoFromJson(Map<String, dynamic> json) => StunInfo(
      udpNatType: (json['udp_nat_type'] as num).toInt(),
      tcpNatType: (json['tcp_nat_type'] as num).toInt(),
      lastUpdateTime: (json['last_update_time'] as num).toInt(),
      publicIp:
          (json['public_ip'] as List<dynamic>).map((e) => e as String).toList(),
      minPort: (json['min_port'] as num).toInt(),
      maxPort: (json['max_port'] as num).toInt(),
    );

Map<String, dynamic> _$StunInfoToJson(StunInfo instance) => <String, dynamic>{
      'udp_nat_type': instance.udpNatType,
      'tcp_nat_type': instance.tcpNatType,
      'last_update_time': instance.lastUpdateTime,
      'public_ip': instance.publicIp,
      'min_port': instance.minPort,
      'max_port': instance.maxPort,
    };

PeerFeatureFlag _$PeerFeatureFlagFromJson(Map<String, dynamic> json) =>
    PeerFeatureFlag(
      isPublicServer: json['is_public_server'] as bool,
      avoidRelayData: json['avoid_relay_data'] as bool,
      kcpInput: json['kcp_input'] as bool,
      noRelayKcp: json['no_relay_kcp'] as bool,
    );

Map<String, dynamic> _$PeerFeatureFlagToJson(PeerFeatureFlag instance) =>
    <String, dynamic>{
      'is_public_server': instance.isPublicServer,
      'avoid_relay_data': instance.avoidRelayData,
      'kcp_input': instance.kcpInput,
      'no_relay_kcp': instance.noRelayKcp,
    };

Url _$UrlFromJson(Map<String, dynamic> json) => Url(
      url: json['url'] as String,
    );

Map<String, dynamic> _$UrlToJson(Url instance) => <String, dynamic>{
      'url': instance.url,
    };

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      peerId: (json['peer_id'] as num?)?.toInt(),
      ipv4Addr: json['ipv4_addr'] == null
          ? null
          : Ipv4Inet.fromJson(json['ipv4_addr'] as Map<String, dynamic>),
      nextHopPeerId: (json['next_hop_peer_id'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toInt(),
      pathLatency: (json['path_latency'] as num?)?.toInt(),
      proxyCidrs: (json['proxy_cidrs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      hostname: json['hostname'] as String?,
      stunInfo: json['stun_info'] == null
          ? null
          : StunInfo.fromJson(json['stun_info'] as Map<String, dynamic>),
      instId: json['inst_id'] as String?,
      version: json['version'] as String?,
      featureFlag: json['feature_flag'] == null
          ? null
          : PeerFeatureFlag.fromJson(
              json['feature_flag'] as Map<String, dynamic>),
      nextHopPeerIdLatencyFirst:
          (json['next_hop_peer_id_latency_first'] as num?)?.toInt(),
      costLatencyFirst: (json['cost_latency_first'] as num?)?.toInt(),
      pathLatencyLatencyFirst:
          (json['path_latency_latency_first'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'peer_id': instance.peerId,
      'ipv4_addr': instance.ipv4Addr,
      'next_hop_peer_id': instance.nextHopPeerId,
      'cost': instance.cost,
      'path_latency': instance.pathLatency,
      'proxy_cidrs': instance.proxyCidrs,
      'hostname': instance.hostname,
      'stun_info': instance.stunInfo,
      'inst_id': instance.instId,
      'version': instance.version,
      'feature_flag': instance.featureFlag,
      'next_hop_peer_id_latency_first': instance.nextHopPeerIdLatencyFirst,
      'cost_latency_first': instance.costLatencyFirst,
      'path_latency_latency_first': instance.pathLatencyLatencyFirst,
    };

TunnelInfo _$TunnelInfoFromJson(Map<String, dynamic> json) => TunnelInfo(
      tunnelType: json['tunnel_type'] as String,
      localAddr: json['local_addr'] == null
          ? null
          : Url.fromJson(json['local_addr'] as Map<String, dynamic>),
      remoteAddr: json['remote_addr'] == null
          ? null
          : Url.fromJson(json['remote_addr'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TunnelInfoToJson(TunnelInfo instance) =>
    <String, dynamic>{
      'tunnel_type': instance.tunnelType,
      'local_addr': instance.localAddr,
      'remote_addr': instance.remoteAddr,
    };

PeerConnStats _$PeerConnStatsFromJson(Map<String, dynamic> json) =>
    PeerConnStats(
      rxBytes: (json['rx_bytes'] as num).toInt(),
      txBytes: (json['tx_bytes'] as num).toInt(),
      rxPackets: (json['rx_packets'] as num).toInt(),
      txPackets: (json['tx_packets'] as num).toInt(),
      latencyUs: (json['latency_us'] as num).toInt(),
    );

Map<String, dynamic> _$PeerConnStatsToJson(PeerConnStats instance) =>
    <String, dynamic>{
      'rx_bytes': instance.rxBytes,
      'tx_bytes': instance.txBytes,
      'rx_packets': instance.rxPackets,
      'tx_packets': instance.txPackets,
      'latency_us': instance.latencyUs,
    };

PeerConnInfo _$PeerConnInfoFromJson(Map<String, dynamic> json) => PeerConnInfo(
      connId: json['conn_id'] as String,
      myPeerId: (json['my_peer_id'] as num).toInt(),
      peerId: (json['peer_id'] as num).toInt(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      tunnel: json['tunnel'] == null
          ? null
          : TunnelInfo.fromJson(json['tunnel'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : PeerConnStats.fromJson(json['stats'] as Map<String, dynamic>),
      lossRate: (json['loss_rate'] as num).toDouble(),
      isClient: json['is_client'] as bool,
      networkName: json['network_name'] as String,
    );

Map<String, dynamic> _$PeerConnInfoToJson(PeerConnInfo instance) =>
    <String, dynamic>{
      'conn_id': instance.connId,
      'my_peer_id': instance.myPeerId,
      'peer_id': instance.peerId,
      'features': instance.features,
      'tunnel': instance.tunnel,
      'stats': instance.stats,
      'loss_rate': instance.lossRate,
      'is_client': instance.isClient,
      'network_name': instance.networkName,
    };

PeerInfo _$PeerInfoFromJson(Map<String, dynamic> json) => PeerInfo(
      peerId: (json['peer_id'] as num).toInt(),
      conns: (json['conns'] as List<dynamic>)
          .map((e) => PeerConnInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PeerInfoToJson(PeerInfo instance) => <String, dynamic>{
      'peer_id': instance.peerId,
      'conns': instance.conns,
    };

PeerRoutePair _$PeerRoutePairFromJson(Map<String, dynamic> json) =>
    PeerRoutePair(
      route: json['route'] == null
          ? null
          : Route.fromJson(json['route'] as Map<String, dynamic>),
      peer: json['peer'] == null
          ? null
          : PeerInfo.fromJson(json['peer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PeerRoutePairToJson(PeerRoutePair instance) =>
    <String, dynamic>{
      'route': instance.route,
      'peer': instance.peer,
    };

Ipv6Addr _$Ipv6AddrFromJson(Map<String, dynamic> json) => Ipv6Addr(
      part1: (json['part1'] as num).toInt(),
      part2: (json['part2'] as num).toInt(),
      part3: (json['part3'] as num).toInt(),
      part4: (json['part4'] as num).toInt(),
    );

Map<String, dynamic> _$Ipv6AddrToJson(Ipv6Addr instance) => <String, dynamic>{
      'part1': instance.part1,
      'part2': instance.part2,
      'part3': instance.part3,
      'part4': instance.part4,
    };

GetIpListResponse _$GetIpListResponseFromJson(Map<String, dynamic> json) =>
    GetIpListResponse(
      publicIpv4: json['public_ipv4'] == null
          ? null
          : Ipv4Addr.fromJson(json['public_ipv4'] as Map<String, dynamic>),
      interfaceIpv4s: (json['interface_ipv4s'] as List<dynamic>)
          .map((e) => Ipv4Addr.fromJson(e as Map<String, dynamic>))
          .toList(),
      publicIpv6: json['public_ipv6'] == null
          ? null
          : Ipv6Addr.fromJson(json['public_ipv6'] as Map<String, dynamic>),
      interfaceIpv6s: (json['interface_ipv6s'] as List<dynamic>)
          .map((e) => Ipv6Addr.fromJson(e as Map<String, dynamic>))
          .toList(),
      listeners: (json['listeners'] as List<dynamic>)
          .map((e) => Url.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetIpListResponseToJson(GetIpListResponse instance) =>
    <String, dynamic>{
      'public_ipv4': instance.publicIpv4,
      'interface_ipv4s': instance.interfaceIpv4s,
      'public_ipv6': instance.publicIpv6,
      'interface_ipv6s': instance.interfaceIpv6s,
      'listeners': instance.listeners,
    };

MyNodeInfo _$MyNodeInfoFromJson(Map<String, dynamic> json) => MyNodeInfo(
      virtualIpv4: json['virtual_ipv4'] == null
          ? null
          : Ipv4Inet.fromJson(json['virtual_ipv4'] as Map<String, dynamic>),
      hostname: json['hostname'] as String,
      version: json['version'] as String,
      ips: json['ips'] == null
          ? null
          : GetIpListResponse.fromJson(json['ips'] as Map<String, dynamic>),
      stunInfo: json['stun_info'] == null
          ? null
          : StunInfo.fromJson(json['stun_info'] as Map<String, dynamic>),
      listeners: (json['listeners'] as List<dynamic>)
          .map((e) => Url.fromJson(e as Map<String, dynamic>))
          .toList(),
      vpnPortalCfg: json['vpn_portal_cfg'] as String?,
    );

Map<String, dynamic> _$MyNodeInfoToJson(MyNodeInfo instance) =>
    <String, dynamic>{
      'virtual_ipv4': instance.virtualIpv4,
      'hostname': instance.hostname,
      'version': instance.version,
      'ips': instance.ips,
      'stun_info': instance.stunInfo,
      'listeners': instance.listeners,
      'vpn_portal_cfg': instance.vpnPortalCfg,
    };

Runin _$RuninFromJson(Map<String, dynamic> json) => Runin(
      devName: json['dev_name'] as String?,
      myNodeInfo: json['my_node_info'] == null
          ? null
          : MyNodeInfo.fromJson(json['my_node_info'] as Map<String, dynamic>),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      routes: (json['routes'] as List<dynamic>)
          .map((e) => Route.fromJson(e as Map<String, dynamic>))
          .toList(),
      peers: (json['peers'] as List<dynamic>?)
          ?.map((e) => PeerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      peerRoutePairs: (json['peer_route_pairs'] as List<dynamic>?)
          ?.map((e) => PeerRoutePair.fromJson(e as Map<String, dynamic>))
          .toList(),
      running: json['running'] as bool,
      errorMsg: json['error_msg'] as String?,
    );

Map<String, dynamic> _$RuninToJson(Runin instance) => <String, dynamic>{
      'dev_name': instance.devName,
      'my_node_info': instance.myNodeInfo,
      'events': instance.events,
      'routes': instance.routes,
      'peers': instance.peers,
      'peer_route_pairs': instance.peerRoutePairs,
      'running': instance.running,
      'error_msg': instance.errorMsg,
    };
