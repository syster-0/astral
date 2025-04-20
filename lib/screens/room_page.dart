import 'dart:math';

import 'package:astral/wid/room_tags_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加这一行导入Clipboard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// 导入 Aps 和相关模型
import 'package:astral/k/app_s/Aps.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/k/models/room_tags.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  // 使用 Aps 实例
  final _aps = Aps();

  // 当前选中的分类标签ID，现在是Set类型，可以多选
  final Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
  }

  // 编辑房间信息 - 调用 Aps 更新
  Future<void> _editRoom(Room updatedRoom) async {
    await _aps.updateRoom(updatedRoom);
    // Aps().rooms 信号会自动更新，UI 会通过 watch 响应
  }

  // 添加新分类 - 调用 Aps 添加
  Future<void> _addCategory(String categoryName) async {
    await _aps.addTag(categoryName);
    // Aps().roomTags 信号会自动更新
  }

  // 根据当前选中的分类过滤房间 - 使用 Aps 数据
  List<Room> get _filteredRooms {
    // 使用 watch 监听 Aps().rooms 的变化
    final allRooms = _aps.rooms.watch(context);

    if (_selectedCategoryIds.isEmpty) {
      return allRooms;
    }
    return allRooms.where((room) {
      // 检查房间的标签ID列表是否包含任何选中的标签ID
      return room.tags.any((tagId) => _selectedCategoryIds.contains(tagId));
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    // 使用 watch 监听标签变化，以便在标签增删时更新分类选择器
    final currentCategories = _aps.allRoomTags.watch(context);
    // _filteredRooms 内部已经 watch 了 rooms

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
                  childCount: _filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = _filteredRooms[index];
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
                      onEdit: () {
                        _showEditDialog(context, room);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateRoomDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 显示添加分类对话框 - 调用 Aps 添加
  void _showAddCategoryDialog(BuildContext context) {
    final categoryController = TextEditingController();
    // 获取当前所有标签名称，用于检查重复
    final existingCategoryNames =
        _aps.allRoomTags.peek().map((t) => t.tag).toSet();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加新分类'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: '分类名称'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                // 改为 async
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !existingCategoryNames.contains(newCategory)) {
                  // 调用 Aps 的方法添加标签
                  await _addCategory(newCategory);
                  Navigator.pop(context); // 关闭对话框
                  // 无需 setState，因为 Aps().roomTags 的 watch 会自动更新UI
                } else if (newCategory.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('分类名称不能为空')));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('该分类已存在')));
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  // 显示编辑对话框 - 使用 Room 对象和 Aps 数据
  void _showEditDialog(BuildContext context, Room room) {
    final nameController = TextEditingController(text: room.name);
    final roomCodeController = TextEditingController(text: room.roomCode ?? '');
    final passwordController = TextEditingController(text: room.password ?? '');

    // 使用标签 ID 列表
    List<int> selectedCategoryIds = List<int>.from(room.tags);
    // 获取当前所有可用标签
    final allCategories = _aps.allRoomTags.peek();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // 使用 StatefulBuilder 来更新对话框内的状态
          builder: (context, setStateDialog) {
            // 重命名 setState 防止冲突
            return AlertDialog(
              title: const Text('编辑房间'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '房间名称'),
                      enabled: !room.encrypted, // 加密房间不能修改名称
                    ),
                    const SizedBox(height: 16),
                    const Text('分类:'),
                    Wrap(
                      spacing: 8.0,
                      children:
                          allCategories.map((category) {
                            return FilterChip(
                              label: Text(category.tag),
                              selected: selectedCategoryIds.contains(
                                category.id,
                              ),
                              onSelected: (selected) {
                                setStateDialog(() {
                                  // 更新对话框状态
                                  if (selected) {
                                    selectedCategoryIds.add(category.id);
                                  } else {
                                    selectedCategoryIds.remove(category.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('加密房间: '),
                        Switch(
                          value: room.encrypted,
                          onChanged: null, // 不允许修改加密状态
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (room.encrypted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('加密密文:'),
                          const SizedBox(height: 4),
                          Text(
                            room.roomCode ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: roomCodeController,
                            decoration: const InputDecoration(labelText: '房间码'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: '房间密码',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    // 改为 async
                    // 创建更新后的 Room 对象
                    final updatedRoomData = Room(
                      name: room.encrypted ? room.name : nameController.text,
                      encrypted: room.encrypted,
                      roomCode: room.roomCode,
                      password:
                          room.encrypted
                              ? room.password
                              : passwordController.text,
                      tags:
                          selectedCategoryIds
                              .map((id) => id.toString())
                              .toList(), // 将 int 类型的标签 ID 转换为 String 类型
                    );

                    // 调用 Aps 更新房间
                    await _editRoom(updatedRoomData);
                    Navigator.pop(context);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 生成随机加密密文
  String _generateEncryptedText() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        16, // 生成16位密文
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // 显示创建房间的步骤对话框 - 使用 Aps 数据和方法
  void _showCreateRoomDialog(BuildContext context) {
    int currentStep = 0;
    String roomName = '';
    bool isEncrypted = false;
    List<int> selectedCategoryIds = []; // 使用标签 ID
    String roomCode = '';
    String password = '';
    String encryptedText = '';

    // 获取当前所有可用标签
    final allCategories = _aps.allRoomTags.peek(); // 使用 peek 获取当前值

    showDialog(
      context: context,
      // barrierDismissible: false, // 防止点击外部关闭，根据需要启用
      builder: (context) {
        return StatefulBuilder(
          // 使用 StatefulBuilder 更新对话框状态
          builder: (context, setStateDialog) {
            Widget stepContent;
            // 获取最新的分类列表，因为可能在步骤中添加了新分类
            final currentAvailableCategories = _aps.allRoomTags.peek();

            // 步骤1：输入房间名称
            if (currentStep == 0) {
              // ... (内容不变) ...
              stepContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: '房间名称'),
                    onChanged: (value) {
                      roomName = value;
                    },
                    autofocus: true,
                  ),
                ],
              );
            }
            // 步骤2：选择是否加密
            else if (currentStep == 1) {
              // ... (内容不变, 注意使用 setStateDialog) ...
              stepContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('是否加密房间:'),
                      Switch(
                        value: isEncrypted,
                        onChanged: (value) {
                          setStateDialog(() {
                            // 使用 setStateDialog
                            isEncrypted = value;
                            if (isEncrypted) {
                              encryptedText = _generateEncryptedText();
                            } else {
                              encryptedText = ''; // 清除非加密时的密文
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            }
            // 步骤3：选择分类和设置房间信息
            else {
              stepContent = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('选择分类:'),
                  Wrap(
                    spacing: 8.0,
                    children:
                        currentAvailableCategories.map((category) {
                          // 使用最新的分类列表
                          return FilterChip(
                            label: Text(category.tag),
                            selected: selectedCategoryIds.contains(category.id),
                            onSelected: (selected) {
                              setStateDialog(() {
                                // 使用 setStateDialog
                                if (selected) {
                                  selectedCategoryIds.add(category.id);
                                } else {
                                  selectedCategoryIds.remove(category.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),
                  ActionChip(
                    label: const Text('+ 添加新分类'),
                    onPressed: () async {
                      // 弹出添加分类对话框
                      await _showAddCategoryDialogInDialog(context);
                      // 添加新分类后，强制刷新创建对话框以显示新分类
                      setStateDialog(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isEncrypted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('自动生成的加密密文:'),
                        const SizedBox(height: 4),
                        Text(
                          encryptedText,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(labelText: '房间码'),
                          onChanged: (value) {
                            roomCode = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(labelText: '房间密码'),
                          obscureText: true, // 密码建议隐藏
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                      ],
                    ),
                ],
              );
            }

            return AlertDialog(
              title: Text('创建房间 - 步骤 ${currentStep + 1}/3'),
              content: SingleChildScrollView(child: stepContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                if (currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setStateDialog(() {
                        // 使用 setStateDialog
                        currentStep--;
                      });
                    },
                    child: const Text('上一步'),
                  ),
                TextButton(
                  onPressed: () async {
                    // 改为 async
                    if (currentStep < 2) {
                      // 验证当前步骤
                      if (currentStep == 0 && roomName.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入房间名称')),
                        );
                        return;
                      }
                      // 验证步骤 1 (加密选择) - 无需验证

                      setStateDialog(() {
                        // 使用 setStateDialog
                        currentStep++;
                      });
                    } else {
                      // 完成创建前的验证
                      if (selectedCategoryIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请至少选择一个分类')),
                        );
                        return;
                      }

                      if (!isEncrypted &&
                          (roomCode.trim().isEmpty ||
                              password.trim().isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入房间码和密码')),
                        );
                        return;
                      }

                      // 创建新房间对象
                      final newRoom = Room(
                        // id 会在数据库中自动生成，这里不需要传
                        name: roomName.trim(),
                        encrypted: isEncrypted, // 使用 isEncrypted 变量
                        tags:
                            selectedCategoryIds
                                .map((id) => id.toString())
                                .toList(), // 将 int 类型的标签 ID 转换为 String 类型
                        roomCode:
                            isEncrypted
                                ? encryptedText
                                : roomCode.trim(), // 根据是否加密设置 roomCode
                        password:
                            isEncrypted
                                ? ""
                                : password.trim(), // 加密房间密码设为 null 或根据实际模型调整
                        // 移除 isEncrypted, tagIds, encryptedText 这些不存在的或错误的参数
                      );

                      // 调用 Aps 添加房间
                      await _aps.addRoom(newRoom);

                      Navigator.pop(context); // 关闭创建对话框
                      // 无需 setState，Aps().rooms 的 watch 会自动更新列表
                    }
                  },
                  child: Text(currentStep < 2 ? '下一步' : '完成'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 在创建/编辑对话框内部显示添加分类对话框
  Future<void> _showAddCategoryDialogInDialog(BuildContext context) async {
    final categoryController = TextEditingController();
    final existingCategoryNames =
        _aps.allRoomTags.peek().map((t) => t.tag).toSet();

    // 使用 Completer 来等待对话框关闭
    // final completer = Completer<void>();

    await showDialog<void>(
      // 等待对话框关闭
      context: context,
      // 使用一个新的 builder context，避免与外部 dialog 的 context 冲突
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('添加新分类'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: '分类名称'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // 关闭当前添加分类对话框
                // completer.complete();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !existingCategoryNames.contains(newCategory)) {
                  await _addCategory(newCategory); // 调用 Aps 添加
                  Navigator.pop(dialogContext); // 关闭当前添加分类对话框
                  // completer.complete();
                } else if (newCategory.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('分类名称不能为空')));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('该分类已存在')));
                }
                // 注意：这里不直接调用 setStateDialog，而是在外部调用处刷新
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
    // return completer.future; // 返回 Future，让调用者可以 await
  }
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
                    room.roomCode ?? '',
                  ) // 使用 room.encryptedText
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCopyableRow(
                        '房间码',
                        room.roomCode ?? '',
                      ), // 使用 room.roomCode
                      const SizedBox(height: 8),
                      _buildCopyableRow(
                        '房间密码',
                        room.password ?? '',
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
