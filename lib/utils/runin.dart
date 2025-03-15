import 'package:json_annotation/json_annotation.dart';

part 'runin.g.dart';

@JsonSerializable()
class Ipv4Addr {
  final int addr;

  Ipv4Addr({required this.addr});

  factory Ipv4Addr.fromJson(Map<String, dynamic> json) =>
      _$Ipv4AddrFromJson(json);
  Map<String, dynamic> toJson() => _$Ipv4AddrToJson(this);
}

@JsonSerializable()
class Ipv4Inet {
  @JsonKey(name: 'address')
  final Ipv4Addr? address;
  @JsonKey(name: 'network_length')
  final int networkLength;

  Ipv4Inet({this.address, required this.networkLength});

  factory Ipv4Inet.fromJson(Map<String, dynamic> json) =>
      _$Ipv4InetFromJson(json);
  Map<String, dynamic> toJson() => _$Ipv4InetToJson(this);
}

@JsonSerializable()
class StunInfo {
  @JsonKey(name: 'udp_nat_type')
  final int udpNatType;
  @JsonKey(name: 'tcp_nat_type')
  final int tcpNatType;
  @JsonKey(name: 'last_update_time')
  final int lastUpdateTime;
  @JsonKey(name: 'public_ip')
  final List<String> publicIp;
  @JsonKey(name: 'min_port')
  final int minPort;
  @JsonKey(name: 'max_port')
  final int maxPort;

  StunInfo({
    required this.udpNatType,
    required this.tcpNatType,
    required this.lastUpdateTime,
    required this.publicIp,
    required this.minPort,
    required this.maxPort,
  });

  factory StunInfo.fromJson(Map<String, dynamic> json) =>
      _$StunInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StunInfoToJson(this);
}

@JsonSerializable()
class PeerFeatureFlag {
  @JsonKey(name: 'is_public_server')
  final bool isPublicServer;
  @JsonKey(name: 'avoid_relay_data')
  final bool avoidRelayData;
  @JsonKey(name: 'kcp_input')
  final bool kcpInput;
  @JsonKey(name: 'no_relay_kcp')
  final bool noRelayKcp;

  PeerFeatureFlag({
    required this.isPublicServer,
    required this.avoidRelayData,
    required this.kcpInput,
    required this.noRelayKcp,
  });

  factory PeerFeatureFlag.fromJson(Map<String, dynamic> json) =>
      _$PeerFeatureFlagFromJson(json);
  Map<String, dynamic> toJson() => _$PeerFeatureFlagToJson(this);
}

@JsonSerializable()
class Url {
  final String url;

  Url({required this.url});

  factory Url.fromJson(Map<String, dynamic> json) => _$UrlFromJson(json);
  Map<String, dynamic> toJson() => _$UrlToJson(this);
}

@JsonSerializable()
class Route {
  @JsonKey(name: 'peer_id')
  final int? peerId;
  @JsonKey(name: 'ipv4_addr')
  final Ipv4Inet? ipv4Addr;
  @JsonKey(name: 'next_hop_peer_id')
  final int? nextHopPeerId;
  final int? cost;
  @JsonKey(name: 'path_latency')
  final int? pathLatency;
  @JsonKey(name: 'proxy_cidrs')
  final List<String>? proxyCidrs;
  final String? hostname;
  @JsonKey(name: 'stun_info')
  final StunInfo? stunInfo;
  @JsonKey(name: 'inst_id')
  final String? instId;
  final String? version;
  @JsonKey(name: 'feature_flag')
  final PeerFeatureFlag? featureFlag;
  @JsonKey(name: 'next_hop_peer_id_latency_first')
  final int? nextHopPeerIdLatencyFirst;
  @JsonKey(name: 'cost_latency_first')
  final int? costLatencyFirst;
  @JsonKey(name: 'path_latency_latency_first')
  final int? pathLatencyLatencyFirst;

  Route({
    this.peerId,
    this.ipv4Addr,
    this.nextHopPeerId,
    this.cost,
    this.pathLatency,
    this.proxyCidrs,
    this.hostname,
    this.stunInfo,
    this.instId,
    this.version,
    this.featureFlag,
    this.nextHopPeerIdLatencyFirst,
    this.costLatencyFirst,
    this.pathLatencyLatencyFirst,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

@JsonSerializable()
class TunnelInfo {
  @JsonKey(name: 'tunnel_type')
  final String tunnelType;
  @JsonKey(name: 'local_addr')
  final Url? localAddr;
  @JsonKey(name: 'remote_addr')
  final Url? remoteAddr;

  TunnelInfo({
    required this.tunnelType,
    this.localAddr,
    this.remoteAddr,
  });

  factory TunnelInfo.fromJson(Map<String, dynamic> json) =>
      _$TunnelInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TunnelInfoToJson(this);
}

@JsonSerializable()
class PeerConnStats {
  @JsonKey(name: 'rx_bytes')
  final int rxBytes;
  @JsonKey(name: 'tx_bytes')
  final int txBytes;
  @JsonKey(name: 'rx_packets')
  final int rxPackets;
  @JsonKey(name: 'tx_packets')
  final int txPackets;
  @JsonKey(name: 'latency_us')
  final int latencyUs;

  PeerConnStats({
    required this.rxBytes,
    required this.txBytes,
    required this.rxPackets,
    required this.txPackets,
    required this.latencyUs,
  });

  factory PeerConnStats.fromJson(Map<String, dynamic> json) =>
      _$PeerConnStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PeerConnStatsToJson(this);
}

@JsonSerializable()
class PeerConnInfo {
  @JsonKey(name: 'conn_id')
  final String connId;
  @JsonKey(name: 'my_peer_id')
  final int myPeerId;
  @JsonKey(name: 'peer_id')
  final int peerId;
  final List<String> features;
  final TunnelInfo? tunnel;
  final PeerConnStats? stats;
  @JsonKey(name: 'loss_rate')
  final double lossRate;
  @JsonKey(name: 'is_client')
  final bool isClient;
  @JsonKey(name: 'network_name')
  final String networkName;

  PeerConnInfo({
    required this.connId,
    required this.myPeerId,
    required this.peerId,
    required this.features,
    this.tunnel,
    this.stats,
    required this.lossRate,
    required this.isClient,
    required this.networkName,
  });

  factory PeerConnInfo.fromJson(Map<String, dynamic> json) =>
      _$PeerConnInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PeerConnInfoToJson(this);
}

@JsonSerializable()
class PeerInfo {
  @JsonKey(name: 'peer_id')
  final int peerId;
  final List<PeerConnInfo> conns;

  PeerInfo({
    required this.peerId,
    required this.conns,
  });

  factory PeerInfo.fromJson(Map<String, dynamic> json) =>
      _$PeerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PeerInfoToJson(this);
}

@JsonSerializable()
class PeerRoutePair {
  final Route? route;
  final PeerInfo? peer;

  PeerRoutePair({
    this.route,
    this.peer,
  });

  factory PeerRoutePair.fromJson(Map<String, dynamic> json) =>
      _$PeerRoutePairFromJson(json);
  Map<String, dynamic> toJson() => _$PeerRoutePairToJson(this);
}

@JsonSerializable()
class Ipv6Addr {
  @JsonKey(name: 'part1')
  final int part1;
  @JsonKey(name: 'part2')
  final int part2;
  @JsonKey(name: 'part3')
  final int part3;
  @JsonKey(name: 'part4')
  final int part4;

  Ipv6Addr({
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
  });

  factory Ipv6Addr.fromJson(Map<String, dynamic> json) =>
      _$Ipv6AddrFromJson(json);
  Map<String, dynamic> toJson() => _$Ipv6AddrToJson(this);
}

@JsonSerializable()
class GetIpListResponse {
  @JsonKey(name: 'public_ipv4')
  final Ipv4Addr? publicIpv4;
  @JsonKey(name: 'interface_ipv4s')
  final List<Ipv4Addr> interfaceIpv4s;
  @JsonKey(name: 'public_ipv6')
  final Ipv6Addr? publicIpv6;
  @JsonKey(name: 'interface_ipv6s')
  final List<Ipv6Addr> interfaceIpv6s;
  final List<Url> listeners;

  GetIpListResponse({
    this.publicIpv4,
    required this.interfaceIpv4s,
    this.publicIpv6,
    required this.interfaceIpv6s,
    required this.listeners,
  });

  factory GetIpListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetIpListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetIpListResponseToJson(this);
}

@JsonSerializable()
class MyNodeInfo {
  @JsonKey(name: 'virtual_ipv4')
  final Ipv4Inet? virtualIpv4;
  final String hostname;
  final String version;
  final GetIpListResponse? ips;
  @JsonKey(name: 'stun_info')
  final StunInfo? stunInfo;
  final List<Url> listeners;
  @JsonKey(name: 'vpn_portal_cfg')
  final String? vpnPortalCfg;

  MyNodeInfo({
    this.virtualIpv4,
    required this.hostname,
    required this.version,
    this.ips,
    this.stunInfo,
    required this.listeners,
    this.vpnPortalCfg,
  });

  factory MyNodeInfo.fromJson(Map<String, dynamic> json) =>
      _$MyNodeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MyNodeInfoToJson(this);
}

@JsonSerializable()
class Runin {
  @JsonKey(name: 'dev_name')
  final String? devName;
  @JsonKey(name: 'my_node_info')
  final MyNodeInfo? myNodeInfo;
  final List<String> events;
  final List<Route> routes;
  final List<PeerInfo>? peers;
  @JsonKey(name: 'peer_route_pairs')
  final List<PeerRoutePair>? peerRoutePairs;
  final bool running;
  @JsonKey(name: 'error_msg')
  final String? errorMsg;

  Runin({
    this.devName,
    this.myNodeInfo,
    required this.events,
    required this.routes,
    this.peers,
    this.peerRoutePairs,
    required this.running,
    this.errorMsg,
  });

  factory Runin.fromJson(Map<String, dynamic> json) => _$RuninFromJson(json);
  Map<String, dynamic> toJson() => _$RuninToJson(this);
}
