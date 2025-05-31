import 'dart:async';
import 'package:flutter/material.dart';
import 'package:astral/k/models/room.dart';

typedef ApplyCallback = void Function(List<Room> sortedRooms);
typedef SaveCallback = Future<void> Function(List<Room> sortedRooms);

class SortingJumpDialog extends StatefulWidget {
  final List<Room> rooms;
  final ApplyCallback onApply;
  final SaveCallback onSave;

  const SortingJumpDialog({
    super.key,
    required this.rooms,
    required this.onApply,
    required this.onSave,
  });

  @override
  State<SortingJumpDialog> createState() => _SortingJumpDialogState();
}

class _SortingJumpDialogState extends State<SortingJumpDialog> {
  late List<Room> _sortedRooms;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollTimer;
  String _currentHoveredRoomName = '';

  @override
  void initState() {
    super.initState();
    // 创建本地副本
    _sortedRooms = [...widget.rooms];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildTitle(colorScheme),
      content: SizedBox(
        width: screenSize.width *  0.65,
        height: screenSize.height / 2, 
        child: Column(
          children: [
            Expanded(
              child: _buildRoomList(colorScheme),
            ),
          ],
        ),
      ),
      actions: [
        _buildApplyButton(colorScheme),
        _buildSaveButton(colorScheme),
      ],
    );
  }

  // 构建标题组件
  Widget _buildTitle(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.sort, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('排序房间', style: TextStyle(fontSize: 18, color: colorScheme.primary)),
      ],
    );
  }

  // 构建房间列表
  Widget _buildRoomList(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(16), 
        color: Colors.transparent,
        child: ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollController: _scrollController,
          itemCount: _sortedRooms.length,
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return child;
          },
          itemBuilder: (context, index) {
            final room = _sortedRooms[index];
            return Padding(
              key: ValueKey(room.id),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _currentHoveredRoomName = room.name;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _currentHoveredRoomName = '';
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _currentHoveredRoomName == room.name
                        ? colorScheme.primaryContainer.withOpacity(0.12)
                        : (Theme.of(context).brightness == Brightness.light)
                          ? colorScheme.surfaceVariant.withOpacity(0.95) 
                          : colorScheme.surfaceVariant.withOpacity(0.15),
                    border: Border.all(
                      color: _currentHoveredRoomName == room.name
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(room.name, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                      subtitle: Text(room.encrypted ? '加密房间' : '开放房间', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      trailing: null,
                    ),
                  ),
                ),
              )
            );
          },
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final movedItem = _sortedRooms.removeAt(oldIndex);
              _sortedRooms.insert(newIndex, movedItem);
            });
          },
        ),
      ),
    );
  }

  // 构建应用按钮
  Widget _buildApplyButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: () {
        // 直接传递本地排序结果
        widget.onApply(_sortedRooms);
      },
      child: Text('应用', 
        style: TextStyle(fontSize: 16, color: colorScheme.secondary)
      ),
    ); 
  }

  // 构建保存按钮
  Widget _buildSaveButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: () async {
        // 直接传递本地排序结果
        await widget.onSave(_sortedRooms);
      },
      child: Text('保存', 
        style: TextStyle(fontSize: 16, color: colorScheme.primary)
      ),
    ); 
  }
}