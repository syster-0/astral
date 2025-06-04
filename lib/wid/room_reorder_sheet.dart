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
        
        // 房间列表
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _rooms.length,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final double animValue = Curves.easeOutCubic.transform(animation.value);
                  final double elevation = lerpDouble(8, 8, animValue)!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      elevation: elevation,
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final room = _rooms.removeAt(oldIndex);
                _rooms.insert(newIndex, room);
              });
            },
            itemBuilder: (context, index) {
              final room = _rooms[index];
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
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          onTap: () {}, // 空函数，只为了触发水波纹效果
          child: ReorderableDragStartListener(
            index: index,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: room.encrypted 
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  room.encrypted ? Icons.lock : Icons.public,
                  color: room.encrypted 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              title: Text(
                room.name.isEmpty ? '未命名房间' : room.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                room.roomName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}