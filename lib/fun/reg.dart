import 'dart:io';
import 'package:flutter/foundation.dart';

Future<void> handleStartupSetting(bool enable) async {
  final executablePath = Platform.resolvedExecutable;
  final startupFolder =
      '${Platform.environment['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup';
  final shortcutPath = '$startupFolder\\Astral.lnk';

  if (enable) {
    // 检查快捷方式是否存在
    if (await File(shortcutPath).exists()) {
      // 如果存在，先删除旧的快捷方式
      await File(shortcutPath).delete();
    }

    // 创建新的快捷方式
    final shell = 'powershell';
    final args = [
      '-Command',
      '\$WshShell = New-Object -ComObject WScript.Shell; '
          '\$Shortcut = \$WshShell.CreateShortcut("$shortcutPath"); '
          '\$Shortcut.TargetPath = "$executablePath"; '
          '\$Shortcut.Save()',
    ];
    await Process.run(shell, args);
  } else {
    // 删除快捷方式
    if (await File(shortcutPath).exists()) {
      await File(shortcutPath).delete();
    }
  }
}

class UrlSchemeRegistrar {
  /// 注册URL scheme到Windows注册表
  static Future<bool> registerUrlScheme() async {
    if (!Platform.isWindows) return true;
    
    try {
      final executablePath = Platform.resolvedExecutable;
      
      // 直接通过reg add命令注册，无需临时文件
      final commands = [
        // 注册主键
        ['add', 'HKEY_CLASSES_ROOT\\astral', '/ve', '/d', 'URL:Astral Protocol', '/f'],
        ['add', 'HKEY_CLASSES_ROOT\\astral', '/v', 'URL Protocol', '/d', '', '/f'],
        
        // 注册图标
        ['add', 'HKEY_CLASSES_ROOT\\astral\\DefaultIcon', '/ve', '/d', '"$executablePath",1', '/f'],
        
        // 注册命令
        ['add', 'HKEY_CLASSES_ROOT\\astral\\shell\\open\\command', '/ve', '/d', '"$executablePath" "%1"', '/f'],
      ];
      
      // 执行所有注册表命令
      for (final command in commands) {
        final result = await Process.run('reg', command);
        if (result.exitCode != 0) {
          if (kDebugMode) {
            print('Failed to execute reg command: ${command.join(' ')}');
            print('Error: ${result.stderr}');
          }
          return false;
        }
      }
      
      if (kDebugMode) {
        print('URL scheme registered successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error registering URL scheme: $e');
      }
      return false;
    }
  }
  
  /// 检查URL scheme是否已注册
  static Future<bool> isUrlSchemeRegistered() async {
    if (!Platform.isWindows) return true;
    
    try {
      final result = await Process.run('reg', [
        'query',
        'HKEY_CLASSES_ROOT\\astral',
        '/ve'
      ]);
      
      return result.exitCode == 0 && 
             result.stdout.toString().contains('URL:Astral Protocol');
    } catch (e) {
      if (kDebugMode) {
        print('Error checking URL scheme registration: $e');
      }
      return false;
    }
  }
  
  /// 卸载URL scheme注册
  static Future<bool> unregisterUrlScheme() async {
    if (!Platform.isWindows) return true;
    
    try {
      final result = await Process.run('reg', [
        'delete',
        'HKEY_CLASSES_ROOT\\astral',
        '/f'
      ]);
      
      if (result.exitCode == 0) {
        if (kDebugMode) {
          print('URL scheme unregistered successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to unregister URL scheme: ${result.stderr}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering URL scheme: $e');
      }
      return false;
    }
  }
  
  /// 更新URL scheme注册（当exe路径改变时）
  static Future<bool> updateUrlSchemeRegistration() async {
    if (!Platform.isWindows) return true;
    
    try {
      // 检查是否已注册
      final isRegistered = await isUrlSchemeRegistered();
      
      if (isRegistered) {
        // 如果已注册，重新注册以更新路径
        return await registerUrlScheme();
      } else {
        // 如果未注册，直接注册
        return await registerUrlScheme();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating URL scheme registration: $e');
      }
      return false;
    }
  }
}
