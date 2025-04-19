import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加这一行导入Clipboard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  // 示例房间数据，添加category字段，现在category是List<String>类型
  final List<Map<String, dynamic>> rooms = [
    {
      'name': '讨论组1',
      'isEncrypted': true,
      'encryptedText': 'E#RT%Y^U&I*O(P)',
      'categories': ['工作'],
    },
    {
      'name': '学习小组',
      'isEncrypted': false,
      'roomCode': 'STUDY01',
      'password': '123456',
      'categories': ['学习'],
    },
    {
      'name': '项目会议',
      'isEncrypted': true,
      'encryptedText': 'A@S#DF%G^H&J*K',
      'categories': ['工作'],
    },
    {
      'name': '闲聊群',
      'isEncrypted': false,
      'roomCode': 'CHAT02',
      'password': 'chat2023',
      'categories': ['娱乐'],
    },
  ];

  // 当前选中的分类，现在是Set类型，可以多选
  final Set<String> _selectedCategories = {};

  // 编辑房间信息
  void _editRoom(int index, Map<String, dynamic> updatedRoom) {
    setState(() {
      rooms[index] = updatedRoom;
    });
  }

  // 获取所有分类
  List<String> get _categories {
    final Set<String> categories = {};
    for (var room in rooms) {
      categories.addAll(List<String>.from(room['categories']));
    }
    return categories.toList()..sort();
  }

  // 根据当前选中的分类过滤房间
  List<Map<String, dynamic>> get _filteredRooms {
    if (_selectedCategories.isEmpty) {
      return rooms;
    }
    return rooms.where((room) {
      List<String> roomCategories = List<String>.from(room['categories']);
      // 只要房间的任一分类在选中的分类中，就显示该房间
      return roomCategories.any(
        (category) => _selectedCategories.contains(category),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 根据约束计算列数
          final columnCount = _getColumnCount(constraints.maxWidth);

          return CustomScrollView(
            // 添加这个属性来控制滚动行为
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 添加分类选择器
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: _buildCategorySelector(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: columnCount, // 使用计算出的列数
                  mainAxisSpacing: 12, // 主轴间距
                  crossAxisSpacing: 12, // 交叉轴间距
                  childCount: _filteredRooms.length, // 使用过滤后的房间列表
                  itemBuilder: (context, index) {
                    final room = _filteredRooms[index];
                    return RoomCard(
                      name: room['name'],
                      isEncrypted: room['isEncrypted'],
                      encryptedText: room['encryptedText'],
                      roomCode: room['roomCode'],
                      password: room['password'],
                      categories: List<String>.from(room['categories']),
                      onEdit: () {
                        // 找到原始索引
                        final originalIndex = rooms.indexOf(room);
                        _showEditDialog(context, originalIndex, room);
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

  // 构建分类选择器
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // 全部分类选项
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: const Text('全部'),
                  selected: _selectedCategories.isEmpty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategories.clear();
                    });
                  },
                ),
              ),
              // 各个分类选项
              ..._categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
              // 添加新分类按钮
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: const Text('+ 新分类'),
                  onPressed: () => _showAddCategoryDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 显示添加分类对话框
  void _showAddCategoryDialog(BuildContext context) {
    final categoryController = TextEditingController();

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
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !_categories.contains(newCategory)) {
                  // 添加一个带有新分类的空房间，这样分类就会被添加到列表中
                  setState(() {
                    // 这里我们不实际添加房间，只是更新一个现有房间的分类
                    if (rooms.isNotEmpty) {
                      final firstRoom = rooms[0];
                      List<String> categories = List<String>.from(
                        firstRoom['categories'],
                      );
                      if (!categories.contains(newCategory)) {
                        categories.add(newCategory);
                        firstRoom['categories'] = categories;
                      }
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  // 显示编辑对话框
  void _showEditDialog(
    BuildContext context,
    int index,
    Map<String, dynamic> room,
  ) {
    final nameController = TextEditingController(text: room['name']);
    final roomCodeController = TextEditingController(
      text: room['roomCode'] ?? '',
    );
    final passwordController = TextEditingController(
      text: room['password'] ?? '',
    );

    // 复制分类列表，避免直接修改原始数据
    List<String> selectedCategories = List<String>.from(room['categories']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      enabled: !room['isEncrypted'], // 加密房间不能修改名称
                    ),
                    const SizedBox(height: 16),
                    const Text('分类:'),
                    Wrap(
                      spacing: 8.0,
                      children:
                          _categories.map((category) {
                            return FilterChip(
                              label: Text(category),
                              selected: selectedCategories.contains(category),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCategories.add(category);
                                  } else {
                                    selectedCategories.remove(category);
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
                          value: room['isEncrypted'],
                          onChanged: null, // 不允许修改加密状态
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (room['isEncrypted'])
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('加密密文:'),
                          const SizedBox(height: 4),
                          Text(
                            room['encryptedText'] ?? '',
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
                  onPressed: () {
                    final updatedRoom = Map<String, dynamic>.from(room);

                    // 只有非加密房间才能更新名称、房间码和密码
                    if (!room['isEncrypted']) {
                      updatedRoom['name'] = nameController.text;
                      updatedRoom['roomCode'] = roomCodeController.text;
                      updatedRoom['password'] = passwordController.text;
                    }

                    // 更新分类
                    updatedRoom['categories'] = selectedCategories;

                    _editRoom(index, updatedRoom);
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

  // 显示创建房间的步骤对话框
  void _showCreateRoomDialog(BuildContext context) {
    int currentStep = 0;
    String roomName = '';
    bool isEncrypted = false;
    List<String> selectedCategories = [];
    String roomCode = '';
    String password = '';
    String encryptedText = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget stepContent;

            // 步骤1：输入房间名称
            if (currentStep == 0) {
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
                          setState(() {
                            isEncrypted = value;
                            if (isEncrypted) {
                              // 生成随机加密密文
                              encryptedText = _generateEncryptedText();
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
                        _categories.map((category) {
                          return FilterChip(
                            label: Text(category),
                            selected: selectedCategories.contains(category),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategories.add(category);
                                } else {
                                  selectedCategories.remove(category);
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
                      _showAddCategoryDialog(context);
                      // 强制刷新对话框以显示新分类
                      setState(() {});
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
                      setState(() {
                        currentStep--;
                      });
                    },
                    child: const Text('上一步'),
                  ),
                TextButton(
                  onPressed: () {
                    if (currentStep < 2) {
                      // 验证当前步骤
                      if (currentStep == 0 && roomName.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入房间名称')),
                        );
                        return;
                      }

                      setState(() {
                        currentStep++;
                      });
                    } else {
                      // 完成创建
                      if (selectedCategories.isEmpty) {
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

                      // 创建新房间
                      final newRoom = {
                        'name': roomName,
                        'isEncrypted': isEncrypted,
                        'categories': selectedCategories,
                      };

                      if (isEncrypted) {
                        newRoom['encryptedText'] = encryptedText;
                      } else {
                        newRoom['roomCode'] = roomCode;
                        newRoom['password'] = password;
                      }

                      setState(() {
                        rooms.add(newRoom);
                      });

                      Navigator.pop(context);
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
}

// 修改RoomCard类，添加categories参数
class RoomCard extends StatefulWidget {
  final String name;
  final bool isEncrypted;
  final String? encryptedText;
  final String? roomCode;
  final String? password;
  final List<String> categories;
  final VoidCallback? onEdit;

  const RoomCard({
    super.key,
    required this.name,
    required this.isEncrypted,
    this.encryptedText,
    this.roomCode,
    this.password,
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
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      // 添加编辑按钮
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
                        widget.isEncrypted ? Icons.lock : Icons.lock_open,
                        color: widget.isEncrypted ? Colors.red : Colors.green,
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
              // 显示分类标签
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    widget.categories.map((category) {
                      return Chip(
                        label: Text(category),
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
                '类型: ${widget.isEncrypted ? "加密" : "不加密"}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              // 展开时显示详细信息
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                if (widget.isEncrypted)
                  _buildCopyableRow('加密密文', widget.encryptedText ?? '')
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCopyableRow('房间码', widget.roomCode ?? ''),
                      const SizedBox(height: 8),
                      _buildCopyableRow('房间密码', widget.password ?? ''),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
                overflow: TextOverflow.ellipsis,
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
