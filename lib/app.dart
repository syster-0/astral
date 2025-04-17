import 'package:astral/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/app_s/Aps.dart';

class KevinApp extends StatefulWidget {
  const KevinApp({super.key});
  @override
  State<KevinApp> createState() => _KevinAppState();
}

class _KevinAppState extends State<KevinApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Aps().themeColor.watch(context), // 设置当前主题颜色,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Aps().themeColor.watch(context),
        brightness: Brightness.dark,
      ),
      themeMode: Aps().themeMode.watch(context), // 设置当前主题模式
      home: MainScreen(),
    );
  }
}
