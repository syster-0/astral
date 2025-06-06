import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/models/room.dart';
import 'package:flutter/material.dart';

Future<void> showEditRoomDialog(
  BuildContext context, {
  required Room room,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return _EditRoomDialog(room: room);
    },
  );
}

class _EditRoomDialog extends StatefulWidget {
  final Room room;
  const _EditRoomDialog({required this.room});

  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  late String _currentHoveredRoomName;
  late String? name;

  @override
  void initState() {
    super.initState();
    name = widget.room.name;
    _currentHoveredRoomName = '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.meeting_room, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text('编辑房间', style: TextStyle(fontSize: 18, color: colorScheme.primary)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: name),
            decoration: InputDecoration(
              labelText: '房间名称',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) => widget.room.name = value,
          ),
          const SizedBox(height: 8),
          // 添加拖拽控件悬停效果
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _currentHoveredRoomName = widget.room.name;
              });
            },
            onExit: (_) {
              setState(() {
                _currentHoveredRoomName = '';
              });
            },
            child: Draggable(
              data: widget.room,
              feedback: Material(
                elevation: 4.0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.primary.withOpacity(0.12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        '拖动排序',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.room.encrypted ? '加密房间' : '普通房间',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.primary.withAlpha(150),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (!widget.room.encrypted) ...[
            TextField(
              controller: TextEditingController(text: widget.room.roomName),
              decoration: InputDecoration(
                labelText: '房间号',
                prefixIcon: Icon(Icons.door_front_door),
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => widget.room.roomName = value,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: widget.room.password),
              decoration: InputDecoration(
                labelText: '房间密码',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => widget.room.password = value,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '取消',
            style: TextStyle(fontSize: 16, color: colorScheme.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            Aps().updateRoom(widget.room);
            Navigator.of(context).pop();
          },
          child: Text(
            '确定',
            style: TextStyle(fontSize: 16, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}