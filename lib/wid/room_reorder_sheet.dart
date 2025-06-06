import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/k/app_s/aps.dart';

class RoomReorderSheet extends StatefulWidget {
  final List<Room> rooms;
  final Function(List<Room>) onReorder;

  const RoomReorderSheet({
    Key? key,
    required this.rooms,
    required this.onReorder,
  }) : super(key: key);

  @override
  State<RoomReorderSheet> createState() => _RoomReorderSheetState();

  static Future<void> show(BuildContext context, List<Room> rooms) async {
    final aps = Aps();
    
    if (MediaQuery.of(context).size.width > 600) {
      // PC端显示为对话框
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 400,
            height: 600,
            child: RoomReorderSheet(
              rooms: List.from(rooms),
              onReorder: (reorderedRooms) {
                aps.reorderRooms(reorderedRooms);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    } else {
      // 移动端显示为底部弹窗
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: RoomReorderSheet(
              rooms: List.from(rooms),
              onReorder: (reorderedRooms) {
                aps.reorderRooms(reorderedRooms);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    }
  }
}

class _RoomReorderSheetState extends State<RoomReorderSheet> {
  late List<Room> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List.from(widget.rooms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        // 拖拽指示器（仅移动端显示）
        if (MediaQuery.of(context).size.width <= 600)
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '调整房间顺序',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // 提示文本
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            '拖拽房间卡片来调整显示顺序',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        // 房间列表 - 使用 Expanded 填充剩余空间
        Expanded(
          child: ReorderableListView.builder(
            // 设置列表的水平内边距
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // 列表项数量为房间数组长度
            itemCount: _rooms.length,
            // proxyDecorator 用于自定义拖拽时的视觉效果
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                // 使用动画控制器
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  // 使用 easeOutCubic 曲线转换动画值，使动画更自然
                  final double animValue = Curves.easeOutCubic.transform(animation.value);
                  // 计算缩放比例，范围在 1.0 到 1.02 之间
                  final double scale = lerpDouble(1.0, 1.02, animValue)!;
                  // 对拖拽项应用缩放变换
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      // 设置底部间距
                      margin: const EdgeInsets.only(bottom: 8),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            // 处理重新排序的回调
            onReorder: (oldIndex, newIndex) {
              setState(() {
                // 由于移除项后列表长度减1，需要调整新位置的索引
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                // 移除原位置的房间并插入到新位置
                final room = _rooms.removeAt(oldIndex);
                _rooms.insert(newIndex, room);
              });
            },
            // 构建列表项
            itemBuilder: (context, index) {
              final room = _rooms[index];
              // 使用 _RoomReorderItem 构建房间项
              // ValueKey 确保 Flutter 可以正确识别和重用 widget
              return _RoomReorderItem(
                key: ValueKey(room.id),
                room: room,
                index: index,
              );
            },
          ),
        ),
        
        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onReorder(_rooms),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('确认'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomReorderItem extends StatelessWidget {
  final Room room;
  final int index;

  const _RoomReorderItem({
    Key? key,
    required this.room,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        // 设置卡片的阴影高度
        elevation: 1,
        // 设置卡片的圆角
        borderRadius: BorderRadius.circular(16),
        // 设置卡片的背景色为低对比度的surface容器色
        color: colorScheme.surfaceContainerLow,
        child: InkWell(
          // 设置水波纹效果的圆角，与外层Material保持一致
          borderRadius: BorderRadius.circular(16),
          // 设置点击时的水波纹颜色，使用主题色的10%透明度
          splashColor: colorScheme.primary.withOpacity(0.1),
          // 设置长按时的高亮颜色，使用主题色的5%透明度
          highlightColor: colorScheme.primary.withOpacity(0.05),
          onTap: () {}, // 空函数，只为了触发水波纹效果
          child: ReorderableDragStartListener(
            // 传入当前项的索引，用于拖拽排序
            index: index,
            child: ListTile(
              // 设置列表项的内边距
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              // 左侧图标区域
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // 根据房间是否加密设置不同的背景色
                  color: room.encrypted 
                      ? colorScheme.primaryContainer  // 加密房间使用主题色容器
                      : colorScheme.secondaryContainer,  // 非加密房间使用次要色容器
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  // 根据房间是否加密显示不同的图标
                  room.encrypted ? Icons.lock : Icons.public,
                  // 图标颜色跟随容器色的对应前景色
                  color: room.encrypted 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              // 主标题显示房间名称，为空时显示"未命名房间"
              title: Text(
                room.name.isEmpty ? '未命名房间' : room.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 副标题显示房间ID，超出部分省略
              subtitle: Text(
                room.roomName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 右侧显示拖动手柄图标
            ),
          ),
        ),
      ),
    );
  }
}