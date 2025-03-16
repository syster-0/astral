// 导入必要的包
import 'dart:convert';

import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/utils/kv_state.dart';
import 'package:astral/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../widgets/card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/runin.dart';

enum ConnectionState { notStarted, connecting, connected }

Runin parseRunin(String jsonString) {
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  return Runin.fromJson(jsonMap);
}

// 辅助方法：将整数形式的IP转换为字符串
String _intToIpv4String(int addr) {
  return [
    (addr >> 24) & 0xFF,
    (addr >> 16) & 0xFF,
    (addr >> 8) & 0xFF,
    addr & 0xFF,
  ].join('.');
}

/// 首页组件
/// 用于显示应用的主页面，包含主题切换和问候功能
class HomePage extends StatefulWidget {
  // 主题模式切换回调函数
  final Function toggleThemeMode;
  // 主题色更改回调函数
  final Function(Color) changeSeedColor;
  // 当前主题模式
  final ThemeMode currentThemeMode;

  /// 构造函数
  const HomePage({
    super.key,
    required this.toggleThemeMode,
    required this.changeSeedColor,
    required this.currentThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 定义状态枚举

  // 当前连接状态
  ConnectionState _connectionState = ConnectionState.notStarted;

  bool isRunning = false; // 只用于控制启动/暂停状态
  Duration runningTime = Duration.zero;
  Timer? timer;

  // 模拟数据
  double uploadSpeed = 0; // MB/s
  double downloadSpeed = 0; // MB/s
  String publicIP = "";
  // 房间名
  String roomName = "";
  // 房间密码
  String roomPassword = "";
  // 用户名
  String username = "";

  bool _isAutoIP = true; // 只用于控制IP自动/手动模式

  String Serverip = "";
  int _uploadBytes = 0;
  int _downloadBytes = 0;
  int _lastUploadBytes = 0;
  int _lastDownloadBytes = 0;
  // 定义卡片列表
  late final List<Widget Function(ColorScheme)> _cardBuilders;

  // 添加 TextEditingController
  late final TextEditingController _roomNameController;
  late final TextEditingController _roomPasswordController;
  late final TextEditingController _usernameController;
  late final TextEditingController _virtualIPController;

  @override
  void initState() {
    super.initState();
    // 初始化所有TextEditingController
    _roomNameController = TextEditingController(text: roomName);
    _roomPasswordController = TextEditingController(text: roomPassword);
    _usernameController = TextEditingController(text: username);
    _virtualIPController = TextEditingController(text: publicIP); // 添加缺失的初始化

    // 修改卡片构建器列表，添加版本信息卡片
    _cardBuilders = [
      _buildNetworkStatusCard,
      _buildUserInfoCard,
      _buildRoomInfoCard,
      _buildVersionInfoCard,
    ];
  }

  void toggleRunning() {
    final km = Provider.of<KM>(context, listen: false);
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        // 切换到连接中状态
        _connectionState = ConnectionState.connecting;
        createServer(
            username: username,
            enableDhcp: _isAutoIP,
            specifiedIp: publicIP,
            roomName: roomName,
            roomPassword: roomPassword,
            severurl: Serverip);
        // 添加连接超时计数器
        int connectionTimeoutCounter = 0;

        // 不再使用固定延迟模拟连接成功，而是通过定时检查IP来确定连接状态
        timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          // 检查组件是否仍然挂载
          if (!mounted) {
            timer.cancel();
            return;
          }

          final info = await getRunningInfo();
          Runin runin = parseRunin(info);

          // 获取网络状态
          final networkStatus = await getNetworkStatus();
          final km = Provider.of<KM>(context, listen: false);
          km.nodes = networkStatus.nodes;

          // 更新网络流量数据
          _updateNetworkStats(networkStatus.nodes);

          final int? version = runin.myNodeInfo?.virtualIpv4?.address?.addr;
          if (version != null) {
            String ipStr = _intToIpv4String(version);
            // 检查IP不为0.0.0.0时认为连接成功
            if (ipStr != "0.0.0.0") {
              if (publicIP != ipStr) {
                km.virtualIP = ipStr;
              }

              // 如果当前状态还是连接中，则更新为已连接
              if (_connectionState == ConnectionState.connecting) {
                setState(() {
                  _connectionState = ConnectionState.connected;
                });
              }

              // 重置超时计数器
              connectionTimeoutCounter = 0;
            } else if (_connectionState == ConnectionState.connecting) {
              // 只在连接状态下增加超时计数
              connectionTimeoutCounter++;

              // 如果连续10秒都是0.0.0.0，判断为连接失败
              if (connectionTimeoutCounter >= 10) {
                // 停止连接并显示失败消息
                timer.cancel();
                setState(() {
                  isRunning = false;
                  _connectionState = ConnectionState.notStarted;
                  runningTime = Duration.zero;
                });

                // 关闭服务器连接
                closeAllServer();

                // 显示连接失败提示
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('连接失败，请检查网络或房间信息后重试'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                return;
              }
            }
          }

          // 再次检查组件是否仍然挂载
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            runningTime += const Duration(seconds: 1);
          });
        });
        // 移除原来的Future.delayed模拟连接成功的代码
      } else {
        // 停止时重置状态
        _connectionState = ConnectionState.notStarted;
        closeAllServer();
        timer?.cancel();
        runningTime = Duration.zero;
        // 重置网络统计数据
        _uploadBytes = 0;
        _downloadBytes = 0;
        _lastUploadBytes = 0;
        _lastDownloadBytes = 0;
        uploadSpeed = 0;
        downloadSpeed = 0;
      }
    });
  }

  // 添加网络统计数据更新方法
  void _updateNetworkStats(dynamic nodes) {
    if (nodes == null || nodes.isEmpty) return;

    int totalUploadBytes = 0;
    int totalDownloadBytes = 0;
    String myIP = Provider.of<KM>(context, listen: false).virtualIP;

    // 查找本机节点
    for (var node in nodes) {
      if (node.ipv4 == myIP) {
        // 找到本机节点，计算上传下载总量
        if (node.connections != null && node.connections.isNotEmpty) {
          for (var conn in node.connections) {
            totalUploadBytes += (conn.txBytes as BigInt).toInt();
            totalDownloadBytes += (conn.rxBytes as BigInt).toInt();
          }
        }
        break;
      }
    }

    // 再次检查挂载状态，确保在setState前组件仍然挂载
    if (!mounted) return;

    // 计算速度 (字节/秒 转换为 MB/秒)
    setState(() {
      _uploadBytes = totalUploadBytes;
      _downloadBytes = totalDownloadBytes;

      // 计算速度差值
      if (_lastUploadBytes > 0) {
        uploadSpeed =
            (_uploadBytes - _lastUploadBytes) / (1024 * 1024); // 转换为MB/s
        uploadSpeed = double.parse(uploadSpeed.toStringAsFixed(2)); // 保留两位小数
      }

      if (_lastDownloadBytes > 0) {
        downloadSpeed =
            (_downloadBytes - _lastDownloadBytes) / (1024 * 1024); // 转换为MB/s
        downloadSpeed =
            double.parse(downloadSpeed.toStringAsFixed(2)); // 保留两位小数
      }

      // 更新上次的值
      _lastUploadBytes = _uploadBytes;
      _lastDownloadBytes = _downloadBytes;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final km = Provider.of<KM>(context);
    _roomNameController.value = TextEditingValue(
      text: km.roomName,
      selection: _roomNameController.selection,
    );
    _roomPasswordController.value = TextEditingValue(
      text: km.roomPassword,
      selection: _roomPasswordController.selection,
    );
    _usernameController.value = TextEditingValue(
      text: km.username,
      selection: _usernameController.selection,
    );
    // 添加虚拟IP控制器的值同步
    _virtualIPController.value = TextEditingValue(
      text: km.virtualIP,
      selection: _virtualIPController.selection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    publicIP = Provider.of<KM>(context).virtualIP;
    _isAutoIP = Provider.of<KM>(context).dynamicIP; // 更新自动IP状态
    //我的房间
    roomName = Provider.of<KM>(context).roomName;
    //我的密码
    roomPassword = Provider.of<KM>(context).roomPassword;
    //我的用户名
    username = Provider.of<KM>(context).username;
    Serverip = Provider.of<KM>(context).serverIP;

    // 使用 LayoutBuilder 来处理布局变化，同时保留状态
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        // 根据约束计算列数
        final columnCount = _getColumnCount(constraints.maxWidth);

        return CustomScrollView(
          // 添加这个属性来控制滚动行为
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 替换原有的 SliverList 为 SliverPadding + SliverGrid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: columnCount, // 使用计算出的列数
                mainAxisSpacing: 16, // 主轴间距
                crossAxisSpacing: 16, // 交叉轴间距
                childCount: _cardBuilders.length,
                itemBuilder: (context, index) {
                  // 直接从列表中获取构建函数并调用
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: _cardBuilders[index](colorScheme),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: _connectionState != ConnectionState.notStarted ? 180 : 100,
        height: 60,
        child: FloatingActionButton.extended(
          onPressed: _connectionState == ConnectionState.connecting
              ? null
              : toggleRunning,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 2),
          splashColor: _connectionState != ConnectionState.notStarted
              ? colorScheme.onTertiary.withOpacity(0.2)
              : colorScheme.onPrimary.withOpacity(0.2),
          highlightElevation: 6,
          elevation: 2,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _getButtonIcon(_connectionState),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 0),
            switchInCurve: Curves.easeOutQuad,
            switchOutCurve: Curves.easeInQuad,
            child: _getButtonLabel(_connectionState),
          ),
          backgroundColor: _getButtonColor(_connectionState, colorScheme),
          foregroundColor:
              _getButtonForegroundColor(_connectionState, colorScheme),
        ),
      ),
    );
  }

  // 修改为接受宽度参数，而不是使用 MediaQuery
  int _getColumnCount(double width) {
    if (width < 600) {
      return 1; // 手机屏幕显示1列
    } else if (width < 900) {
      return 2; // 平板或小屏幕显示2列
    } else {
      return 3; // 大屏幕显示3列
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

// 根据连接状态获取按钮图标
  Widget _getButtonIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.notStarted:
        return const Icon(
          Icons.play_arrow,
          key: ValueKey('play'),
          size: 34,
        );
      case ConnectionState.connecting:
        return SizedBox(
          key: const ValueKey('connecting'),
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onTertiary),
          ),
        );
      case ConnectionState.connected:
        return const Icon(
          Icons.pause,
          key: ValueKey('pause'),
          size: 34,
        );
    }
  }

  // 根据连接状态获取按钮文本
  Widget _getButtonLabel(ConnectionState state) {
    switch (state) {
      case ConnectionState.notStarted:
        return const Text(
          '启动',
          key: ValueKey('start_text'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        );
      case ConnectionState.connecting:
        return const Text(
          '连接中...',
          key: ValueKey('connecting_text'),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case ConnectionState.connected:
        return Text(
          _formatDuration(runningTime),
          key: const ValueKey('running_text'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }

  // 根据连接状态获取按钮背景色
  Color _getButtonColor(ConnectionState state, ColorScheme colorScheme) {
    switch (state) {
      case ConnectionState.notStarted:
        return colorScheme.primary;
      case ConnectionState.connecting:
        return colorScheme.tertiary.withOpacity(0.7);
      case ConnectionState.connected:
        return colorScheme.tertiary;
    }
  }

  // 根据连接状态获取按钮前景色
  Color _getButtonForegroundColor(
      ConnectionState state, ColorScheme colorScheme) {
    switch (state) {
      case ConnectionState.notStarted:
        return colorScheme.onPrimary;
      case ConnectionState.connecting:
      case ConnectionState.connected:
        return colorScheme.onTertiary;
    }
  }

  // 修改卡片构建方法，移除多余的内边距
  Widget _buildDashboardCard(ColorScheme colorScheme) {
    return FloatingCard(
        colorScheme: colorScheme,
        maxWidth: 600, // 设置最大宽度
        height: 200,
        child: SizedBox(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: uploadSpeed,
                  title: '上传',
                  color: colorScheme.primary,
                ),
                PieChartSectionData(
                  value: downloadSpeed,
                  title: '下载',
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ));
  }

  // 修改流量统计卡片，移除多余的内边距
  Widget _buildTrafficCard(ColorScheme colorScheme) {
    return FloatingCard(
        colorScheme: colorScheme,
        maxWidth: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 修改标题为图标+文字组合
            Row(
              children: [
                Icon(Icons.data_usage, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                const Text('流量统计',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrafficInfo('上传速度', '$uploadSpeed MB/s', Icons.upload,
                    colorScheme.primary),
                _buildTrafficInfo('下载速度', '$downloadSpeed MB/s', Icons.download,
                    colorScheme.secondary),
              ],
            ),
          ],
        ));
  }

  // 修改IP地址卡片，移除多余的内边距
  Widget _buildIPCard(ColorScheme colorScheme) {
    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 修改标题为图标+文字组合
          Row(
            children: [
              Icon(Icons.wifi, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('网络信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildIPInfo('虚拟 IP', publicIP, Icons.public, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTrafficInfo(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(label),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildIPInfo(
      String label, String value, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: colorScheme.secondary)),
      ],
    );
  }

  // 新增合并后的网络状态卡片（合并了流量统计和IP信息）
  Widget _buildNetworkStatusCard(ColorScheme colorScheme) {
    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏带有连接状态指示器
          Row(
            children: [
              Icon(Icons.network_check, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('网络状态',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              // 添加状态指示器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(_connectionState, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(_connectionState),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // IP信息部分
          _buildIPInfo('虚拟 IP', publicIP, Icons.public, colorScheme),
          const SizedBox(height: 12),

          // 流量统计部分
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.data_usage, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text('流量统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrafficInfo('上传速度', '$uploadSpeed MB/s', Icons.upload,
                  colorScheme.primary),
              _buildTrafficInfo('下载速度', '$downloadSpeed MB/s', Icons.download,
                  colorScheme.secondary),
            ],
          ),

          // 添加运行时间显示
          if (_connectionState == ConnectionState.connected) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '运行时间: ${_formatDuration(runningTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 获取状态文本
  String _getStatusText(ConnectionState state) {
    switch (state) {
      case ConnectionState.notStarted:
        return '未连接';
      case ConnectionState.connecting:
        return '连接中';
      case ConnectionState.connected:
        return '已连接';
    }
  }

  // 获取状态颜色
  Color _getStatusColor(ConnectionState state, ColorScheme colorScheme) {
    switch (state) {
      case ConnectionState.notStarted:
        return Colors.grey;
      case ConnectionState.connecting:
        return Colors.orange;
      case ConnectionState.connected:
        return Colors.green;
    }
  }

  // 优化用户信息卡片
  Widget _buildUserInfoCard(ColorScheme colorScheme) {
    final km = Provider.of<KM>(context, listen: false);
    final isValidIP = _isAutoIP || _isValidIPv4(km.virtualIP);

    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(Icons.person, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('用户信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              // 添加编辑状态指示器
              if (_connectionState == ConnectionState.connected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '已锁定',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 用户名输入框
          TextField(
            controller: _usernameController,
            enabled: _connectionState != ConnectionState.connected,
            onEditingComplete: () {
              // 改为完成编辑时更新
              Provider.of<KM>(context, listen: false).username =
                  _usernameController.text;
            },
            decoration: InputDecoration(
              labelText: '用户名',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.person, color: colorScheme.primary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),

          // IP设置部分
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _virtualIPController,
                  enabled: !_isAutoIP &&
                      _connectionState != ConnectionState.connected,
                  onChanged: (value) {
                    // 保留空回调以避免实时更新
                  },
                  onEditingComplete: () {
                    // 添加完成编辑回调
                    if (!_isAutoIP) {
                      Provider.of<KM>(context, listen: false).virtualIP =
                          _virtualIPController.text;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '虚拟网IP',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lan, color: colorScheme.primary),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    errorText: !isValidIP && !_isAutoIP ? '请输入有效的IPv4地址' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Switch(
                    value: _isAutoIP,
                    onChanged: _connectionState != ConnectionState.connected
                        ? (value) {
                            setState(() {
                              _isAutoIP = value;
                            });
                            km.dynamicIP = value;
                            // 切换模式时同步最新值
                            if (!value) {
                              km.virtualIP = _virtualIPController.text;
                            }
                          }
                        : null,
                  ),
                  Text(
                    _isAutoIP ? "自动" : "手动",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (_isAutoIP)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '系统将自动分配虚拟网IP',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 优化房间信息卡片
  Widget _buildRoomInfoCard(ColorScheme colorScheme) {
    final km = Provider.of<KM>(context, listen: false);
    return FloatingCard(
      colorScheme: colorScheme,
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(Icons.meeting_room, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('房间信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              // 添加编辑状态指示器
              if (_connectionState == ConnectionState.connected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '已锁定',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 房间名称输入框
          TextField(
            controller: _roomNameController,
            enabled: _connectionState != ConnectionState.connected,
            onEditingComplete: () {
              // 改为完成编辑时更新
              Provider.of<KM>(context, listen: false).roomName =
                  _roomNameController.text;
            },
            decoration: InputDecoration(
              labelText: '房间名称',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.meeting_room, color: colorScheme.primary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),

          // 房间密码输入框
          TextField(
            controller: _roomPasswordController,
            enabled: _connectionState != ConnectionState.connected,
            onEditingComplete: () {
              // 改为完成编辑时更新
              Provider.of<KM>(context, listen: false).roomPassword =
                  _roomPasswordController.text;
            },
            obscureText: true,
            decoration: InputDecoration(
              labelText: '房间密码',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              // helperText: '留空表示无密码',
            ),
          ),
        ],
      ),
    );
  }

  // 添加IPv4地址验证方法
  bool _isValidIPv4(String ip) {
    if (ip.isEmpty) return false;

    // 使用正则表达式验证IPv4地址格式
    final ipv4Pattern = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

    return ipv4Pattern.hasMatch(ip);
  }
}

// 添加版本信息卡片
Widget _buildVersionInfoCard(ColorScheme colorScheme) {
  // 这里可以从配置或API获取实际版本号
  final String appVersion = AppInfoUtil.getVersion();

  return FloatingCard(
    colorScheme: colorScheme,
    maxWidth: 600,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text('版本信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),

        // 版本信息列表
        _buildVersionItem('软件版本', appVersion, Icons.apps, colorScheme),
        const SizedBox(height: 12),

        // 使用FutureBuilder处理异步获取的版本信息
        FutureBuilder<String>(
          future: easytierVersion(),
          builder: (context, snapshot) {
            String version = snapshot.hasData ? snapshot.data! : "加载中...";
            return _buildVersionItem(
                'ET内核版本', version, Icons.memory, colorScheme);
          },
        ),
      ],
    ),
  );
}

// 版本信息项构建方法
Widget _buildVersionItem(
    String label, String version, IconData icon, ColorScheme colorScheme) {
  return Row(
    children: [
      Icon(icon, size: 20, color: colorScheme.primary),
      const SizedBox(width: 12),
      Text('$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          )),
      const SizedBox(width: 8),
      Text(
        version,
        style: TextStyle(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
