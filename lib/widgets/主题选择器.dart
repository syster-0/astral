import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void showThemeColorPicker(
    BuildContext context, Color seedColor, Function(Color) changeSeedColor) {
  // 创建一个临时颜色变量，避免直接修改状态
  Color pickerColor = seedColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('选择主题颜色'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 使用更简单的BlockPicker替代复杂的ColorPicker
              BlockPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                availableColors: const [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                ],
              ),
              const SizedBox(height: 10),
              // 添加一个自定义颜色按钮
              ElevatedButton.icon(
                icon: const Icon(Icons.color_lens),
                label: const Text('自定义颜色'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAdvancedColorPicker(
                      context, pickerColor, changeSeedColor);
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              // 使用 Future.microtask 延迟颜色更改，避免在当前帧中触发重建
              Navigator.of(context).pop();
              changeSeedColor(pickerColor);
            },
          ),
        ],
      );
    },
  );
}

void _showAdvancedColorPicker(
    BuildContext context, Color initialColor, Function(Color) changeSeedColor) {
  Color pickerColor = initialColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('自定义颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
            labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              // 使用 Future.microtask 延迟颜色更改，避免在当前帧中触发重建
              Navigator.of(context).pop();
              Future.microtask(() {
                changeSeedColor(pickerColor);
              });
            },
          ),
        ],
      );
    },
  );
}
