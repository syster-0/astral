import 'dart:math';

import 'package:astral/wid/room_tags_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加这一行导入Clipboard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// 导入 Aps 和相关模型
import 'package:astral/k/app_s/Aps.dart';
import 'package:astral/k/models/room.dart';

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

  Future<void> _showAddRoomDialog() async {
    bool isEncrypted = false;
    String? name;
    String? roomName;
    String? roomPassword;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加房间'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: '房间名称'),
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('是否加密'),
                    value: isEncrypted,
                    onChanged: (value) {
                      setState(() {
                        isEncrypted = value;
                      });
                    },
                  ),
                  if (!isEncrypted) ...[
                    TextField(
                      decoration: const InputDecoration(labelText: '房间号'),
                      onChanged: (value) => roomName = value,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: '房间密码'),
                      onChanged: (value) => roomPassword = value,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    addEncryptedRoom(
                      isEncrypted,
                      name!,
                      roomName!,
                      roomPassword!,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用 watch 监听标签变化，以便在标签增删时更新分类选择器
    final currentCategories = _aps.allRoomTags.watch(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = _getColumnCount(constraints.maxWidth);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  // 传递当前获取的分类列表
                  child: RoomTagsSelector(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: columnCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // 使用过滤后的房间列表长度
                  childCount:
                      _aps.rooms.watch(context).where((room) {
                        // 如果没有选中的标签，显示所有房间
                        if (!currentCategories.any((tag) => tag.selected)) {
                          return true;
                        }
                        // 如果有选中的标签，只显示包含选中标签的房间
                        return room.tags.any(
                          (tagId) => currentCategories
                              .where((tag) => tag.selected)
                              .any((tag) => tag.id.toString() == tagId),
                        );
                      }).length,
                  itemBuilder: (context, index) {
                    // 获取过滤后的房间列表
                    final filteredRooms =
                        _aps.rooms.watch(context).where((room) {
                          if (!currentCategories.any((tag) => tag.selected)) {
                            return true;
                          }
                          return room.tags.any(
                            (tagId) => currentCategories
                                .where((tag) => tag.selected)
                                .any((tag) => tag.id.toString() == tagId),
                          );
                        }).toList();

                    final room = filteredRooms[index];
                    // 查找房间对应的标签名称列表
                    final roomCategoryNames =
                        currentCategories
                            .where((tag) => room.tags.contains(tag.id))
                            .map((tag) => tag.tag)
                            .toList();

                    return RoomCard(
                      // 传递 Room 对象和标签名称列表
                      room: room,
                      categories: roomCategoryNames,
                      onEdit: () {},
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void addEncryptedRoom(bool isEncrypted, String name, String s, String t) {
  Aps().addRoom(
    Room(
      name: name,
      encrypted: isEncrypted,
      roomName: s,
      roomCode: s,
      password: t,
      tags: ['23213'],
    ),
  );
}

// 修改RoomCard类，接收 Room 对象和分类名称列表
class RoomCard extends StatefulWidget {
  final Room room; // 接收 Room 对象
  final List<String> categories; // 接收分类名称列表
  final VoidCallback? onEdit;

  const RoomCard({
    super.key,
    required this.room,
    required this.categories,
    this.onEdit,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room; // 获取传入的 room 对象

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.name, // 使用 room.name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: widget.onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: '编辑房间',
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        room.encrypted
                            ? Icons.lock
                            : Icons.lock_open, // 使用 room.isEncrypted
                        color: room.encrypted ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 显示分类标签 - 使用传入的 categories 列表
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    widget.categories.map((categoryName) {
                      // 使用 widget.categories
                      return Chip(
                        label: Text(categoryName),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        labelStyle: const TextStyle(fontSize: 12),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 4),
              Text(
                '类型: ${room.encrypted ? "加密" : "不加密"}', // 使用 room.isEncrypted
                style: TextStyle(color: Colors.grey[600]),
              ),
              // 展开时显示详细信息 - 使用 room 对象
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                if (room.encrypted)
                  _buildCopyableRow(
                    '加密密文',
                    room.roomCode,
                  ) // 使用 room.encryptedText
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCopyableRow(
                        '房间码',
                        room.roomCode,
                      ), // 使用 room.roomCode
                      const SizedBox(height: 8),
                      _buildCopyableRow(
                        '房间密码',
                        room.password,
                      ), // 使用 room.password
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // _buildCopyableRow 方法保持不变
  Widget _buildCopyableRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label:', style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis, // 防止长文本溢出
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () => _copyToClipboard(value, context),
          tooltip: '复制$label',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
