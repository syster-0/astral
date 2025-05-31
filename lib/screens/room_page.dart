import 'package:astral/fun/e_d_room.dart';
import 'package:astral/fun/show_add_room_dialog.dart';
import 'package:astral/fun/show_edit_room_dialog.dart';
import 'package:astral/fun/sorting_jump_dialog.dart';
import 'package:astral/screens/user_page.dart';
import 'package:astral/wid/room_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/k/app_s/aps.dart';


class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  // 使用 Aps 实例
  final _aps = Aps();
   bool isHovered = false;

  // 根据宽度计算列数
  int _getColumnCount(double width) {
    if (width >= 1200) {
      return 4;
    } else if (width >= 900) {
      return 3;
    } else if (width >= 600) {
      return 2;
    }
    return 1;
  }

  // 显示输入分享码的弹窗
  void _showPasteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String shareCode = '';
        return AlertDialog(
          title: const Text('输入分享码'),
          content: TextField(
            onChanged: (value) {
              shareCode = value;
            },
            decoration: const InputDecoration(hintText: '请输入分享码'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (shareCode.isNotEmpty) {
                  try {
                    // 解密并添加房间
                    var room = decryptRoomFromJWT(shareCode);
                    if (room != null) {
                      _aps.addRoom(room);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('房间已成功导入')));
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('分享码无效')));
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('分享码无效')));
                  }
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示排序弹窗
  void _showSortingDialog(BuildContext context) {
    // 创建本地排序副本
    final localCopy = [..._aps.rooms.value.where((room) => true).toList()]..sort((a, b) {
      if (a.id == _aps.selectroom.value?.id) return -1;
      if (b.id == _aps.selectroom.value?.id) return 1;
      return 0;
    });

    showDialog(
      context: context,
      builder: (context) => SortingJumpDialog(
        // 传递本地副本
        rooms: localCopy,
        onApply: (sortedRooms) {
          // 直接应用排序结果并更新选中状态
          setState(() {
            // 1. 直接使用排序结果更新本地列表
            _aps.rooms.value = [...sortedRooms];
            
            // 2. 强制选中排序后的第一个房间
            if (sortedRooms.isNotEmpty) {
              _aps.selectroom.value = sortedRooms.first;
            }
          });
        },
        onSave: (sortedRooms) async {
          await Future.wait(sortedRooms.map((room) => _aps.updateRoom(room)));
          // 同步更新本地排序
          setState(() {
            _aps.rooms.value = [...sortedRooms];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // 构建房间列表视图
  Widget _buildRoomsView(BuildContext context, BoxConstraints constraints) {
    final columnCount = _getColumnCount(constraints.maxWidth);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columnCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // 使用过滤后的房间列表长度
            childCount:
                _aps.rooms.watch(context).where((room) {
                  return true;
                }).length,
            itemBuilder: (context, index) {
              // 获取过滤后的房间列表
              final filteredRooms =
                  _aps.rooms.watch(context).where((room) {
                    return true;
                  }).toList();
              final room = filteredRooms[index];
              return RoomCard(
                // 传递 Room 对象和标签名称列表
                room: room,
                onEdit: () {
                  showEditRoomDialog(context, room: room);
                },
                onDelete: () {
                  _aps.deleteRoom(room.id);
                },
                onShare: () {
                  var a = encryptRoomWithJWT(room);
                  // 复制房间信息到剪贴板
                  Clipboard.setData(ClipboardData(text: a));
                  // 显示 SnackBar 提示
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('房间信息已复制到剪贴板')));
                },
              );
            },
          ),
        ),
        // 添加底部安全区域，防止内容被遮挡
        SliverToBoxAdapter(
          child: SizedBox(
            height:
                MediaQuery.of(context).padding.bottom + 20, // 底部安全区高度 + 额外间距
          ),
        ),
      ],
    );
  }

  // 新增：CoState 枚举转中文
  String _coStateToText(CoState state) {
    switch (state) {
      case CoState.idle:
        return '未连接';
      case CoState.connecting:
        return '连接中';
      case CoState.connected:
        return '已连接';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听连接状态和房间列表变化
    final isConnected = _aps.Connec_state.watch(context);
    // 使用双重监听确保选中状态实时更新
    final selectedRoom = _aps.selectroom.watch(context);

    // 实时获取并排序房间列表
    final filteredRooms = _aps.rooms.watch(context)
        .where((room) => true)
        .toList()
      ..sort((a, b) {
        if (a.id == selectedRoom?.id) return -1;
        if (b.id == selectedRoom?.id) return 1;
        return 0;
      });

    // 强制触发重建当房间顺序变化时
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (filteredRooms.isNotEmpty && 
          filteredRooms.first.id != selectedRoom?.id) {
        // 如果第一个房间未被选中则自动选择
        _aps.selectroom.value = filteredRooms.first;
      }
    });

    // 构建房间列表视图
    Widget _buildRoomsView(BuildContext context, BoxConstraints constraints) {
      final columnCount = _getColumnCount(constraints.maxWidth);
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: columnCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // 使用排序后的房间列表长度
              childCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return RoomCard(
                  // 传递 Room 对象和标签名称列表
                  room: room,
                  onEdit: () {
                    showEditRoomDialog(context, room: room);
                  },
                  onDelete: () {
                    _aps.deleteRoom(room.id);
                  },
                  onShare: () {
                    var a = encryptRoomWithJWT(room);
                    // 复制房间信息到剪贴板
                    Clipboard.setData(ClipboardData(text: a));
                    // 显示 SnackBar 提示
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('房间信息已复制到剪贴板')));
                  },
                );
              },
            ),
          ),
          // 添加底部安全区域，防止内容被遮挡
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom + 20, // 底部安全区高度 + 额外间距
            ),
          ),
        ],
      );
    }

    // 返回构建的UI
    return Scaffold(
      body: Column(
        children: [
          // 顶部显示当前选中房间信息
          if (selectedRoom != null)
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: Card(
                margin: const EdgeInsets.all(18),
                elevation: isHovered ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isHovered ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isConnected == CoState.connected ? () {
                      var shareCode = encryptRoomWithJWT(selectedRoom);
                      Clipboard.setData(ClipboardData(text: shareCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('房间信息已复制到剪贴板')),
                      );
                    } : null,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text('当前房间: ${selectedRoom.name}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('连接状态: ${_coStateToText(isConnected)}${isConnected == CoState.connected ? ' (点击分享房间)' : ''}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: isConnected != CoState.idle
                // 已连接：显示用户列表
                ? const UserPage()
                // 未连接：显示房间列表
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildRoomsView(context, constraints);
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: isConnected != CoState.idle
          ? null // 已连接时不显示按钮
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'sort',
                  onPressed: () => _showSortingDialog(context),
                  child: const Icon(Icons.sort),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'paste',
                  onPressed: _showPasteDialog,
                  child: const Icon(Icons.paste),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () => showAddRoomDialog(context),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }
}