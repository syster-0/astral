import 'dart:io';

Future<void> handleStartupSetting(bool enable) async {
  final executablePath = Platform.resolvedExecutable;
  final appName = 'Astral';
  final regPath = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';

  if (enable) {
    // 添加注册表项，实现开机自启动
    final args = [
      'add',
      regPath,
      '/v',
      appName,
      '/t',
      'REG_SZ',
      '/d',
      '"$executablePath"',
      '/f',
    ];
    await Process.run('reg', args);
  } else {
    // 删除注册表项，取消开机自启动
    final args = ['delete', regPath, '/v', appName, '/f'];
    await Process.run('reg', args);
  }
}
