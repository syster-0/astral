import 'package:astral/fun/e_d_room.dart';
import 'package:astral/fun/random_name.dart';
import 'package:astral/fun/show_add_room_dialog.dart';
import 'package:astral/fun/show_edit_room_dialog.dart';
import 'package:astral/wid/room_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// 导入 Aps 和相关模型
import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/models/room.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  // 使用 Aps 实例
  final _aps = Aps();

  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('房间信息已复制到剪贴板')),
                        );
                      },
                    );
                  },
                ),
              ),
              // 添加底部安全区域，防止内容被遮挡
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom +
                      20, // 底部安全区高度 + 额外间距
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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

void addEncryptedRoom(
  bool isEncrypted,
  String? name,
  String? roomname,
  String? password,
) {
  var room = Room(
    name: name ?? RandomName(), // 如果 name 为 null，则使用空字符串
    encrypted: isEncrypted,
    roomName:
        isEncrypted ? Uuid().v4() : (roomname ?? ""), // 如果未加密，则使用随机UUID作为房间名
    password: isEncrypted ? Uuid().v4() : (password ?? ""), // 如果未加密，则生成一个随机密码
    tags: [],
  );
  Aps().addRoom(room);
}
