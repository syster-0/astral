import 'package:astral/k/app_s/Aps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RoomTagsSelector extends StatefulWidget {
  const RoomTagsSelector({super.key});

  @override
  State<RoomTagsSelector> createState() => _RoomTagsSelectorState();
}

class _RoomTagsSelectorState extends State<RoomTagsSelector> {
  // 添加状态变量来跟踪长按准备删除的标签
  String? _tagMarkedForDeletion;
  // 添加状态变量来跟踪快速删除模式
  bool _isDeleteModeActive = false;
  // 1. 创建 ScrollController
  final ScrollController _scrollController = ScrollController();

  // 4. 添加 dispose 方法来释放 controller
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 在 build 方法开头获取一次标签列表，避免重复 watch
    final allTags = Aps().allRoomTags.watch(context);
    // 检查是否有任何一个标签被选中
    final bool isAnyTagSelected = allTags.any((tag) => tag.selected);

    // 将 Column 改为 Row
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐
      children: [
        Expanded(
          child: Listener(
            // 添加鼠标滚轮事件监听
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                // 将垂直滚动转换为水平滚动
                _scrollController.position.moveTo(
                  _scrollController.offset + event.scrollDelta.dy,
                  curve: Curves.linear,
                );
              }
            },
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              // 添加以下属性调整滚动条位置
              thickness: 6, // 减小滚动条厚度
              radius: const Radius.circular(3), // 圆角
              interactive: true, // 确保可交互

              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(), // 添加此属性确保滚动行为正常
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 8.0,
                      ), // 给第一个标签加左边距
                      child: FilterChip(
                        label: const Text('全部'),
                        selected: !isAnyTagSelected,
                        onSelected: (selected) {
                          // 清除所有删除状态
                          setState(() {
                            _tagMarkedForDeletion = null;
                            _isDeleteModeActive = false;
                          });
                          if (selected) {
                            Aps().clearAllTagSelections();
                          }
                        },
                      ),
                    ),
                    // 遍历分类列表
                    ...allTags.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _tagMarkedForDeletion = category.tag;
                              _isDeleteModeActive = false;
                            });
                          },
                          child: FilterChip(
                            label: Text(category.tag),
                            selected: category.selected,
                            onSelected: (selected) {
                              setState(() {
                                _tagMarkedForDeletion = null;
                                _isDeleteModeActive = false;
                              });
                              Aps().setTagSelected(category.tag, selected);
                            },
                            onDeleted:
                                (_isDeleteModeActive ||
                                        _tagMarkedForDeletion == category.tag)
                                    ? () {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        category.tag,
                                      );
                                      if (_tagMarkedForDeletion ==
                                          category.tag) {
                                        setState(() {
                                          _tagMarkedForDeletion = null;
                                        });
                                      }
                                    }
                                    : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 将按钮移到 Expanded 外部，并用 Padding 包裹
        Padding(
          padding: const EdgeInsets.only(right: 1.0), // 添加右边距
          child: Row(
            mainAxisSize: MainAxisSize.min, // 使 Row 包裹其内容
            children: [
              // 1. 快速删除按钮
              IconButton(
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color:
                      _isDeleteModeActive
                          ? Theme.of(context).colorScheme.error
                          : null,
                ),
                tooltip: '切换快速删除模式',
                onPressed: () {
                  setState(() {
                    _isDeleteModeActive = !_isDeleteModeActive;
                    _tagMarkedForDeletion = null;
                  });
                },
              ),
              // 2. 添加新分类按钮
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '添加新分类',
                onPressed: () {
                  setState(() {
                    _tagMarkedForDeletion = null;
                    _isDeleteModeActive = false;
                  });
                  _showAddCategoryDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 添加显示添加分类对话框的方法
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加新分类'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "请输入分类名称"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: const Text('添加'),
              onPressed: () {
                final String newTagName = controller.text.trim();
                if (newTagName.isNotEmpty) {
                  // 调用 Aps 中的方法来添加新标签（假设存在 addRoomTag 方法）
                  Aps().addTag(newTagName);
                  Navigator.of(context).pop(); // 关闭对话框
                } else {
                  // 可以选择性地显示错误提示，例如使用 SnackBar
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('分类名称不能为空')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 添加显示删除确认对话框的方法
  void _showDeleteConfirmationDialog(BuildContext context, String tagToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除标签 "$tagToDelete" 吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ), // 强调删除按钮
              child: const Text('删除'),
              onPressed: () {
                // 调用 Aps 中的方法来删除标签（假设存在 deleteTag 方法）
                Aps().deleteTag(tagToDelete);
                Navigator.of(context).pop(); // 关闭对话框
                // 确认删除后，最好也清除一下标记，以防万一
                // （虽然理论上在调用此函数前或后，状态会被其他操作清除）
                // setState(() {
                //   if (_tagMarkedForDeletion == tagToDelete) {
                //      _tagMarkedForDeletion = null;
                //   }
                //   // 保持 _isDeleteModeActive 不变
                // });
              },
            ),
          ],
        );
      },
    );
  }
}
